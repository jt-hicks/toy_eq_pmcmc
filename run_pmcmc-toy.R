library("odin.dust")
library("odin")
library("patchwork")
library('mcstate')
library(RColorBrewer)

setwd('./toy_example/')
source('./data_gen/data_gen_toy.R')
source('model_parameters_toy.R')
source('equilibrium_toy.R')

#Generate some data
data_raw_toy <- data_gen_toy(volatility=0.1,init_prev = 0.5)

###Setting up particle filter with data, index, compare, and stochastic schedule
data <- mcstate::particle_filter_data(data_raw_toy, time = "t", rate = NULL, initial_time = 0)

index <- function(info) {
  list(run = c(Ih = info$index$Ih),
       state = c(Host_prev = info$index$Host_prev,
                 Vector_prev = info$index$Vector_prev,
                 beta = info$index$beta_out))
}

compare <- function(state, observed, pars = NULL) {
  dbinom(x = observed$positive,
         size = observed$tested,
         prob = state[1, ],
         log = TRUE)
}

stochastic_schedule <- seq(from = 60, by = 30, to = 1830)

##Suppose we want to fit parameters for the beta volatility and initial prevalence of a population
##The model_param_list_create_toy generate a list of default parameters that is
##used by both the equilibrium solution and the main odin model
##We add beta_volatility here because it's needed by the odin model, but not the 
##equilibrium solution.
mpl_pf <- model_param_list_create_toy(beta_volatility=0.1)

##Run the equilibrium solution to get initial compartment values at a given
##prevalence.
state <- equilibrium_toy(prev_eq=0.4,mpl=mpl_pf)

##Create the particle filter
model <- odin.dust::odin_dust("toyodinmodel.R")
n_particles <- 100
p <- mcstate::particle_filter$new(data, model, n_particles, compare,
                                  index = index, seed = 1L,
                                  stochastic_schedule = stochastic_schedule,
                                  n_threads = 4)

##Now this is where I struggle. Say I want to fit init_Ih and beta_volatility
##using the pmcmc. How do I fix the other parameters in the mpl and equilibrium
##solution, but allow init_Ih and beta_volatity to change? Since a changing init_Ih
##will change the rest of the equilibrium solution, how do I get the equilibrium
##solution function to run at the beginning of each MCMC step?
##Below I've coded as it would be nice to have it. That is, where I 
##only have to specify init_Ih and beta_volatility as pmcmc_parameters and
##the proposal matrix only includes covariance distributions for those two parameters.
init_Ih <- mcstate::pmcmc_parameter("init_Ih", 0.8, min = 0, max = 1)
beta_volatility <- mcstate::pmcmc_parameter("beta_volatility", 0.3, min = 0)

proposal_matrix <- diag(0.1, 2)
mcmc_pars <- mcstate::pmcmc_parameters$new(list(init_Ih = init_Ih, 
                                                beta_volatility = beta_volatility),
                                           proposal_matrix)
n_steps<- 500
n_burnin <- 200


control <- mcstate::pmcmc_control(
  n_steps,
  save_state = TRUE,
  save_trajectories = TRUE,
  progress = TRUE,
  n_chains = 4,
  n_workers = 2,
  n_threads_total = 16)
pars<- mcmc_pars$fix(list(#??equilbrium function except init_Ih and beta_volatility?
                            ))
pars$initial()
pmcmc_run <- mcstate::pmcmc(pars, p, control = control)

history <- pmcmc_run$trajectories$state

matplot(data_raw$t, t(history[1, , -1]), type = "l",
        xlab = "Time", ylab = "State",
        col = "#ff000022", lty = 1)
lines(data_raw$t,data_raw$positive/data_raw$tested,col="blue",lwd=4)

out_pars <- as.data.frame(pmcmc_run$pars)
plot(out_pars$beta_volatility)
plot(out_pars$beta_volatility)
