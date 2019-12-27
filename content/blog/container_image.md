---
title: "Dissecting a docker container image"
date: 2017-02-16T11:27:42-05:00
draft: false
image: "/images/container_image/cake_fail.jpg"

categories: 
  - Containers
tags:
  - containers
  - images
  - docker
  - cri
  - nsenter

# post type
type: post
---

The Docker container format is revolutionizing the IT world

That statement can be backed up by a lot of facts. Every IT pro who uses or has investigated docker knows a few things about docker container images.

* They are somehow reminiscent of a layer cake
* They hold exactly what the application needs to run

Some of them know that tar is involved somewhere along the line as well. But let’s take a little deeper look at the layers of an active docker image.

## Image overview

The image I’ve decided to work with is [https://hub.docker.com/r/jeduncan/php-demo-app/](https://hub.docker.com/r/jeduncan/php-demo-app/). It is a simple PHP application that I use for demos all the time. It is based on the CentOS base image, and was created using [s2i](https://github.com/openshift/source-to-image).

Looking for my image in my local docker cache

    $ sudo docker images
    REPOSITORY                             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    ...
    docker.io/jeduncan/php-demo-app        latest              e0d8f7356c86        8 months ago        529.3 MB
    ...

Taking a look at the docker history of my container. Make a note of the layer names. Also take note of how many of the layers are 0 bytes

    $ sudo docker history docker.io/jeduncan/php-demo-app
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    e0d8f7356c86        8 months ago        /bin/sh -c tar -C /tmp -xf - && /usr/libexec/   13.22 MB
    d809d5f307cd        8 months ago        /bin/sh -c *#(nop) LABEL io.openshift.builder-   0 B*
    18af1578ecc7        8 months ago        /bin/sh -c *#(nop) CMD ["/bin/sh" "-c" "$STI_S   0 B*
    70ef03009bf2        8 months ago        /bin/sh -c *#(nop) USER [1001]                   0 B*
    d65cdc6d01c2        8 months ago        /bin/sh -c sed -i -f /opt/app-root/etc/httpdc   173 kB
    06114003ac47        8 months ago        /bin/sh -c *#(nop) COPY dir:7850e5725084799696   73.95 kB*
    061f1be2c737        8 months ago        /bin/sh -c *#(nop) COPY dir:c1d195bef873c9d12f   3.209 kB*
    805ee3fa596c        8 months ago        /bin/sh -c yum install -y centos-release-scl    131.4 MB
    5910419c705f        8 months ago        /bin/sh -c *#(nop) LABEL io.k8s.description=Pl   0 B*
    ae896b2c439a        8 months ago        /bin/sh -c *#(nop) ENV PHP_VERSION=5.5 PATH=/o   0 B*
    10b4afa48bf4        8 months ago        /bin/sh -c *#(nop) EXPOSE 8080/tcp               0 B*
    81fde05ca6a7        8 months ago        /bin/sh -c *#(nop) MAINTAINER SoftwareCollecti   0 B*
    7b0019cd981d        8 months ago        /bin/sh -c *#(nop) LABEL io.openshift.builder-   0 B*
    994a26d6ed0b        8 months ago        /bin/sh -c *#(nop) CMD ["base-usage"]            0 B*
    30c4fb7a775b        8 months ago        /bin/sh -c *#(nop) ENTRYPOINT &{["container-en   0 B*
    8615016dd586        8 months ago        /bin/sh -c *#(nop) WORKDIR /opt/app-root/src     0 B*
    138168ea415d        8 months ago        /bin/sh -c *#(nop) COPY dir:152d394e9a3f4adc23   3.847 kB*
    00de5600e485        8 months ago        /bin/sh -c rpmkeys --import file:///etc/pki/r   187.7 MB
    8739e2b28f51        8 months ago        /bin/sh -c *#(nop) ENV BASH_ENV=/opt/app-root/   0 B*
    05a5ce9abf41        8 months ago        /bin/sh -c *#(nop) COPY file:92abfe3dd1d63ab45   81 B*
    7590566fabb0        8 months ago        /bin/sh -c *#(nop) ENV STI_SCRIPTS_URL=image:/   0 B*
    deea4e12ec1b        8 months ago        /bin/sh -c *#(nop) LABEL io.openshift.s2i.scri   0 B*
    5f6cac4b09ab        8 months ago        /bin/sh -c *#(nop) MAINTAINER Jakub Hadvig <jh   0 B*
    7aca3d3bbd4d        9 months ago        /bin/sh -c *#(nop) CMD ["/bin/bash"]             0 B*
    9ebea32a283d        9 months ago        /bin/sh -c *#(nop) LABEL name=CentOS Base Imag   0 B*
    0dd747e33c96        9 months ago        /bin/sh -c *#(nop) ADD file:deb8ef25b4d805246a   196.7 MB*
    3690474eb5b4        17 months ago       /bin/sh -c *#(nop) MAINTAINER The CentOS Proje   0 B*

## Getting the image out of the docker cache

Exporting my image using docker save

    $ sudo docker save e0d8f7356c86 > php-demo-app.tar
    $ sudo ls -al -h php-demo-app.tar
    -rw-r--r--. 1 root root 521M Feb 15 20:40 php-demo-app.tar

Using docker save <image> will export a container image. Using docker export <container> will export a running container instance.

At this point we have our image exported to a tarball. Yes, all a docker container image is is a tarball. A little more accurately, it is a tarball of tarballs. But we will get there in a few minutes.

Extracting our tarball image

    $ sudo tar -xf php-demo-app.tar -C image/
    $ sudo cd image/
    $ sudo ll
    total 108
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 00de5600e4850ec67759313b8bf4d1f59507eeb2ec063ab7e303a08405a4be1b
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 05a5ce9abf413adc9173aa19c58cbca8649c5298de340c2a6305b81e6056db6a
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 06114003ac4783ccbe13a7f2b26a4de8ac3683370abe1e3cf8eb726f7473e841
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 061f1be2c73733a5349dcdf4d4bf419396674084aefe5e75425504497097ec7b
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 0dd747e33c966ae31e2a44bc9ef80d6e69edefb88461878ee650583f9bce5c41
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 10b4afa48bf4007a3671865c83481ab12c8d632ee9ec8412031f84261a8c0d81
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 138168ea415d93012e7dcfbcfc70d3420969e945304661b35041aed20d4ff52c
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 18af1578ecc7992ced8e68b2c4c73378095c31894c50e7420b06af2ff764d4b7
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 30c4fb7a775b28e3f221372c610436ae3cde7950f13f13304abbdfc19bea5007
    drwxr-xr-x. 2 root root 4096 Feb 15 20:40 3690474eb5b4b26fdfbd89c6e159e8cc376ca76ef48032a30fa6aafd56337880
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 5910419c705f4ea196fa35e840c4c199a1f8a41321ea0e1858bc85a4d9dbf8ff
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 5f6cac4b09ab9026455fe34f77ebd90a5f4f32535a41784b4aba64d88791f8bb
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 70ef03009bf2664d0b8235dee96e57457bd222bb184271957dce6a2aaa94e82b
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 7590566fabb0f37fcaa7ccdb2fa1906157df21ceb8878fe3792274e612c96135
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 7aca3d3bbd4d7d97724ed643027f840699dd9f67847a1e9d7a6452d731f2e434
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 7b0019cd981d72cd4b90e99f1d232dacea3fa0d10923cd342904c3f4b1b9d089
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 805ee3fa596c6943f390a7c24ef5c585b139089b9d05847744df5780c4192246
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 81fde05ca6a772bcd79b035a090235531a92e0de1e17bb25a08ff0f02c84112f
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 8615016dd58691d197f06c76590dc31a45c8a6017516b24a0a0387f2d460c138
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 8739e2b28f513204fc5194518094870eda866c1fee65a3e0b3a2f46a258091dd
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 994a26d6ed0b590153dce7f50f4bfac0404ebe908a42a75b662b4212c8ac1f76
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 9ebea32a283d19b08ba1fdd8a6fc257aebfba190a94a2161461153182df88ae6
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 ae896b2c439a54e4087caa368ef62ecbd55187fd970099a6175825a59a9fe531
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 d65cdc6d01c20f9096c56c2ea01fe0819a2dc872a622e25f49a948c7af211d2b
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 d809d5f307cdc826fb558ea24e8d2f244a9d023b83d92f60a22bc73b834140be
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 deea4e12ec1b9e64133fa9bcbf0936726bb1061160386251716306ed7aef6613
    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 e0d8f7356c86225627f1dcc1747e643004ba180ad22712a46052d7e52e6cc595

OK. so we have 26 directories inside our tarball. Oddly enough we also have 26 layers in our image.

Also, the directory names seem to coincide with the layer names.

    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 00de5600e4850ec67759313b8bf4d1f59507eeb2ec063ab7e303a08405a4be1b
    00de5600e485        8 months ago        /bin/sh -c rpmkeys --import file:///etc/pki/r   187.7 MB

    drwxr-xr-x. 2 root root 4096 Feb 15 20:39 d809d5f307cdc826fb558ea24e8d2f244a9d023b83d92f60a22bc73b834140be
    d809d5f307cd        8 months ago        /bin/sh -c *#(nop) LABEL io.openshift.builder-   0 B*

*Coincidence? I THINK NOT.*

So what is inside each of these directories? Let’s take a look at the top layer, e0d8f7356c86

    $ sudo cd e0d8f7356c86225627f1dcc1747e643004ba180ad22712a46052d7e52e6cc595/
    $ sudo cat VERSION
    1.0
    $ sudo ls -al -h layer.tar
    -rw-r--r--. 1 root root 13M Feb 15 20:39 layer.tar

So we can see here we are using Version 1.0 of *something*, and we can see that the size of layer.tar is the same as the size of that image layer.

It turns out that VERSION tells docker what the schema version of the json file. So let’s take a deeper look at that.

## The layer json file

Each layer of a docker image contains a json file called, aptly enough, json. It turns out this provides a huge amount of information about each layer.

    $ sudo cat json | python -m json.tool
    {
        "Size": 13216151,
        "architecture": "amd64",
        "config": {
            "AttachStderr": **false**,
            "AttachStdin": **false**,
            "AttachStdout": **false**,
            "Cmd": [
                "/usr/libexec/s2i/run"
            ],
            "Domainname": "",
            "Entrypoint": [
                "container-entrypoint"
            ],
            "Env": [
                "PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/rh/php55/root/usr/bin",
                "STI_SCRIPTS_URL=image:///usr/libexec/s2i",
                "STI_SCRIPTS_PATH=/usr/libexec/s2i",
                "HOME=/opt/app-root/src",
                "BASH_ENV=/opt/app-root/etc/scl_enable",
                "ENV=/opt/app-root/etc/scl_enable",
                "PROMPT_COMMAND=. /opt/app-root/etc/scl_enable",
                "PHP_VERSION=5.5"
            ],
            "ExposedPorts": {
                "8080/tcp": {}
            },
            "Hostname": "",
            "Image": "",
            "Labels": {
                "build-date": "2016-05-16",
                "io.k8s.description": "Platform for building and running PHP 5.5 applications",
                "io.k8s.display-name": "[docker.io/jeduncan/php-demo-app-form](http://docker.io/jeduncan/php-demo-app-form)",
                "io.openshift.builder-base-version": "6158a36",
                "io.openshift.builder-version": "c92700d33afbe3891302ff9efcbdaa00f618bf76",
                "io.openshift.expose-services": "8080:http",
                "io.openshift.s2i.build.commit.author": "Jamie Duncan <jduncan@redhat.com>",
                "io.openshift.s2i.build.commit.date": "Mon Jun 20 10:52:36 2016 -0400",
                "io.openshift.s2i.build.commit.id": "67c651c0e00da74b61ad2a73cf42b01d889fdced",
                "io.openshift.s2i.build.commit.message": "fixing typos",
                "io.openshift.s2i.build.commit.ref": "master",
                "io.openshift.s2i.build.image": "[docker.io/openshift/php-55-centos7](http://docker.io/openshift/php-55-centos7)",
                "io.openshift.s2i.build.source-location": "file:///home/jduncan/Code/php-demo-form",
                "io.openshift.s2i.scripts-url": "image:///usr/libexec/s2i",
                "io.openshift.tags": "builder,php,php55",
                "io.s2i.scripts-url": "image:///usr/libexec/s2i",
                "license": "GPLv2",
                "name": "CentOS Base Image",
                "vendor": "CentOS"
            },
            "MacAddress": "",
            "NetworkDisabled": **false**,
            "OnBuild": null,
            "OpenStdin": **false**,
            "PublishService": "",
            "StdinOnce": **false**,
            "Tty": **false**,
            "User": "1001",
            "VolumeDriver": "",
            "Volumes": null,
            "WorkingDir": "/opt/app-root/src"
        },
        "container": "d4f7c5dee0df9a455ff722be9cab1e4a016c9f513d8e60f216a1d5b25e8f1991",
        "container_config": {
            "AttachStderr": **false**,
            "AttachStdin": **false**,
            "AttachStdout": **true**,
            "Cmd": [
                "/bin/sh",
                "-c",
                "tar -C /tmp -xf - && /usr/libexec/s2i/assemble"
            ],
            "Domainname": "",
            "Entrypoint": [
                "container-entrypoint"
            ],
            "Env": [
                "PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/rh/php55/root/usr/bin",
                "STI_SCRIPTS_URL=image:///usr/libexec/s2i",
                "STI_SCRIPTS_PATH=/usr/libexec/s2i",
                "HOME=/opt/app-root/src",
                "BASH_ENV=/opt/app-root/etc/scl_enable",
                "ENV=/opt/app-root/etc/scl_enable",
                "PROMPT_COMMAND=. /opt/app-root/etc/scl_enable",
                "PHP_VERSION=5.5"
            ],
            "ExposedPorts": {
                "8080/tcp": {}
            },
            "Hostname": "d4f7c5dee0df",
            "Image": "[docker.io/openshift/php-55-centos7:latest](http://docker.io/openshift/php-55-centos7:latest)",
            "Labels": null,
            "MacAddress": "",
            "NetworkDisabled": **false**,
            "OnBuild": null,
            "OpenStdin": **true**,
            "PublishService": "",
            "StdinOnce": **true**,
            "Tty": **false**,
            "User": "1001",
            "VolumeDriver": "",
            "Volumes": null,
            "WorkingDir": "/opt/app-root/src"
        },
        "created": "2016-06-20T14:53:14.904907708Z",
        "docker_version": "1.8.2.fc21",
        "id": "e0d8f7356c86225627f1dcc1747e643004ba180ad22712a46052d7e52e6cc595",
        "os": "linux",
        "parent": "d809d5f307cdc826fb558ea24e8d2f244a9d023b83d92f60a22bc73b834140be"
    }

There is a TON of information in here. We can see all of the labels associated with the image, and this layer in particular. The full spec is documented at [https://github.com/docker/docker/blob/master/image/spec/v1.md](https://github.com/docker/docker/blob/master/image/spec/v1.md).

### A few key values (pun intended) from inside this image json file

* **parent** — This is the ID of the parent image; the next lowest layer in the layer cake. If this value isn’t present, then it is the lowest layer in the cake.

    $ sudo cd 3690474eb5b4b26fdfbd89c6e159e8cc376ca76ef48032a30fa6aafd56337880/ $ sudo cat json | python -m json.tool | grep parent *#*

* **Cmd** — this is the command that was run to create the container for this layer

* **id** — this is the uuid for this image layer, and should match the directory the json file exists in

There are a bunch of other values like exposed ports, docker version, and all sorts of things that you may have wondered how docker tracked when you created a container. Well, it’s all right here in this json. It starts with the base layer, and then keeps building and changing through each layer.

## The layer tarball

Next lets take a look at what is inside the tarball itself. To keep things simple, let’s take a look at a small layer, but not a 0 byte one.

d65cdc6d01c2 8 months ago /bin/sh -c sed -i -f /opt/app-root/etc/httpdc 173 kB

This layer added 173kB to our container image. So what all did it do?

    $ sudo cd ../d65cdc6d01c20f9096c56c2ea01fe0819a2dc872a622e25f49a948c7af211d2b/
    $ sudo mkdir tarfiles
    $ sudo tar -xf layer.tar -C tarfiles
    $ sudo cd tarfiles
    $ sudo ll
    total 260
    drwxr-xr-x. 4 root root   4096 Jun  1  2016 opt
    drwxrwxrwt. 3 root root   4096 Jun  1  2016 tmp

We have 2 directories. /opt and /tmp. OK…

    $ sudo ls -al opt/
    total 8
    drwxrwxr-x. 4 jack root 4096 Jun  1  2016 app-root
    drwxr-xr-x. 4 root root 4096 Jun  1  2016 rh
    $ sudo ls -al opt/app-root/
    etc/ src/
    $ sudo ls -al opt/app-root/etc/
    conf.d/           httpdconf.sed     php.d/            php.ini.template  scl_enable

So we have a handful of files. What command did we run to need these?

    $ sudo cat json | python -m json.tool | grep -A 1 Cmd
            "Cmd": [
                "/bin/sh -c sed -i -f /opt/app-root/etc/httpdconf.sed /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf &&     sed -i '/php_value session.save_path/d' /opt/rh/httpd24/root/etc/httpd/conf.d/php55-php.conf &&     echo \"IncludeOptional /opt/app-root/etc/conf.d/*.conf\" >> /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf &&     head -n151 /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf | tail -n1 | grep \"AllowOverride All\" || exit &&     mkdir /tmp/sessions &&     chown -R 1001:0 /opt/app-root /tmp/sessions &&     chmod -R a+rwx /tmp/sessions &&     chmod -R ug+rwx /opt/app-root &&     chmod -R a+rwx /opt/rh/php55/root/etc &&     chmod -R a+rwx /opt/rh/httpd24/root/var/run/httpd"

OH. So we took a bunch of files from our parent container image and ran some sed commands on them. We also created /tmp/sessions and altered a few permissions on files.

Anything that this command touched or changed was added to this tarball by docker.

That is exactly all that docker does to create a layer in a container image.

## Putting it all together

This is everything we need to have a practical understanding of how Docker creates and tracks container images.

### Overview of Docker image creation

1. Start with a base image. In our case the CentOS 7 base image.
1. Creates a container with this image.
1. Execute the next command in the Dockerfile or automated process.
1. Capture the files changed from this command. This is called the changeset.
1. Track a ton of metadata around what happened in this image. Including giving it a new UUID, the UUID of the container used to run the command (the parent), tracking labels and environment variables, the command that was run, information about the environment, etc.
1. Capture the changeset in a tarball called layer.tar
1. Capture the metadata in a file called json
1. Create a file called VERSION that indicates the version of json schema that was used
1. Put all of these artifacts in a directory named after the UUID
1. Repeat this process for each command that needs to be run
1. Tar all of this up into a single tarball
1. Push your new image into an image registry
1. Profit

### Next Steps

As long as you are compliant with this schema and format, then you can build container images with any toolset that you like. No unicorn blood or voodoo curses required!

*Originally published at [blog.jeduncan.com](http://blog.jeduncan.com/docker-image-dissection.html) on February 16, 2017.*
