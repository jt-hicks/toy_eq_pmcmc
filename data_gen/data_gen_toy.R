# Create a simulated data set to test binomial likelihood comparison function.
# Read in odin model
data_gen_toy <- function(volatility,init_prev,model_file='./data_gen/RM_RW_odin_model.R'){
# Create random walk beta sequence to pass to model
  source('model_parameters_toy.R')
  source('equilibrium_toy.R')
  
  mpl <- model_param_list_create_toy()
  
  pars <- equilibrium_toy(prev_eq=init_prev,mpl=mpl)
  
  genRandWalk <- function(x,vol,randWalk) {
    if (x == 0)    return (randWalk)
    else return(genRandWalk(x-1,vol,c(randWalk,randWalk[length(randWalk)]*exp(rnorm(1)*vol))))
  }
  beta_times<-seq(0,1800,by=30)
  beta_volatility<-volatility
  beta_vals <- genRandWalk(length(beta_times)-1,beta_volatility,pars$init_beta)
  keep <- beta_vals

  mpl <- model_param_list_create_toy(beta_times=beta_times,beta_vals=beta_vals)
  
  pars <- equilibrium_toy(prev_eq=init_prev,mpl=mpl)
  
  # Run model
  generator <- odin(model_file)
  state_use <- pars[names(pars) %in% coef(generator)$name]
  
  # create model with initial values
  mod <- generator(user = state_use, use_dde = TRUE)
  t <- seq(30, 1830, by = 30)
  output <- as.data.frame(mod$run(t))
  
  #Generate pseudo data from run instance
  #Select proportions at whole days
  days <- output[,c('t','Ih')]
  days$tested <- round(rnorm(n = length(days$t), mean = 10000, sd = 100))
  days$positive <- rbinom(n = length(days$t), size = days$tested, p = days$Ih)
  test_data <- days[,c('t','tested','positive')]

  
  matplot(days$t, days$positive/days$tested, type = "l", lty = 1, #col = cols_prev,
          xlab = "time", ylab = "number positive")

  return(test_data)
}