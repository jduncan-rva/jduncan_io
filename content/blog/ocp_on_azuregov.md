---
title: "OpenShift 3.11 on Azure Government"
date: 2019-05-07T10:35:35-05:00
draft: false
image: "/images/ocp_azuregov/capitol_graphic.jpg"

categories: 
  - Cloud
tags:
  - howto
  - Azure
  - AzureGov
  - OpenShift
  - Video

# post type
type: post
---

Note: This post goes hand in hand with the Red Hat Summit breakout session I’m doing on May 9 at 1 pm.

The 2019 edition of [Red Hat Summit](https://www.redhat.com/en/summit/2019) is all about [OpenShift](https://www.openshift.com). OpenShift 4.0, [Operators](https://github.com/operator-framework), new [container-based storage](https://github.com/rook/rook/blob/master/ROADMAP.md). All sorts of massive improvements for what I think is the best option in the industry to manage your applications for the next 5–7 years.

Our session (with [Chris Green](https://github.com/greencee) from the Microsoft Azure Government team) is about how to successfully deploy a production-grade instance of OpenShift in the Azure Government regions.

To accomplish this quickly we used the self-managed OpenShift template from the Azure Gov marketplace. It defaults to an HA control plane, HA infrastructure nodes, *N* application nodes, and adding logging, metrics, container-based storage, and even the Azure cloud provider are essentially point and click. The entire process takes approximately 90 minutes. At a high level, it looks like this:

{{< figure 
width="720" height="370"
class="figure"
alt="OpenShift on Azure Gov architecture overview"
src="/images/ocp_azuregov/azure_arch.jpg"
link="/images/ocp_azuregov/azure_arch.jpg"
target="_blank"
caption="OpenShift on Azure Gov architecture overview"
>}}

There are a couple of caveats:

* After deploying the initial 3.11 cluster using the Azure ARM template, additional cluster lifecycle events are managed using the OpenShift 3.x standard of [openshift-ansible](https://github.com/openshift/openshift-ansible).

* ARM templates have a built-in 90 minute timeout. If you add log aggregation and metrics into your OpenShift cluster, you can creep past this time limit. I did. The template said I errored, but the only error was a timeout condition in the Azure API. I logged into the bastion host doing the deployment and the logs looked complete. Turns out the cluster finished just after the 90 minute mark and was fully functional. **The Azure team who maintains this template is aware of the issue and working on it.**

To walk through the entire process, including some point and click fun to double-check the entire cluster was operational, I made a [youTube](https://www.youtube.com/watch?v=-DOz2781Rm4) video for your enjoyment.

{{< youtube -DOz2781Rm4 >}}

If you’re at Red Hat Summit this week, and this topic is in your brain somewhere, please come by the session, or find me somewhere in the convention center and let’s talk about it!
