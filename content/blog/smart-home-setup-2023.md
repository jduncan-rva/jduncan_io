---
title: "Smart Home Setup 2023"
date: 2022-12-28T13:57:13-05:00
draft: false
image: "/images/smart-home-setup-2023/cover.jpeg"
summary: "A tour of current state and future plans for our Smart Home setup."

categories: 
  - smart home
tags:
  - smart home
  - home automation
  - home assistant
  - home networking
  - ubiquiti
  - plex media server

# post type
# don't have more than 3 "featured" posts at any given time, and ideally keep 3 going for symmetry"
# options 
# - post: normal blog post
# - featured: featured blog post 
type: post
---

As I dive into 2023, a focus for my home is to really tighten up my smart home configuration. I spent a little time this fall working on some broad strokes to set up for a really fun 2023 to make our house lots of fun to live in. Here's a summary of what I'm currently running.

### Home Media 

I've run a [Plex Media Server](https://www.plex.tv/) for a long time. To back up Plex, I've also run [Radarr](https://radarr.video/) to track movies, [Sonarr](https://sonarr.tv/) to track TV shows, and [SABnzbd](https://sabnzbd.org/) to access Usenet content. This all runs on a couple of [old HP 800 SFF desktops](https://www.amazon.com/gp/product/B084VXHXJ9/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1). Plex runs as a dedicated service on one system, and the other services run in containers on the second system. This was built out in the early days of CentOS 7, and they were having intermittent issues with disk space and random annoyances. So I laid down a fresh install of [Ubuntu 22.04](https://releases.ubuntu.com/22.04/) to get everything running smoothly again.

The actual storage is housed on a [Synology 918+](https://www.storagereview.com/review/synology-diskstation-ds918-review) running 4x 4TB WD Red disks for 12TB of usable space. Other than a backup location for digital family files, this is the primary purpose for the Synology.

* Current Status - This runs nice and clean and easy and the Plex server can handle multiple concurrent 1080p streams.
* Planned Improvements - The processor on the Plex server can't transcode 4k streams and keep up. I may end up upgrading that system later this year. If so, that would be the biggest upgrade to this part of the smart home.

### Family Document Storage

For family documents that we need to digitize and retain, we have a [Fujitsu ScanSnap ix1500](https://www.amazon.com/gp/product/B086GBVC26/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1). This thing is amazing. It can scan at ridiculous speeds, and generate a searchable PDF automatically. 

For storage, files are dropped on to our Synology NAS. On the NAS, we have [Cloud Sync](https://www.synology.com/en-us/dsm/feature/cloud_sync) set up with bi-directional syncs to Google Drive and Dropbox. Any a file hits specific folders in any of those locations, it's automatically synced to all locations. 

I took a few days last year and digitized all of our important files. This set up gives us digital copies of all of those files in 3 different locations. 

* Current Status - Fast and easy, if a little manual. Things can back up in the "to be scanned" pile if I'm not diligent. And I'm rarely diligent.
* Planned Improvements - Something has to be possible with Home Assistant, but I'm not sure what just yet. 

### Family Calendar

We have a large computer monitor at a conpicuous place in our kitchen running [Dakboard](https://dakboard.com/site). We have it tied into multiple Google calendars, Google Photos, and local weather. It's incredibly useful. It's powered by a Raspberry Pi running Dakboard's Raspbian variant. 

* Current Status - Easy and essential to our household.
* Planned Improvements - Can't really think of anything. Possibly some automation improvements via Google Calendar, but it's a pretty solid solution as-is.

### Home Networking

Several years ago, I converted our entire house over to [UniFi by Ubiquiti](https://www.ui.com/consoles). The company has gotten some bad press lately, and I'm not sure if it's deserved or not. I haven't really looked into it. But the hardware is rock solid. Outside of one upgrade snafu with a switch, my experience has been phenomanal. 

This conversion required running network cables through the walls of a house built in the mid-90s. That wasn't the most fun. But we got it done.

Our AT&T U-Verse was (begrudgingly) brought into our living room. So the Unifi gateway, router, and a small PoE switch are all there. There is an AC-Pro access point on each level of the house, a larger switch in my office, and a mesh wifi extender in the backyard to get signal up to my workshop.

{{< figure 
width="900" height="500"
class="figure"
alt="My Unifi home network devices. a gateway, a router, 3 switches, and 4 access points"
src="/images/smart-home-setup-2023/unifi-screenshot.png"
caption="My Unifi home network devices. a gateway, a router, 3 switches, and 4 access points"
>}}

* Current Status - Rock solid
* Planned Improvements - It would be nice to have PoE access points on the outside of the house. But I don't think I'm ready to take that work on any time soon.

### Home Security

Our home security situation is still a bit of a hodge-podge. For the same reasons we don't have PoE access points outside, we don't have hard-wired security cameras outside. Instead, we run a handful of [Bink cameras](https://blinkforhome.com/products). They take pretty good pictures, have good motion detection, and the batteries last apparently forever. 

Our actual alarm system is form [Abode](https://goabode.com/). It's a DIY system that took me about 2 hours to set up about 4 years ago. Outside of a few battery replacements, the system has been amazingly reliable. Abode uses [Z-Wave](https://www.z-wave.com/) to connect all of its sensors, so we're also able to integrate smart smoke detectors, a few light switches, and the front door lock. 

Abode has the ability to hook into Google Assistant and Alexa, optional professional monitoring, as well as geo-fencing. The primary alarm box also has an integrated battery backup and LTE modem. In short, it's everything we need from an alarm system.

* Current Status - Rock Solid
* Planned Improvements - None really planned.

### Home Automation

This is where I've made the biggest recent changes. For years, we've used a mix-and-match collection of Alexa routines, IFTTT triggers, Abode automations, and 3 or 4 other things that I can't hink of right now. It was a mess, and it was brittle and hard to keep synchronized. Soon after buying this house, we also added [Ecoboee thermostats](https://www.ecobee.com/) to the mix.

Oh yeah, and we have a Chamberlain MyQ garage door opener that we inherited with the house.

And an [Ambient Weasther weatherstation](https://ambientweather.net/dashboard/876660bf232d88c2511835988a739eaa) and that's pretty much all of the sensors and antennae that our house is currently generating.

Over Thanksgiving this year, I fell into the abyss known as [Home Assistant](https://www.home-assistant.io/). By Christmas, my wife was mostly speaking to me again. So I'll call the learning curve to get comfortbale with that technology at 2-3 weeks. 

But OMG what it can't do.

Home Assistant takes pretty much everything I just listed in the above paragraphs and gives me all of the power that all of them can provide in a single automatable platform. It's quite simply amazing. A few examples: 

* I can read the current light conditions from my backyard weather station and use that to decide whether or not to turn on lights on our basement steps when motion is detected by a small motion sensor.
* Our front porch lights come on 30 minutes prior to sunset each day and turn off at 10pm.
* We have an ... adventurous ... 6 year old. If the garage door or back door is opened between 5:30am and 7:30am an announcement is made on the Echo in our bedroom just in case some adventures are happening.

Home Assistant has a container-based OS distribution for multiple platforms. I've deployed it on to a Raspberry Pi 4 and added a Zigbee controller USB dongle. I had a Z-Wave USB dongle as well, but I had some issues with that controller and the Z-Wave controller built into our Abode alarm. So for any items controlled directly by Home Assistent, I'm using a [SONOFF Zigbee 3.0 USB Dongle](https://www.amazon.com/gp/product/B0B6P22YJC/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1). I've added the following (approximately) to my home automation footprint so far: 

* 20 Sengled Zigbee lightbulbs (both warm white and RGB)
* 4 Thirdreality Zigbee motion sensors
* 10 Sonoff Zigbee plugs
* 2 Innr Zigbee flood lights
* 1 Kwikset Convert Zigbee deadbolt

Home Assistant uses YAML to define automations, and has a _very_ mature web UI that handles all but the most complex automations. Additionally, it integrates seamlessly with the other cloud-based platforms I'm already using, has an SSL-protected way to access and control it remotely, and is all-around amazing. 

{{< figure 
width="900" height="500"
class="figure"
alt="The Home Assistant Default dashboard showing all information available"
src="/images/smart-home-setup-2023/home-assistant.png"
caption="The Home Assistant Default dashboard showing all information available"
>}}

Additionally, the Home Assistant community is incredibly active. So blockers are easily solved and ideas are easily found.

* Current Status: Learning Curve pretty much caught up and growing by leaps and bounds
* Biggest Lessons: Zigbee runs on 2.4GHz, so interference with Wifi is a real thing and has to be accounted for. 
* Planned Improvements: This is under very active development in 2023, and a primary focus.

### Conclusions

Applying technology to solve problems around our home has been a fun hobby for a long time. Rounding the corner into Home Assistant really empowers me to taket that to the next level. I'm really looking forward to it, even if my wife is occassionally frustrated. :) 



