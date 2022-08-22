# File: RM_RW_odin_test.R
# Purpose: Adaptation of the Ross-McDonald malaria model to aid development
# of parallelisation of deterministic, continuous-time model parameter estimation.
# Includes delay function and time-varying random walk parameter.

################
# Human States #
################
#Rate of change of state variable of human susceptible
deriv(Sh) <- -foi_h * Sh + r * Ih
#Rate of change of the human infectious compartment
deriv(Ih) <- foi_h * Sh - r * Ih
#Force of infection from vectors to humans
foi_h <- a * bh * Iv


#################
# Vector States #
#################
# Rate of change of the susceptible vector compartment
# beta * init_Sv: scale the interpolated emergence to the initial mosquito population size
deriv(Sv) <- beta - foi_v * Sv - mu * Sv
# Latent vector compartments (mutliple compartments to avoid delay function)
deriv(Ev[1]) <- foi_v * Sv - (nrates/tau) * Ev[i] - mu * Ev[i]
deriv(Ev[2:nrates]) <- (nrates/tau) * Ev[i - 1] - (nrates/tau) * Ev[i] - mu * Ev[i]
# Rate of change of the infectious vector population
deriv(Iv) <- (nrates/tau) * Ev[nrates] - mu * Iv
# Force of infection from humans to vectors
foi_v <- a * bv * Ih                 
# Vector births/deaths - a piece-wise constant function that changes
# every 30 days based on a random-walk function.
beta <- interpolate(beta_times, beta_vals, "constant")

output(beta) <- beta

# total number of mosquitoes
V <- Sv + sum(Ev[]) + Iv

##################
# Initial States #
##################
initial(Sh) <- init_Sh
initial(Ih) <- init_Ih

initial(Sv) <- init_Sv
initial(Ev[]) <- init_Ev[i]
initial(Iv) <- init_Iv

##############
# User Input #
##############
init_Sh <- user()
init_Ih <- user()
init_Sv <- user()
init_Ev[] <- user()
init_Iv <- user()

nrates <- user()
dim(Ev) <- nrates
dim(init_Ev) <- nrates

beta_times[]<-user()
beta_vals[]<-user()
dim(beta_times)<-user()
dim(beta_vals)<-user()

# Ratio mosquitoes:humans
# M <- user(10)

# Biting rate (bites per human per mosquito)
a <- user()
# Probability of transmission from vectors to humans
bh <- user()
# Probability of transmission from humans to vectors
bv <- user()
# Daily probability of vector survival
p <- user()
mu <- user()
#p <- exp(-mu)
# Rate of recovery
r <- user()
# Length in mosquito latency period
tau <- user()

#Check model equations
N <- Sh + Ih
output(Host_prev) <- Ih / N
output(Vector_prev) <- Iv / V
output(Ev_sum) <- sum(Ev[])
output(V) <- V