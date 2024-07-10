beta.Solver <- function(modes, ESS){
  alpha <- modes*ESS + 1
  beta <- ESS + 2 - alpha
  return(c("shape1" = alpha, "shape2" = beta))
}

drawElicitedPriorDistribution <- function(alpha1, alpha2, beta1, beta2){
  x0 <- seq(0, 1, length.out = 10000)
  y1 <- dbeta(x0, alpha1, beta1)
  y2 <- dbeta(x0, alpha2, beta2)
  beta_dist <- data.frame(x = rep(x0, 2),
                          Treatment = rep(c("reference treatment", "novel therapy"), each = 10000),
                          y = c(y1, y2))
  
  pElicitedPriorDistribution <- ggplot(beta_dist) + 
    geom_line(aes(x, y, color = Treatment)) +
    labs(x = "Success Rate", y = "Probability Density", title = "Prior") + 
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)) + 
    scale_color_manual(values=c("#ed7a31","#009aa8"))
  
  return(pElicitedPriorDistribution)
}

# draw theta1 and theta2 from elicited distribution, then draw X from corresponding binomial distribution
computeIsTheDrugEffective <- function(alpha1, alpha2, beta1, beta2, n1, n2, eta, threshold){
 
  theta1 <- rbeta(1, alpha1, beta1)
  theta2 <- rbeta(1, alpha2, beta2)
  
  X1 <- rbinom(1, n1, theta1)
  X2 <- rbinom(1, n2, theta2)
  
  # the posterior dist. for theta1 & theta2, conjugate to the prior
  theta1_post <- rbeta(1e5, X1 + alpha1, n1 - X1 + beta1)
  theta2_post <- rbeta(1e5, X2 + alpha2, n2 - X2 + beta2)
  
  delta_post <- theta2_post - theta1_post
  succ_p <- sum(delta_post > eta/2)/length(delta_post)
  
  if(succ_p > threshold){
    outcome <- "Drug is effective!"
  }else{
    outcome <- "Drug is NOT effective!"
  }
  
  return(outcome)
}

##### Simulation studies
# turn STEP 4 into a function for simulation studies
powerDraw <- function(alpha1, beta1, alpha2, beta2, n1, n2, eta, threshold, Nrep, npos = 1e5){
  
  theta1 <- rbeta(Nrep, alpha1, beta1)
  theta2 <- rbeta(Nrep, alpha2, beta2)
  
  X1 <- rbinom(Nrep, n1, theta1)
  X2 <- rbinom(Nrep, n2, theta2)
  X2_null <- rbinom(Nrep, n2, theta1)
  
  prop_power <- prop_type1 <- prop_power_flat <- prop_type1_flat <- list()
  
  withProgress(message = 'Simulation', value = 0, { 
    
  for (i in 1:Nrep) {
    
    incProgress(1/Nrep, detail = paste("Iteration", i))
    
    theta1_post <- rbeta(npos, X1[i] + alpha1, n1 - X1[i] + beta1)
    theta2_post <- rbeta(npos, X2[i] + alpha2, n2 - X2[i] + beta2)
    theta2_post_null <- rbeta(npos, X2_null[i] + alpha2, n2 - X2_null[i] + beta2)
    
    delta_post <- theta2_post - theta1_post
    delta_post_null <- theta2_post_null - theta1_post
    prop_power[[i]] <- sum(delta_post > eta/2)/length(delta_post)
    prop_type1[[i]] <- sum(delta_post_null > eta/2)/length(delta_post_null)
    
    ### use flat prior beta(1, 1) instead of user input informative priors
    theta1_post_flat <- rbeta(npos, X1[i] + 1, n1 - X1[i] + 1)
    theta2_post_flat <- rbeta(npos, X2[i] + 1, n2 - X2[i] + 1)
    theta2_post_null_flat <- rbeta(npos, X2_null[i] + 1, n2 - X2_null[i] + 1)
    
    delta_post_flat <- theta2_post_flat - theta1_post_flat
    delta_post_null_flat <- theta2_post_null_flat - theta1_post_flat
    prop_power_flat[[i]] <- sum(delta_post_flat > eta/2)/length(delta_post_flat)
    prop_type1_flat[[i]] <- sum(delta_post_null_flat > eta/2)/length(delta_post_null_flat)
  }
    
  })
  
  prop_power <- unlist(prop_power)
  prop_type1 <- unlist(prop_type1)
  prop_power_flat <- unlist(prop_power_flat)
  prop_type1_flat <- unlist(prop_type1_flat)
  succ_power <- sum(prop_power > threshold)/Nrep
  succ_type1 <- sum(prop_type1 > threshold)/Nrep
  succ_power_flat <- sum(prop_power_flat > threshold)/Nrep
  succ_type1_flat <- sum(prop_type1_flat > threshold)/Nrep
  
  #return(list(prop_power, prop_type1, prop_power_flat, prop_type1_flat))
  return(data.frame("Design" = 
                      c(
                        "Elicited prior",
                        "Flat prior"
                      ), 
                    Power = c(succ_power, succ_power_flat),
                    Type_I_error = c(succ_type1, succ_type1_flat)
                    ))
}