---
layout: post
title:  "Dynamic Copula Estimation"
date:   2016-04-24
categories: posts
tags: copula r
comments: true
---
An important issue in modeling asset returns is the change of dependence and market co-movement in different periods of the market. Early work has documented this issue for equity markets, along with evidence that changes in correlation caused deviations from multivariate normality characterized by asymmetric dependence. This is a stylized feature that should be considered in the estimation of systemic risk. In this respect, the use of constant correlations may severely affect the risk estimates and lead to incorrect inferences. Naturally this calls for the specification of a dynamic copula, that is a copula whose shape and parameters change with time. We present in the following the dynamic specifications for various (constant) copula models.
<br>
[Patton (2006)][Patton] adapts the idea of [Engle (2002)][Engle] to model the dynamics of bivariate Archimedean copulas with an ARMA-type process. He assumes that the functional form of the copula stays fixed over the sample, whereas the transformed copula parameter as Kendall’s tau varies according to the process

$$ \tau_t = \Lambda\left(\omega +b\tau_{t-1} +c \sum_{j=1}^{10} \frac{|u_{t-j}-v_{t-j}|}{10}\right), $$

where $$ \Lambda(x)=(1+e^{-x})^{-1} $$ is the logistic transformation to keep $$ \tau_t \in [0,1] $$ at all times and $$ (u_t,v_t) $$ are the copula values i.e. scalars values in the range of (0,1) at time $$ t $$. This equation is henceforth referred to as *Patton's equation*. The parameters $$ \omega $$, $$ b $$, and $$ c $$ are to be estimated using maximum likelihood method. Below we will show how to do this in `R`.

First of all, let us set up the objective function that we need to maximize, which is the log likelihood function of the copula in question. For demonstration, we consider the Gumbel and Clayton copulas.

### Dynamic Gumbel copula
The (constant) Gumbel copula has generator $$ \phi_{Gu}(u)=(-\log u)^{\theta}, \, \theta \geq 1 $$, and consequently is equal to

$$ C_{Gu}(u,v;\theta) = \mathrm{exp}\left[-\{(\log u)^{\theta}+(\log v)^{\theta}\}^{1/\theta}\right] = \mathrm{exp}\left[-(t_u+t_v)^{1/\theta}\right]. $$

Its density is

$$\begin{multline*}
c_{Gu}(u,v;\theta) = \frac{\partial^2 C_{Gu}}{\partial u\partial v}=C_{Gu}(u,v;\theta)(uv)^{-1}\{(-\log u)^{\theta}+(-\log v)^{\theta}\}^{-2+2/\theta}(\log(u)\log(v))^{\theta-1}\\
\times\{1+(\theta-1)((-\log u)^{\theta}+(-\log v)^{\theta})^{-1/\theta}\}
\end{multline*}$$

hence when we incorporate time-varying exposure into its parameter $$ \theta $$ via *Patton's equation*, its log likelihood is given by the function `GumbelTVLogL`.

{% highlight r %}

### Computes the negative log likelihood of a time varying Gumbel copula

GumbelTVLogL <- function(psi, data) {
  u = data[, 1]
  v = data[, 2]
  theta <- GumbelTV(psi, data)
  tu <- (-log(u))^theta
  tv <- (-log(v))^theta
  out1 <- exp(-(tu+tv)^(1/theta))
  out2 <- (u*v)^(-1)
  out3 <- (tu+tv)^(-2+2/theta)
  out4 <- (log(u)*log(v))^(theta-1)
  out5 <- 1+(theta-1)*(tu+tv)^(-1/theta)
  out <- out1*out2*out3*out4*out5
  LL = sum(log(out))
  LL = -LL
  return(LL)
}

GumbelTV <- function(theta,data){
  u <- data[,1]
  v <- data[,2]
  t <- dim(data)[1]
  tau <- rep(1,t)
  psi <- rep(0,t)
  tau[1]     = cor(data,method="kendall")[1,2]
  for (i in 2:t){
    if(i <= 10){
      psi[i] <- theta[1]+theta[2]*psi[i-1]+theta[3]*mean(abs(u[1:i-1]-v[1:i-1]))
    }
    else{
      psi[i] <- theta[1]+theta[2]*psi[i-1]+theta[3]*mean(abs(u[(i-10):i-1]-v[(i-10):i-1]))
    }
    tau[i] <- 0.0001+0.75/(1+exp(-psi[i]))
  }
  psi <- 1/(1-tau)
  return(psi)
}
{% endhighlight %}

### Dynamic Clayton copula
The (constant) Clayton copula, with generator $$ \phi_{Cl}(u)=1/\theta(u^{-\theta}-1), $$ is given by

$$ C_{Cl}(u,v;\theta) = (u^{-\theta}+v^{-\theta}-1)^{-1/\theta}, $$


The density of the Clayton copula is

$$ c_{Cl}(u,v;\theta)=\frac{\partial^2 C_{Cl}}{\partial u\partial v}=(1+\theta)(uv)^{-1-\theta}(u^{-\theta}+v^{\theta}-1)^{-1/\theta-2} $$

and the log likelihood of its dynamic counterpart with $$ \theta $$ changing with time is given by the function `ClaytonTVLogL`.

{% highlight r%}

# Computes the negative log likelihood of a time varying Clayton copula

ClaytonTVLogL = function(psi, data) {
  ############################### calculate loglikelihood ###############
  u = data[, 1]
  v = data[, 2]
  theta <- ClaytonTV(psi, data)
  out1 <- (u*v)^(-1-theta)
  out2 <- (u^(-theta)+v^(-theta)-1)^(-1/theta-2)
  out <- (1+theta)*out1*out2
  LL = sum(log(out))
  LL = -LL
  return(LL)
}

ClaytonTV <- function(theta,data){
  u <- data[,1]
  v <- data[,2]
  t <- dim(data)[1]
  tau <- rep(1,t)
  psi <- rep(0,t)
  tau[1] <- cor(data,method="kendall")[1,2]
  for (i in 2:t){
    if(i <= 10){
      psi[i] <- theta[1]+theta[2]*psi[i-1]+theta[3]*mean(abs(u[1:i-1]-v[1:i-1]))
    }
    else{
      psi[i] <- theta[1]+theta[2]*psi[i-1]+theta[3]*mean(abs(u[(i-10):i-1]-v[(i-10):i-1]))
    }  
    tau[i] <- 0.0001+0.75/(1+exp(-psi[i]))
  }
  psi <- 2/(1-tau)-2
  return(psi)
}
{% endhighlight %}

The next part is the actual estimation step, where we will use the `R` package `nloptr` (short for Nonlinear Optimization in `R`)to solve for obtain our maximum likelihood estimates of $$ \omega $$, $$ b $$, and $$ c $$. In the following `udata` denotes a n-by-2 matrix of copula values.

{% highlight r%}
install.packages("nloptr") # comment this out if you already have this package installed
library(nloptr)
out = nloptr(x0 = c(0.1, -0.3, -0.5), eval_f = ClaytonTVLogL, lb = c(-10, -10, -10), ub = c(10, 10, 10),
opts = list(algorithm = "NLOPT_LN_COBYLA", xtol_rel = 1e-05, maxeval=10000), data = udata)
theta = ClaytonTV(out$solution, data = udata)
sol = out$solution
aic = 2 * length(sol) - 2 * (-ClaytonTVLogL(sol, udata))
se = diag(sqrt(solve(optimHess(sol, ClaytonTVLogL, data = udata))))
{% endhighlight %}

We can do the same for Gumbel copula by changing the respective arguments. Upon having our estimates of the copula parameters, we can then choose which copula model fits the data better based on AIC.


[Patton]: http://papers.ssrn.com/sol3/papers.cfm?abstract_id=895877
[Engle]: http://econpapers.repec.org/article/ecmemetrp/v_3a50_3ay_3a1982_3ai_3a4_3ap_3a987-1007.htm

### **References**

1. *Andrew J. Patton. “Modelling Asymmetric Exchange Rate Dependence”. In: International Economic Review 47.2(2006).*
2. *Robert Engle. “Autoregressive Conditional Heteroscedasticity with Estimates of the Variance of United Kingdom Inflation”. In: Econometrica 50.4 (1982), pp. 987–1007.*
