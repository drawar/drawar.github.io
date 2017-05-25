---
layout: post
title: "Optimal ETF Portfolio"
date: 24 Jan 2017
categories: posts
tags:  r quant shiny
---

<a href="https://lhvan.shinyapps.io/ETF_Portfolio/"><img src="https://raw.githubusercontent.com/drawar/drawar.github.io/master/_posts/etf-portfolio_img1.png" width="1200" height="300" />


Update 18/05/2017: It has come to my attention that Yahoo Finance has changed their API and thus most download functions, including the one I'm using for this dashboard, will no longer work. If anyone is interested in developing a fix, please follow this GitHub [thread][thread].
<br>


It's the start of my CNY holiday and I finally get some off time to dig into some R codes, this time with Shiny dashboard. Inspired by [this][blog], I have made a similar app with U.S. ETFs, since data for these are more complete and readily available at Yahoo!Finance. I also decided to replace some static chart with `highcharter` interactive chart, and implemented my own mean-variance optimized portfolio with options to specify maximum allocation per security and ability to short-sell.

[blog]: https://thedatagame.com.au/2016/12/24/a-single-index-model-shiny-app-for-etfs/
[thread]: https://github.com/joshuaulrich/quantmod/issues/157
