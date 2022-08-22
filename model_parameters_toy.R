#Edits- For toy model
#------------------------------------------------
#' Model Parameter List Creation
#'
#' \code{model_param_list_create} creates list of model parameters to be used
#' within \code{equilibrium_init_create}
#'
#' @param nrates Number of Erhlang distribution compartments to replay delay function. Default = 15
#' @param a Biting rate (bites per human per mosquito). Default = 1/3
#' @param bh Probability of transmission from vectors to humans. Default = 0.05
#' @param bv Probability of transmission from humans to vectors. Default = 0.05
#' @param p Daily probability of vector survival. Default = 0.9
#' @param mu Mosquito deat rate. Default = -log(p)
#' @param r Rate of recovery from human infection. Default = 1/100
#' @param tau Length of mosquito latency period. Default = 12
#' @param ... Any other parameters needed for non-standard model. If they share the same name
#' as any of the defined parameters \code{model_param_list_create} will stop. You can either write
#' any extra parameters you like individually, e.g. model_param_list_create(extra1 = 1, extra2 = 2)
#' and these parameteres will appear appended to the returned list, or you can pass explicitly
#' the ellipsis argument as a list created before, e.g. model_param_list_create(...=list(extra1 = 1, extra2 = 2))
#'
#' @export


model_param_list_create_toy <- function(
    nrates = 15,
    a = 1/3,
    bh = 0.05,
    bv = 0.05,
    p = 0.9,
    mu = -log(p),
    r = 1/100,
    tau = 12,
    ...
    
){
  # set up param list
  mp_list <- list()
  
  # catach extra params and place in list
  extra_param_list <- list(...)
  if(length(extra_param_list)>0){
    if(is.list(extra_param_list[[1]])){
      extra_param_list <- extra_param_list[[1]]
    }
  }
  
  ## DEFAULT PARAMS
  
  mp_list$nrates <- nrates
  mp_list$a <- a
  mp_list$bh <- bh
  mp_list$bv <- bv
  mp_list$p <- p
  mp_list$mu <- mu
  mp_list$r <- r
  mp_list$tau <- tau
  
  
  # check that none of the spare parameters in the extra
  if(sum(!is.na(match(names(extra_param_list),names(mp_list))))!=0){
    
    stop (message(cat("Extra params in ... share names with default param names. Please check:\n",
                      names(extra_param_list)[!is.na(match(names(extra_param_list),names(mp_list)))]
    )
    ))
  }
  
  return(append(mp_list,extra_param_list))
}
