---
title: "Controlling Linux Capabilities in OpenShift"
date: 2017-02-18T11:20:55-05:00
draft: false
image: "/images/linux_capabilities/it_crowd.jpg"

categories: 
  - Containers
tags:
  - Ops
  - Linux
  - capabilities
  - howto

# post type
type: post
---

The power of the root user does not come from having the name root

And it does not come from having a uid of 0. The power of the root user is based in a concept inside the Linux kernel called *capabilities*.

## Linux Capabilities

There are things that only the root user can do. One of the most visible examples is having the ability to open up a network port below 1024. This is restricted because if anyone could do it they could intercept traffic on core services like ssh, http, telnet, etc.

There are currently 38 capabilities in Linux, by my count. They do all sorts of things and are documented in the Linux manpages. man capabilities for a full and up-to-date list. Let’s have a little fun and investigate the one I mentioned above.

## Opening ports below 1024 as a regular user

Oh that magic ability! In a normal world, we are not able to start the httpd daemon on port 80 with a regular user.

Trying to start httpd with a regular user

    $ httpd -d $(pwd) -DNO_DETACH
    (13)Permission denied: AH00072: make_sock: could not **bind** to address [::]:80
    (13)Permission denied: AH00072: make_sock: could not **bind** to address 0.0.0.0:80
    no listening sockets available, shutting down

Of course this doesn’t work. It doesn’t work by design. But what happens if we add the CAP_NET_BIND_SERVICE? We can do this with setcap utility in Linux. It may seem a little counter-intuitive that we add the capability to a file and not a user. But when you think it through, this makes a lot of sense for what we are doing with containers. When we create a container we are going to be able to specify the specific capabilities for the application that starts our container.

But before we get to that, let’s confirm that capabilities even work.

Adding a Linux capability to a file in Linux

    $ sudo setcap cap_net_bind_service=+ep /usr/sbin/httpd
    $ getcap /usr/sbin/httpd
    /usr/sbin/httpd = cap_net_bind_service+ep

Now the httpd executable has the CAP_NET_BIND_SERVICE capability. Let’s take this puppy for a test drive!

Running httpd on port 80 as a regular user

    $ whoami
    jduncan
    $ httpd -d $(pwd) -DNO_DETACH

Now if I hop over to another terminal I can test our my handiwork

    $ sudo netstat --numeric-ports -tpl | grep httpd
    tcp6       0      0 [::]:80                 [::]:*                  LISTEN      18024/httpd

Holy crap! It looks like it may have worked! If we test it just to be sure we can curl whatever is listening on localhost on port 80.

    $ curl localhost
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "[http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd](http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd)">

    <html xmlns="[http://www.w3.org/1999/xhtml](http://www.w3.org/1999/xhtml)" xml:lang="en" lang="en">
            <head>
                    <title>Test Page **for** the Apache HTTP Server on Fedora</title>
    ...

And there we have it. We have Apache running on port 80 as a completely normal user. To be honest, I had to do a little work for httpd itself to start up. I had to copy around some config files and tweak some ownership of logs and pid files, etc. It has nothing to do with the port, however. It is just the stuff that httpd needs to do its job.

## Capabilities with docker

The docker daemon has the ability to manage capabilities as well.

The ‘docker run` command has an option called — privileged. This allows the container to share all of the hosts’ namespaces and do all sorts of powerful things. It is painted with a VERY broad brush. But sometimes that is jus what you have to do. But we can also do something like we did above in a container.

By default, docker starts a container with a subset of capabilities turned on. This is documented at [https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities](https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities). CAP_NET_BIND_SERVICE is already in that list. That is why containers can open up low port numbers already. These capabilities can be dropped with the — cap-dropoption.

If you want to add an additional capability you can use the — cap-add parameter to give a container any additional capability it needs.

This is handled at run time, you may notice. So you can launch a dev version of a container and give it tons of power in a dev lab. But then launch the same container in production and give it an incredibly locked-down set of capabilities for that environment.

## Extending capabilities with OpenShift

This is all great if I am running a handful of containers on a host. But OpenShift is designed to serve multiple applications across large clusters at massive scale. We need a workflow that will let us associate these concepts with users in a multi-tenant system. We accomplish this with *Security Context Constraints (SCC)*.

SCC’s allow you to control permissions inside a kubernetes/OpenShift pod. Inside OpenShift, several SCC’s are deployed out of the box.

OpenShift default SCCs

    $ oc get scc
    NAME               PRIV      CAPS      SELINUX     RUNASUSER          FSGROUP     SUPGROUP    PRIORITY   READONLYROOTFS   VOLUMES
    anyuid             **false**     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    10         **false**            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
    hostaccess         **false**     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     **false**            [configMap downwardAPI emptyDir hostPath persistentVolumeClaim secret]
    hostmount-anyuid   **false**     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    <none>     **false**            [configMap downwardAPI emptyDir hostPath nfs persistentVolumeClaim secret]
    hostnetwork        **false**     []        MustRunAs   MustRunAsRange     MustRunAs   MustRunAs   <none>     **false**            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
    nonroot            **false**     []        MustRunAs   MustRunAsNonRoot   RunAsAny    RunAsAny    <none>     **false**            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
    privileged         **true**      []        RunAsAny    RunAsAny           RunAsAny    RunAsAny    <none>     **false**            [*]
    restricted         **false**     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     **false**            [configMap downwardAPI emptyDir persistentVolumeClaim secret]

Let’s take a deeper look at one of these SCCs.

restricted SCC details

    $ oc describe scc restricted
    Name:                                           restricted
    Priority:                                       <none>
    Access:
      Users:                                        <none>
      Groups:                                       system:authenticated
    Settings:
      Allow Privileged:                             **false**
      Default Add Capabilities:                     <none>
      Required Drop Capabilities:                   KILL,MKNOD,SYS_CHROOT,SETUID,SETGID
      Allowed Capabilities:                         <none>
      Allowed Volume Types:                         configMap,downwardAPI,emptyDir,persistentVolumeClaim,secret
      Allow Host Network:                           **false**
      Allow Host Ports:                             **false**
      Allow Host PID:                               **false**
      Allow Host IPC:                               **false**
      Read Only Root Filesystem:                    **false**
      Run As User Strategy: MustRunAsRange
        UID:                                        <none>
        UID Range Min:                              <none>
        UID Range Max:                              <none>
      SELinux Context Strategy: MustRunAs
        User:                                       <none>
        Role:                                       <none>
        Type:                                       <none>
        Level:                                      <none>
      FSGroup Strategy: MustRunAs
        Ranges:                                     <none>
      Supplemental Groups Strategy: RunAsAny
        Ranges:                                     <none>

There is a ton of great information in here. For example, the SCC a used to launch an application in OCP defines whether or not it can use any of the host namespaces. But for this topic we care about 3 lines here.

1. Default Add Capabilities — this is a list of capabilities to add to a pod by default when it is being created.

1. Required Drop Capabilities — this is a list of capabilities to drop when creating a pod.

1. Allowed Capabilities — this is a list of other capabilities that applications affected by this SCC are allowed to use.

SCCs are defined with YAML, like everything else in OpenShift.

Sample SCC definition

    kind: SecurityContextConstraints
    apiVersion: v1
    metadata:
      name: scc-admin
    allowPrivilegedContainer: **true**
    requiredDropCapabilities:
    - KILL
    - MKNOD
    - SYS_CHROOT
    runAsUser:
      **type**: RunAsAny
    seLinuxContext:
      **type**: RunAsAny
    fsGroup:
      **type**: RunAsAny
    supplementalGroups:
      **type**: RunAsAny
    users:
    - my-admin-user
    groups:
    - my-admin-group

In this example, the scc-admin SCC could create priviliged containers, but they would not have the KILL, MKNOD, and SYS_CHROOT capabilities.

## Using our new SCC

SCC’s are managed by cluster managers in OpenShift. It is not a permission that everyone has access to. But you can create service accounts that have access to one or more SCC. They can then use these SCCs to create applications with the exact security profiles they need to have.

I am not going to get into service accounts here. If you would like to dig into them, they are documented at [https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html#dev-guide-service-accounts](https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html#dev-guide-service-accounts).

## Putting it all together

There we are. That is a quick stroll through how Linux capabilities can be leveraged by containers in OpenShift.

1. Linux capabilities allow for very fine-grained access to administrative-level functions for applications.

1. Docker has a mechanism to add or remove these capabiliites when containers are created.

1. Kubernetes and OpenShift take this further with the concept of Security Context Constraints that allow for large-scale control of application clusters
