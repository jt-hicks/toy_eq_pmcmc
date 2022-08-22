##Create a toy example of equilibrium function

equilibrium_toy <- function(prev_eq, mpl){
  
  #Human States Equilibrium
  Ih_eq <- prev_eq
  Sh_eq <- 1 - Ih_eq
  foi_h_eq <- mpl$r * Ih_eq / Sh_eq
  
  #Vector States Equilibrium
  ##need to calculate beta_eq
  foi_v_eq <- mpl$a * mpl$bv * Ih_eq
  Iv_eq <- foi_h_eq / (mpl$a * mpl$bh)
  Ev_eq <- rep(NA,mpl$nrates)
  Ev_eq[mpl$nrates] <- (Iv_eq * mpl$tau * mpl$mu)/mpl$nrates
  for(i in (mpl$nrates-1):1){
    Ev_eq[i] <- (Ev_eq[i+1] * ((mpl$nrates/mpl$tau)+mpl$mu)) / (mpl$nrates/mpl$tau)
  }
  Sv_eq <- (Ev_eq[1] * ((mpl$nrates/mpl$tau)+mpl$mu)) / foi_v_eq
  beta_eq <- Sv_eq * (foi_v_eq + mpl$mu)
  
  res <- list(init_Sh = Sh_eq, init_Ih = Ih_eq, init_Sv = Sv_eq, init_Ev = Ev_eq,
              init_Iv = Iv_eq, init_beta = beta_eq)
  res <- append(res,mpl)
  
  return(res)
}