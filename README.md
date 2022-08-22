# toy_eq_pmcmc

For the malaria model, we use a function that calculates the initial values of the model at t=0 based on an equilibrium solution (equilibrium_toy.R). Another function, the model parameter list (model_parameters_toy.R), contains default parameters that can be modified or added to (for example, adding the beta volatility parameter for the random walk), which is used by both the equilibrium solution and the main odin model. The equilibrium solution and model parameter list are how we specify the user defined values for the odin model. But we often want to fit the initial values to the data. In my example, we want to fit both beta_volatility and init_Ih. 

So my questions are:
Do I need to convert the fixed values in the equilibrium state and parameter list into pmcmc_parameters? If so, is there a more straightforward approach than converting each parameter individually and then fixing them? In other words, is there a way to fix these parameters before having to specify them as pmcmc_parameters (I'm guessing this is where the closure comes in)?
Since changing init_Ih changes the equilibrium solution, how do I run that function at each step of the MCMC?
Finally, is there a way to specify the proposal matrix for just two parameters of interest as opposed to including a matrix for all the parameters from the equilibrium solution and parameter list (most of whose proposals we will ignore because we want them fixed anyway)?

Files:
run_pmcmc-toy.R: Main code to generate simulated data and run the pmcmc
toyodinmodel.R: Odin model with stochastic update
equilibrium_toy.R: Equilibrium solution for toyodinmodel
model_parameters_toy.R: Function to create a list of parameters needed for the model
./data_gen/data_gen_toy.R: Generates simulated data
./data_gen/RM_RW_odin_model.R: Odin model with random walk used to generate simulated data
