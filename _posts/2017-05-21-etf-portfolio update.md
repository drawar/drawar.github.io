---
layout: post
title: "New Update to Optimal ETF Portfolio Dashboard"
date: 21 May 2017
categories: posts
tags:  r quant shiny
comments: true
---



As some of you may have noticed, Yahoo! Finance API has stopped working for the past few days because the service has allegedly been discontinued (more details [here][yahooforum], which has in turn corrupted a lot of R programs that rely on the API, including this dashboard. Luckily I have found a temporary fix that addresses this issue.
<br>

It's true that Yahoo! has discontinued the service, but they still host the data on their server, albeit making them more difficult to access and download by adding a "crumb" to their url. You will now have to establish a session with Yahoo! Finance by entering, for example, [https://finance.yahoo.com/quote/AAPL/history?p=AAPL][link], with your browser to get that crumb. 

## How to get the crumb, in fine points

Here's a step by step guideline to get that sacred piece of information

1. Go to [https://finance.yahoo.com/quote/AAPL/history?p=AAPL][link] with your browser. Any ticker other than "AAPL" is fine as well.
2. Look for the "Download Data" button and right click and copy the link
3. Near the end of the link you'll see something like "&crumb=". Copy whatever follows it. Congrats, you have found the crumb.

## So I have the crumb now, what's next?

You'll need to gingerly paste the crumb into the box on the sidebar and you're set to use the dashboard as usual. One caveat though, that this workaround requires a new browser tab/window to open for each ETF ticker you selected. This is admittedly not the best idea, but it works so I'm going to stick to it until a better fix comes around. I'm more than happy to hear what you think, so feel free to comment below your suggestions.

<a href="https://lhvan.shinyapps.io/ETF_Portfolio/"><img src="https://raw.githubusercontent.com/drawar/drawar.github.io/master/_posts/etf-portfolio-update.png" width="1200" height="300" />

[blog]: https://thedatagame.com.au/2016/12/24/a-single-index-model-shiny-app-for-etfs/
[yahooforum]: https://forums.yahoo.net/t5/Yahoo-Finance-help/Is-Yahoo-Finance-API-broken/td-p/250503/page/3)
[link]: https://finance.yahoo.com/quote/AAPL/history?p=AAPL
