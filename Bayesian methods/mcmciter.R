
mcmc.iter <- function(theta, logDensity, sigma, n.iter){
  
  res <- matrix(NA, n.iter+1, length(theta)) # Matrix for saving values 
  res[1,] <- theta # Saves startung value
  logD <- logDensity(theta) # log density of starting value
  accProb <- 0 # No. of accepted draws
  
  # Code that perfroms steps 1-3 of MCMC. 
  for (i in seq_len(n.iter)){ # Repeats code below n.iter times
    
    thetaProp <- theta + rnorm(length(theta), 0, sigma) # Proposal 
    logDProp <- logDensity(thetaProp) # Log density of proposal 
    r <- min( c(1, exp(logDProp - logD) ) ) # Computes r (step 2) 
    
    if(r>runif(1)){ # Accept thetaProp with probability r
      
      theta <- thetaProp 
      logD <- logDProp 
      accProb <- accProb + 1
      
    }
    
    res[i+1,] <- theta # Save value  
    
  }
  
  list(sample = res, accProb = accProb/n.iter) # Output
  
}
