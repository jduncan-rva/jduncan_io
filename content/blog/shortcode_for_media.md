---
title: "Getting to know Hugo shortcodes"
date: 2019-12-28T21:49:22-05:00
draft: false
image: "/images/shortcode_for_media/birds.jpg"
summary: "A quick introduction to Hugo shortcodes with examples"

categories: 
  - Hugo
tags:
  - shortcodes
  - bootstrap
  - design

# post type
type: post
---

One of the biggest things that made me leary about getting to know Hugo over the years is its desire to use [Markdown](https://www.markdownguide.org/basic-syntax/). Yes, Hugo supports [asciidoc](http://asciidoc.org/) and [restructuredtext](https://docutils.sourceforge.io/rst.html). But its heart is in markdown. From the Hugo website:

{{< quote author="Hugo docs">}}
Hugo loves Markdown because of its simple content format, but there are times when Markdown falls short. Often, content authors are forced to add raw HTML (e.g., video &lt;iframe&gt; to Markdown content. We think this contradicts the beautiful simplicity of Markdown's syntax.
{{< /quote >}}

This sums up my relationship with markdown almost perfectly. Markdown is great for a README file in a repo, but it comes up a little short when you want to communicate in more complex ways like project documentation, a website, or even a book. Hugo overcomes these limitations while keeping the writing experience simple using [Shortcodes](https://gohugo.io/content-management/shortcodes/). Shortcodes are maybe the most powerful feature in Hugo because it provdes the ability to keep the writing experience simple, but also quickly and easily extend its templating system. The quote above is a shortcode to format the quote properly. I had to type this code:

{{< figure 
width="720px" height="82px"
src="/images/shortcode_for_media/quote_shortcode.png"
alt="Using a shortcode to format a blockquote"
caption="shortcode content to format a blockquote"
>}}

A shortcode is called by using the Hugo-standard `{{`, followed by either a `<` or `&`. The difference between the two operators has evolved over time withn Hugo. Currently, if you use `<` you're telling Hugo that your shortcode won't require any additional markdown parsing, while using `&` will process your shortcode output through the [Hugo markdown processing engine](https://gohugo.io/getting-started/configuration-markup/#goldmark).

Shortcodes are stored in your Hugo project in `/layouts/shortcodes` or inside your them at the same location. My shortcode for the quote content wraps your content in a blockquote and handles the `author` parameter that is passed to provide quote attribution.

```
<blockquote>
    <p>{{ .Inner | markdownify }}</p>
    <span class="cite">- {{ .Get "author" }}</span>
</blockquote>
```

* The `{{ .Inner }}` parameter represents all the content between the beginning and ending shortcode tags. [Markdownify](https://gohugo.io/functions/markdownify/) is a function in Hugo that runs the content through the markdown engine. I found that I had better results using `markdownify` than running the entire shortcode output through the markdown engine using `&` when calling my shortcode. I'm not entirely sure why this was the case, and it could well be my own lack of Hugo experience. 
* `{{ .Get "author" }}` pulls in the value of the `author` parameter that your configure in your shortcode. In my example that was `Hugo Docs`. 

At this point, I have properly rendered HTML content for my bockquote. To give it the effect I wanted with the pretty border and large quotation mark at the top, I found some CSS on the internet to format the elements I created in my shortcode. 

```
blockquote {
    display: block;
    border-width: 2px 0;
    border-style: solid;
    border-color: #eee;
    padding: 1.5em 0 0.5em;
    margin: 1.5em 0;
    position: relative;
  }
  blockquote:before {
    content: '\201C';
    position: absolute;
    top: 0em;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 3rem;
    height: 2rem;
    font: 6em/1.08em 'PT Sans', sans-serif;
    color: #666;
    text-align: center;
  }

  blockquote .cite {
    display: block;
    text-align: right;
    font-size: 0.875em;
    color: #e74c3c;
  }
```

With all of that in place, my website now renders pretty quotes by adding a few simple lines into my markdown content. I also created a shortcode to handle [bootstrap media objects](https://getbootstrap.com/docs/4.0/layout/media-object/). I like this presentation style a lot when I'm creating content. It's similar to the quote shortcode, but takes more parameters and the HTML formatting is a little more complex. 

```
<div class="media">
    <img src={{ .Get "img" }} alt={{ .Get "alt" }} width={{ .Get "width" }} height={{ .Get "height" }}>
    <div class="media-body">
        <h5 class="mt-0">{{ .Get "title" }}</h5>
        {{ .Inner | markdownify }}
    </div>   
</div>
```

You can see this shortcode in action [in my post about Operators]({{< ref "/blog/practical_kubernetes_operator.md#types-of-operators" >}}). 

## Conclusions and next steps
Most Hugo templates come with some shortcodes, There are [built-in shortcodes](https://gohugo.io/content-management/shortcodes/#use-hugos-built-in-shortcodes) in Hugo as well. My plan is to eventually maintain a collection of shortcodes that do what I want with the themes I use. It's an incredibly powerful framework to make Hugo customizable while keeping it simple.