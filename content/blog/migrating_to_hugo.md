---
title: "Migrating from Medium to Hugo"
date: 2019-12-28T09:41:49-05:00
draft: false
image: "/images/migrating_to_hugo/birds_migrating.jpg"

categories: 
  - Hugo
tags:
  - howto
  - medium
  - automation

# post type
type: featured
---

My personal blog/writing platform has lived in a lot of places over the years. My dedication to contributing to it tends to come in spurts. It's lived on a lot of platforms over the years. Most recently it's been hosted on [Medium](https://medium.com/@jamieeduncan). I decided to migrate from Medium for a [hosts of reasons](https://nomedium.dev/) this post isn't going into and back to my own blog. I landed on using [Hugo](https://gohugo.io/) and hosting it on [Netlify](https://www.netlify.com/).

My primary goal was to take some of my favorite posts from Medium and re-publish them on my new Hugo-powered blog. 

{{< tip
title="I'm not a design professional"
>}}
My design skills are "curious amateur" level at best. I didn't create this site from scratch, or anything near it. I actually paid a few dollars for a [Hugo theme](https://gethugothemes.com/products/liva-hugo/) I liked and have done a little customization on it. 

In fact, this admonition box is one of my customizations. My next blog post will likely be about the [Hugo shortcodes](https://gohugo.io/content-management/shortcodes/) I've added to my site's codebase so far.
{{< /tip >}}

## Getting content out of Medium in Markdown

Medium has an export function, but it outputs your content as HTML. Luckily, `mediumexporter` has already been created to do this job for us. I found [an article](https://medium.com/@macropus/export-your-medium-posts-to-markdown-b5ccc8cb0050), oddly enough on Medium, that outlines its usage. As I began to think about it I decided I needed to build on this very useful one-liner just a little bit more. 

If you aren't used to using Hugo, creating content is handled by the `hugo` command line tool. My site uses a `blog` category to handle my normal posts, so creating a new blog post would look like this. Notice that I included the file extension to tell Hugo that this was going to be written using markdown.

```
hugo new blog/new_topic.md
/Users/djamie/Code/jduncan_io/content/blog/new_topic.md created
```
All content is created inside the `content` folder in Hugo. Here's how I decided to build out my site's directory structure (the them I used dictated a lot of this structure). You can see `content/blog/new_topic.md` was created.

```
content
├── about
│   └── about.md
├── blog
│   ├── _index.md
│   ├── container_image.md
│   ├── dockercon_2017.md
│   ├── domain_specific_dns_on_macbook.md
│   ├── kube-on-pi.md
│   ├── linux_capabilities.md
│   ├── migrating_to_hugo.md
│   ├── new_topic.md
│   ├── ocp_on_azuregov.md
│   ├── practical_kubernetes_operator.md
│   └── technical_debt.md
├── contact
│   └── _index.md
└── search
    └── _index.md

4 directories, 14 files
```

Hugo adds _frontmatter_ to each newly created markdown file. You can customize how this works using [archetypes](https://gohugo.io/content-management/archetypes/). When I created my new blog post this frontmatter was automatically generated. 

```
---
title: "New_topic"
date: 2019-12-28T11:56:24-05:00
draft: true
image: "/images/some/path/"

categories:
  -
tags:
  -

# post type
type: post
---
```

This is metadata used by Hugo and the templates you create to create logic and stateful information in your site. For example, the `image` parameter is used by my theme to set the preview image at the top of each blog post. Additionally, the `type` parameter is used to decide if a post 'normal', or if it's `featured` at the top of my home page. Hugo builds in variable scoping, so the parameters in a post's frontmatter are valid only for that page, while parameters in your `config.toml` or `config.yaml` files are scoped to be site-wide. It's a simple, powerful system.

Now that I have my frontmatter set, I can use `mediumexporter` to populate the content. 

### Using mediumexporter to add post content

By default, `mediumexporter` takes a URL from a medium post and outputs the content as markdown to `STDOUT`. Using a simple redirect I can append this content to my new, empty post from the base directory for my Hugo site. 

```
mediumexporter https://medium.com/@macropus/export-your-medium-posts-to-markdown-b5ccc8cb0050 >> content/blog/new_topic.md
```

Your new post now looks more like this. 

```
---
title: "New_topic"
date: 2019-12-28T11:56:24-05:00
draft: true
image: "/images/some/path/"

categories:
  -
tags:
  -

# post type
type: post
---


# Export your Medium posts to Markdown

There’s a simple solution to avoid copy/pasting and re-editing your Medium articles.

![](https://cdn-images-1.medium.com/max/2000/1*i-S80mDrkJQO2tJ_lhYwfA.png)

First of all, you need to install node on your computer.

There is an installer for node for all platforms, just download it and install it like you would any other program:

* [***https://nodejs.org/en/download/](https://nodejs.org/en/download/)***

Once you have this installed, you fire up the **Command Prompt** on **Windows** or **Terminal** on **MacOS** or **Linux** and run this command.
...
```

You're close! But you should make a few tweaks to make your content more inline with Hugo best practices.

### Tweaking the content to fit Hugo

* The first changes you should make is to the frontmatter. The `mediumexporter` tool doesn't make any changes to it, so you should at least alter the `date` parameter to reflect the data you published the content on Medium. At least I think you should.
* Hugo uses the `title` parameter to set the title for a post, while `mediumexporter` sets the title as a top level markdown heading. So take the top-level (single `#`) heading and set it to your Medium post's title.
* Hugo has builtin shortcodes for embedding common format types like [YouTube videos](https://gohugo.io/content-management/shortcodes/#youtube) and [Twitter](https://gohugo.io/content-management/shortcodes/#tweet) content. The `mediumexporter` tool takes those Medium plugins and converts them to raw HTML. 
* Graphics and images are linked to their Medium CDN URL. I pulled down local copies of all the content into my sites `static/images` directory. For each post I create a new sub-directory there to hold the post's images and graphics.
* I used the `figure` shortcode and created a bootstrap `media` shortcode (post upcoming) to format the pictures in my post to look very similar to their appearance on Medium. The `figure` shortcode creates HTML5 `<figure>` content. The [`media`](https://getbootstrap.com/docs/4.0/layout/media-object/) shortcode creates bootstrap media objects to quickly format grahpics and text. 

## Conclusions and next steps

Making those changes, I was able to take my favorite 6 or 8 Medium posts and pull them into Hugo cleanly in about 45 minutes. I have since added a small script to automate creating a new post and its corresponding images subdirectory.

```
#! /usr/bin/env bash

ARTICLE=$1

echo "Creating new blog post $1."
hugo new blog/$1.md
echo "Creating directory for images."
mkdir -p static/images/$1
echo "Done. Happy writing."
```

This is simplistic now, but I'll keep updating it with things like regex to set the images directory and other fun things. I do love a good helper script.

After working with Hugo on and off for a weekend, I'm quite impressed. It's easier to extend than most of the other static site generators I've worked with in the past. Hugo also is fast and consistent with a vibrant user community to help you work through challenges while you're getting started.
