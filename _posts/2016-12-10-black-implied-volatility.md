---
layout: post
title: "Black's (1976) Implied Volatility"
date: 10 Dec 2016
categories: posts
tags:  r quant
---

The Black 76 model is an adaptation of the Black-Scholes model originally proposed to price commodity options, but has found many applications in other asset classes such as bond options and futures options. Details about the model and its derivation can be read off on Wikipedia. Anyway, below is my Black pricing function of European futures option (`blkPrice`) 
<br>

```r
blkPrice <- function (f, k, tau, sigma, type, r) 
{
    if (missing(r)) {
        r <- 0.01
    }
    d1 <- log(f/k)/(sigma * sqrt(tau)) + sigma/2 * sqrt(tau)
    d2 <- d1 - sigma * sqrt(tau)
    typeFlag = ifelse(type == "C", 1, -1)
    (f * pnorm(d1 * (typeFlag)) - k * pnorm(d2 * (typeFlag))) * 
        typeFlag * exp(-r * tau)
}
```
I have vectorized this function so it's possible to do something like this

```r
blkPrice(20, 20 + seq(-2, 2, by = 0.25), 4/12, 0.25, "P")
```

```r
## [1] 0.3700305 0.4375653 0.5131497 0.5970697 0.6895429 0.7907156 0.9006619
## [8] 1.0193849 1.1468191 1.2828346 1.4272423 1.5797999 1.7402191 1.9081729
## [15] 2.0833027 2.2652258 2.4535427
```
 And here's the function used to back out implied volatility (`blkImpVol`)

```r
blkImpVol <- function (f, k, tau, price, type, r, tol = .Machine$double.eps, 
    maxIter = 10000, interval = c(0, 10)) 
{
    uniroot(function(x, f, k, tau, price, type, r) {
        blkPrice(f = f, k = k, tau = tau, sigma = x, type = type, 
            r = r) - price
    }, interval = c(-10, 10), f, k, tau, price, type, r)$root
}
```

This function relies on R's `uniroot` function, which uses Brent's method, to solve for the implied volatility numerically. Now, assume option data are available in the following format and we're supposed to calculate the implied volatility for each option

```r
## strike type optionPrice futurePrice time_to_expiry
##1    98.0    C      2.1230         100           0.25
##2    98.0    P      0.0011         100           0.25
##3    98.8    C      1.3259         100           0.25
```

The following function will help us do that

```r
ImpliedVol <- function (dat) 
{
    iv <- mapply(blkImpVol, dat$futurePrice, dat$strike, dat$time_to_expiry, 
        dat$optionPrice, dat$type)
    return(iv)
}
```
Now let's see how it works with an example

```r
df <- data.frame(strike = c(50, 20),
                 type = c("C", "P"),
                 optionPrice = c(1.62, 0.01),
                 futurePrice = c(48.03, 48.03),
                 time_to_expiry = c(0.1423, 0.1423))
ImpliedVol(df)
```

```r
## [1] 0.3370149 0.8556862
```

That looks great, however as the number of option increases, the function slows down markedly. This is due to the inefficient nature of `uniroot`, which can be improved by writing the univariate solver in C++ and wrap it in R by `Rcpp`, as suggested [here][blog]. 

[blog]: http://dirk.eddelbuettel.com/blog/2012/10/25/
