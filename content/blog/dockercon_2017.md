---
title: "Docker, Inc. and Operations — thoughts from DockerCon 2017"
date: 2017-05-17T11:16:10-05:00
draft: false
image: "/images/dockercon_2017/docker_dead.jpg"

categories: 
  - Containers
tags:
  - docker
  - dockercon
  - rant
  - ops

# post type
type: post
---

I didn’t go to Dockercon this year

I had some customer events and couldn’t make it work. Talking with some co-workers who did go, I had my folding money bet on Docker making an announcement during their Day 1 keynotes about moving their efforts into the Kubernetes world. It made sense to me. I’m glad nobody would take my bet. Instead they doubled down on their own stack. But they did have announcements to make

I watched their day 1 keynote demo about some of these new technologies and took some notes. This is the video below. It’s interesting in a lot of ways.

{{< youtube iHQCVFMBdCA >}}

## tl:dr;

InfraKit is yet-another-attempt-at-vendor-lock.

LinuxKit is far and away not more secure than the established solutions out there. But it does have some good ideas inside it.

If a company were using LinuxKit build servers that held my personal data, I would terminate my relationship with that company as soon as I found out.

## Infrakit

[InfraKit](https://github.com/docker/infrakit) is a collection of tools to build out virtual machines in a few formats. According to Github it works with the following infrastructure tools:

From the repo README.md, a list of the current plugins:

    infrakit: a command line interface to interact with plugins
    infrakit-group-default: the default Group plugin
    infrakit-instance-file: an Instance plugin using dummy files to represent instances
    infrakit-instance-terraform: an Instance plugin integrating Terraform
    infrakit-instance-vagrant: an Instance plugin using Vagrant
    infrakit-instance-maas: an Instance plugin using MaaS
    infrakit-flavor-vanilla: a Flavor plugin for plain vanilla set up with user data and labels
    infrakit-flavor-zookeeper: a Flavor plugin for Apache ZooKeeper ensemble members
    infrakit-flavor-swarm: a Flavor plugin for Docker in Swarm mode.

I have worked with hundreds of customers across the entire world of enterprise technology. I have never worked with one who hinged their production data on the above tools.

## Platform Agnostic

OK. Awesome. So is any modern tool that manages infrastructure. But unlike tools like [Ansible](https://www.ansible.com/), it ONLY works with Docker, Inc. tools. This is simply an attempt at vendor lock.

## Reverse uptime

In the video they talk for several minutes about how patching is awful and instead of doing that you should just set a timer on your servers to have them automatically redeploy based on the latest image.

I don’t even know where to start with the [Rube Goldberg-iness](https://en.wikipedia.org/wiki/Rube_Goldberg) of this. First off, patching isn’t hard. It hasn’t been for many years now for any competent Operations professional managing any sane environment.

But instead of incorporating with tools like [Ansible](https://www.ansible.com/) that make this easy, effective, automated, and efficient, you build your own thing that is adding mountains of un-needed complexity to your environment.

Patching is too hard, so you will re-image systems all the time instead? Seriously? Really?

## Initial thoughts

Intentionally introducing points of failure into your environment (re-imaging servers) to solve problems that almost never require it (patching / threat mitigation) is not a principle that is sustainable or sane in systems that have true SLAs and uptime requirements. The idea is neat. In practice, it is immature and incredibly high-risk for very little reward. If you want to have systems that are consistently patched and safe, have a good Ops team. You cannot script them away.

This tools is designed for small labs and developer’s laptops. It is geared at startups, not enterprise IT departments. The Docker people on stage told everyone to not worry, that they had been using this (and other tools on this list) in production for several months now.

What does “in production” mean at Docker, Inc.? Can you back that up with data about the size and scope of your environment?

## LinuxKit

The most secure OS builder for your containers.

*DockerCon 2017 keynote*
 — Riyaz Faizullabhoy — Security Engineer

[LinuxKit](https://github.com/linuxkit/linuxkit) was one of their big new announcements. This is the one that really got my attention. Docker has come up with a new way to build Linux. This is interesting. Maybe?

Docker is claiming that their Linux distro is the most secure thing out there now. They say it’s because, hell, I never really could figure out what they were saying here. But they did mention a few projects that they are pulling into their projects. Do these make it more secure?

Once you get through the marketing, LinuxKit is a build system for a Linux distributions. Docker supplies the kernel, and you take this framework and add in whatever you want in the userspace. Libraries, vim, emacs (eew!), whatever.

If you look at the kernel setup scripts in their [GitHub repo](https://github.com/linuxkit/linuxkit/tree/master/scripts/kernels), they are supporting 5 kernels; CentOS, Debian, Fedora, Ubuntu, and their *mainline* kernel that I’m assuming is from Alpine Linux.

A startup with ~330 employees, most of them sales, is going to take 5 different Linux distributions, modify them to make them the “most secure”, and then make them stable enough so they are production-ready.

Red Hat has effectively 2 active Linux distributions right now, RHEL 6 and 7. RHEL 5 is closing in on it’s end-of-life, so I’m not counting it. We have, literally, 1000’s of engineers.

And what about these changes they are making?

Per the presentation, LinuxKit provides “secure and modernly configured kernels”. They claim to be configuring their kernels with recommendations from the [Kernel Self Proection Project (KSPP)](https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project). I am not an everyday security expert, so I looked to some of my colleagues to help steer me to solid information around KSPP. Many thanks to [Scott McCarty](https://www.twitter.com/fatherlinux), [Matt Micene](https://www.twitter.com/cleverbeard), and Eric Paris for helping gather up some information.

KSPP is largely an attempt to get changes may by [PaX Team and grsecurity](https://www.grsecurity.net/) into the mainline kernel. The traditional knowledge from kernel experts is that the grsecurity hardening features come with very measurable performance tradeoffs. Most decisions inside the Linux kernel live on the “performance vs. security” spectrum, so that’s not surprising.

There is also a lot of personality and politics revolving around gsecurity. Oddly, if you look at a (VERY) recent [kernel hardening mailing list](http://openwall.com/lists/kernel-hardening/2017/06/03/14) thread, the head of gsecurity (Brad Spengler) is accusing the KSPP of plagarism and tossing around legal action as a recourse.

From a technical perspective, a lot of these changes have NOT made it into the mainline Linux kernel. So users of LinuxKit are relying on Docker, Inc. to ensure they are fully vetted and tested and work properly for 5 different Linux distributions. Possible? maybe. Probable? not remotely.

From a project perspective, the KSPP looks a little toxic (?).

A great idea. But tell me, what IS a Windows container? How is it isolating things inside the kernel? I know that developers don’t think this matters. But it starts to matter as soon as something starts to act randomly weird. That’s why Operations teams exist. Depth of knowledge of how something works is a good thing. That cannot exist in a closed-source kernel.

If you go this route you are expecting Microsoft and Docker to be able to fully test, vet, and support your Linux platform.

Yeah, I’m just ranting here. I don’t like the idea of closed source kernels.

[SECCOMP](https://en.wikipedia.org/wiki/Seccomp) (SECure COMPuting mode) has been around since 2005. All Linux kernels can leverage it. It is a universal security utility in Linux. The [person who invented it](https://www.linkedin.com/in/andrea0arcangeli/) also works at Red Hat.

[Landlock](https://landlock-lsm.github.io/linux-doc/landlock-v5/security/landlock/index.html) is a stackable security module for the Linux.

Landlock is a stackable Linux Security Module (LSM) that makes it possible to create security sandboxes. This kind of sandbox is expected to help mitigate the security impact of bugs or unexpected/malicious behaviors in user-space applications. The current version allows only a process with the global CAP_SYS_ADMIN capability to create such sandboxes but the ultimate goal of Landlock is to empower any process, including unprivileged ones, to securely restrict themselves. Landlock is inspired by seccomp-bpf but instead of filtering syscalls and their raw arguments, a Landlock rule can inspect the use of kernel objects like files and hence make a decision according to the kernel semantic.

*Landlock website*
 — [https://landlock-lsm.github.io/linux-doc/landlock-v5/security/landlock/index.html](https://landlock-lsm.github.io/linux-doc/landlock-v5/security/landlock/index.html)

From my understanding, it is essentially an abstraction layer on top of SECCOMP.

Landlock is described as differing from SELinux, AppArmor, Smack, and other security modules in that it’s not only dedicated to administrators, there is a more limited kernel attack surface, and has other design differences in particularly focusing upon unprivileged processes.

*Phoronix article on Landlock*
 — [http://www.phoronix.com/scan.php?page=news_item&px=Landlock-LSM-V3](http://www.phoronix.com/scan.php?page=news_item&px=Landlock-LSM-V3)

As of August 2016, it was [called a proof of concept](https://lwn.net/Articles/698226/) by its authors.

Is this code ready for production workloads?

Wireguard is really cool. It is an in-kernel VPN tunnel. It is a very fast-moving and quickly maturing project.

WireGuard is not yet complete. You should not rely on this code. It has not undergone proper degrees of security auditing and the protocol is still subject to change. We’re working toward a stable 1.0 release, but that time has not yet come.

*Wireguard website*
 — [https://www.wireguard.io/#work-in-progress](https://www.wireguard.io/#work-in-progress)

Again, is this production-ready?

I know what [Type Safety](https://en.wikipedia.org/wiki/Type_safety) is, but I am not sure what they are talking about here. Are there specific projects they are using? Or did they just hire the best developers? I’m not sure.

These are base components for all OCI-compliant container runtimes. Sorry. No additional security here.

Docker quite simply does not know more about SELinux than, say, the engineering team at Red Hat that maintains it.

*Originally published at [blog.jeduncan.com](http://blog.jeduncan.com/docker_operations_platform.html) on May 17, 2017.*
