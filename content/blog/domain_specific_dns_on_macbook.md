---
title: "Domain-specific DNS on your Macbook"
date: 2019-11-11T14:54:08-05:00
draft: false
image: "/images/domain_specific_dns/floor_is_dns.jpg"
description: "Setting up your macbook to resolve domain-specific DNS servers"

categories: 
  - "Macbook"
tags:
  - DNS
  - Macbook
  - howto

# post type
type: post
---

DNS is hard. all. the. time.

I recently moved to a Macbook Pro for my primary work laptop. I keep a Fedora 31 laptop handy, and I have a decent-sized home lab to doing Linux-y things. For browsing and surfing thoughs, a Macbook is a pretty good experience.

My home lab is what caused me to have to dig this up. My home network is [Ubiquiti hardware](https://www.ui.com/), and it automatically manages my internal DNS zones and hostnames. I ❤ it. On my Linux laptop, I would quickly configure dnsmasq and be done with it.

But my work laptop automatically connects to my work VPN. Because my employer manages my configuration remotely, how can I have my home lab domain, int.jduncan.io not get pushed out to public servers for resolution where it will fail? Turns out, it’s really easy to set specific DNS resolvers for various domains.

First, check out your DNS configuration using $ scutil --dns . You’ll see a lot of different resolvers configured. In my case resolver #1 is what is handling my DNS lookups, then #2 handles the .local domain. Resolver #3 is the reverse lookup for the 169.254 [APIPA address space](https://whatis.techtarget.com/definition/Automatic-Private-IP-Addressing-APIPA), and so on. The root DNS servers for the internet are also listed.

    scutil --dns
    DNS configuration

    resolver #1
      search domain[0] : vmware.com
      search domain[1] : eng.vmware.com
      nameserver[0] : 10.84.54.30
      nameserver[1] : 10.84.54.31
      flags    : Request A records
      reach    : 0x00000002 (Reachable)
      order    : 50000

    resolver #2
      domain   : local
      options  : mdns
      timeout  : 5
      flags    : Request A records
      reach    : 0x00000000 (Not Reachable)
      order    : 300000

    resolver #3
      domain   : 254.169.in-addr.arpa
      options  : mdns
      timeout  : 5
      flags    : Request A records
      reach    : 0x00000000 (Not Reachable)
      order    : 300200

    resolver #4
      domain   : 8.e.f.ip6.arpa
      options  : mdns
      timeout  : 5
      flags    : Request A records
      reach    : 0x00000000 (Not Reachable)
      order    : 300400

To add an additional resolver to a Mac, create a directory at /etc/resolver.

    $ sudo mkdir /etc/resolver

For each domain that you want to hit a specific nameserver, create a file with the name of your desired domain and a nameserver line (or lines) in the file. For my internal domain I used the following command:

    cat 'nameserver 192.168.1.1' > /etc/resolver/int.jduncan.io

Now, when I run scutil --dns again I see my newly created resolver:

    resolver #8
      domain   : int.jduncan.io
      nameserver[0] : 192.168.1.1
      flags    : Request A records
      reach    : 0x00020002 (Reachable,Directly Reachable Address)

A quick lookup confirms that my configuration is doing what I want it to do. Another thing I discovered when looking into this is that dig and nslookup on OSX [don’t use the OS resolver configuration](https://stackoverflow.com/questions/50914268/os-x-etc-resolver-dev-isnt-working-why-not).

    $ dscacheutil -q host -a name vcenter.int.jduncan.io
    name: vcenter.int.jduncan.io
    ip_address: 192.168.10.110

And that’s it. If I want to configure forward or reverse zones to resolving using a specific nameserver on OSX it’s that simple.
