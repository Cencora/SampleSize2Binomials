For p=1,…,Number of simulations, draw $$\\theta_1^p \\sim Beta(\\alpha_1, \\beta_1)$$ and $$\\theta_2^p \\sim Beta(\\alpha_2, \\beta_2)$$  

Then draw the number of successes $X_1^p$ and $X_2^p$ from $X_1 \\sim Bin(n_1,\\theta_1)$ and $X_2 \\sim Bin(n_2,\\theta_2)$. These are the assumed distributions of the data assuming the design prior is correct.  Also, draw $X_{2\,null}^p  ~ Bin(n_2,\\theta_1)$; these are alternative novel treatment group data values assuming the null distribution (no treatment effect).  Next, compute the posterior distributions for $\\theta_1$ and $\\theta_2$. Thanks to the conjugacy of the beta prior with the binomial likelihood, these posteriors can be written as 
$$ \\theta_{1\,post}^p \\sim Beta(\\alpha_1 + X_1^p,\,\\beta_1 + n_1 - X_1^p) $$
$$ \\theta_{2\,post}^p \\sim Beta(\\alpha_2 + X_2^p,\,\\beta_2 + n_2 - X_2^p) $$
$$ \\theta_{0\,post}^p \\sim Beta(\\alpha_2 + X_{2\,null}^p,\,\\beta_2 + n_2 - X_{2\,null}^p) $$

Hence, by simple differencing, we can estimate the posterior distribution of the difference between them under the design prior, $\\delta^p = \\theta_{2\,post}^p - \\theta_{1\,post}^p$, as well as the corresponding posterior distribution of the difference under the null hypothesis, $\\delta_{null}^p = \\theta_{0\,post}^p - \\theta_{1\,post}^p$. 

Compute PoS1, P($\\delta^p > \\eta/2 \\mid data$), which is just the empirical proportion of $\\delta^p$ values that exceed $\\eta/2$.  If PoS1 is greater than the threshold, the treatment is effective; otherwise, it is not effective. Similarly, we can also compute PoS2, P($\\delta_{null}^p > \\eta/2 \\mid data$).  This value is the Type I error of the procedure under the elicited prior.  

Then, the entire process is repeated, but using flat priors, Beta (1,1), and report the power and Type I error under the flat priors as well.  The difference in these quantities indicates how much benefit (increased power) we get from using the user’s elicited prior, and at what cost (increased Type I error, which will always result unless the user does not think the new treatment will beat the standard).