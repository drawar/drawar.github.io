---
layout: post
title: "plotly demo"
date: 24 May 2016
categories: posts
tags:  r data-visualization plotly interactive
---



```r
library(plotly)
p <- plot_ly(economics, x = date, y = unemploy / pop)
p
```
<p align="center">
<iframe width="600" height="400" frameborder="0" scrolling="no" src="https://plot.ly/~drawar/3.embed"></iframe>
</p>
