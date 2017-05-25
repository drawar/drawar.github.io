---
layout: post
title:  "Monte Carlo Simulation"
date:   2016-04-19
categories: posts
tags: mc option
comments: true
---
Monte Carlo simulation is a legitimate and widely used technique for dealing with uncertainty in many aspects of business operations. The objective of any simulation study is to estimate an expectation ($$ E(X) $$) in some form or another thus this method can be readily applied to determine *expected* option value. Monte-Carlo methods are ideal for pricing options where the payoff is path-dependent (e.g. lookback options, Asian options, and spread options) or options whose payoff is dependent on multiple assets, when it is not feasible to work with lattice-based methods such as binomial tree or finite difference method.
<br>

### Theoretical background

A typical Monte Carlo simulation consists of three steps

* Identify a random variable of interest $$ X $$.
* Generate an i.i.d. sample $$ X_1, X_2, $$ ..., $$ X_n $$ from the distribution of $$ X $$.
* Estimate $$ E(X) $$ using the sample mean $$ \bar{X} $$

The use of sample mean to estimate the expectation of interest is justified by the Strong Law of Large Numbers (SLLN) which states that if $$ X_1, X_2 $$, ..., $$ X_n $$ are independent and identically distributed, each with finite expectation, then

$$ \frac{1}{n}\sum_{i=1}^n X_i \to\ E(X) $$

with probability 1. In the simulation context it means that as we generate more and more samples i.e. increase $$ n $$, our sample mean $$ \bar{X} $$ converges to the desired value $$ E(X) $$. Moreover when the variance of $$ X_i $$ is also finite, the Central Limit Theorem (CLT) tells us that

$$ \frac{\sqrt{n}(\bar{X}-\mu)}{\sigma} \leadsto\ N(0,1) $$

where $$ \mu = E(X_i) $$, $$ \sigma^2 = Var(X_i) $$, and the wiggly arrow denotes convergence in distribution. In the simulation context we can use this theorem to obtain a confidence interval for the expectation that we are estimating.

### Generate independent random variables

It's important to note that almost all random number generators actually create series of *pseudo-random* numbers. They aren't random in the strict mathematical sense because the entire sequence of numbers is a deterministic function based on an initial seed value. Nevertheless, sequences of numbers can be created such that they appear very close to random, since the seed, by default, is changed with every call of the generating procedure, unless set otherwise.

If we can generate uniform random numbers from a $$ Uniform(0,1) $$ then we have the basis for generating many other random variables as well. This is why many programming languages include functions that return $$ Uniform(0,1) $$ values as built-in functions. For example, if we want to generate a Bernoulli random variable with parameter p, then call a uniform random number between (0,1) and determine if it is less than p. If so, return the value, otherwise return the value 0.

Uniform random variables can also be used as starting points to generate other important random variables, such as the normal. We can generate two independent standard normal random variable (i.e. with zero mean and unit variance) by taking two independent uniform random numbers, $$ U_1 $$ and $$ U_2 $$, and transforming them as

$$ X_1 = \cos (2\pi U_1)\sqrt{-2 \log U_2}, \quad X_2 = \sin (2\pi U_1)\sqrt{-2 \log U_2}. $$

This method of generating normal random variables from uniform random variables is known as the *Box-Muller method*.

### Generate correlated random variables

So far we have only discussed generate uncorrelated samples of random variables. How about generating $$ Y_1 $$ and $$ Y_2 $$ from a bivariate normal distribution with mean $$ (\mu_1, \mu_2) $$, variance $$ (\sigma_1^2, \sigma_2^2) $$ , and correlation $$ \rho $$? To do so, we make use of *Cholesky Decomposition* to decompose the covariance matrix into the product of a lower triangular and its transpose. Thus the steps are

* Use *Box-Muller method* to draw random samples $$ X_1 $$ and $$ X_2 $$.
* Make the transformation

$$ Y_1 = \mu_1+\sigma_1 X_1,\quad Y_2 = \mu_2 + \sigma_2(\rho X_1+\sqrt{1-\rho^2}X_2). $$
