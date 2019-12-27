---
title: "Everybody owes technical debt — even Kubernetes"
date: 2019-04-21T10:56:37-05:00
draft: false
image: "/images/technical_debt/debt_rock.jpg"

categories: 
  - Kubernetes
tags:
  - technical debt
  - kubernetes

# post type
type: post
---

I talk a lot about technical debt; how paying it off is both a smart long and short term decision. I often focus my conversations around automating old and manual workflows (I work with a lot of my customers to bring Ansible successfully into their environments).

{{< figure 
width="720" height="224"
class="figure"
alt="Dilbert and technical debt"
src="/images/technical_debt/dilbert.gif"
link="/images/technical_debt/dilbert.gif"
target="_blank"
caption="Even Dilbert addresses technical debt"
>}}

But technical debt can take on many forms:

* Manual processes
* Poorly automated processes and workflows
* Legacy code with significant shortcomings

Technical debt can be summarized as any workflow, process, code, or piece of hardware that consistently pulls attention away from fulfilling you and/or your team’s mission. That’s easy enough to understand. But it’s hard to convince someone who’s fighting fires and reactive most of their day to stop what they’re doing and work on automating a workflow that isn’t hopelessly broken and hasn’t been actively worked on since before they joined the team. Even though they comprehend that spending a few hours now can save them a ton of hours later, people almost always focus on the short term emergency and let the long term technical debt build up until it breaks and causes an avalanche of pain for both them and the end users.

We all know this isn’t how we should be doing business. But it seems to be how a lot of end up handling our everyday tasks. And when I walk in to tell someone how to do it ‘right’, the assumption is they’ve been doing it ‘wrong’ up until then. That’s never my intention. I’ve ignored more than my fair share of technical debt over the years. But it can become adversarial. That’s why I was so excited when I saw this tweet from [Tim Allclair](https://twitter.com/tallclair) :

<iframe src="https://medium.com/media/969fb2c8c60c251486ade2eb0968f5b9" frameborder=0></iframe>

Kubernetes is demonstrably the most exciting IT project in the world right now. It’s the gravity well that the IT Celebrity phenomenon orbits. When I saw [Davanum Srinivas](https://twitter.com/dims), a world-class developer, doing the work required here it made me feel good.

I’m not qualified to summarize what he did in any great detail. But from my understanding, it revolves around kubernetes re-basing to a newer release of [cAdvisor](https://github.com/google/cadvisor) — a tool that collects resource data from container runtimes. This re-base made a lot of code for [mesos](http://mesos.apache.org/) and [rkt](https://coreos.com/rkt/) redundant or unneeded.

This contributor to the sexiest OpenSource project on the planet “chopped the wood and carried the water” to retire this technical debt from the kubernetes code base. In the process, he got rid of ~450k lines of code that won’t have to be tested and accounted for and understood again by that team.

That’s what paying off technical debt is all about. I can’t wait to show this to my customers.
