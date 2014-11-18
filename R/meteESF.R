
#' @title meteESF
#'  
#' @description \code{meteESF} Calculates the ``ecosystem structure
#' function'' which forms the core of the Maximum Entropy Theory of
#' Ecology
#'
#' @details
#' Uses either data or state variables to calculate the Ecosystem Structure 
#' Function (ESF). \code{power} need not be specified; if missing an arbitrarily
#'  large value is assigned to E0 (N0*1e5) such that it will minimally affect 
#'  estimation of Lagrange multipliers. Consider using sensitivity analysis to 
#'  confirm this assumption.
#' 
#' @param spp A vector of species names for each entry
#' @param abund A vector giving abundances of each entry
#' @param power A vector giving metabolic rates for each entry
#' @param S0 Total number of species
#' @param N0 Total number of individuals
#' @param E0 Total metabolic rate; defaults to N0*1e5 if not specified or 
#'        calculated from \code{power}
#' @param minE Minimum possible metabolic rate
#' @keywords lagrange multiplier, METE, MaxEnt, ecosystem structure function
#' @export
#' 
#' @examples
#' esf1=meteESF(spp=arth$spp,
#'               abund=arth$count,
#'               power=arth$mass^(.75),
#'               minE=min(arth$mass^(.75)))
#' @return An object of class \code{esf}
#'
#' @author Andy Rominger <ajrominger@@gmail.com>, Cory Merow
#  @note other junk to mention
# @seealso add pi
#' @references Harte, J. 2011. Maximum entropy and ecology: a theory of abundance, distribution, and energetics. Oxford University Press.
#  @aliases - a list of additional topic names that will be mapped to this documentation when the user looks them up from the command line.
#  @family - a family name. All functions that have the same family tag will be linked in the documentation.

meteESF <- function(spp, abund, power,
                    S0=NULL, N0=NULL, E0=N0*1e6,
                    minE) {
  ## case where spp (and abund) provided
  if(!missing(spp) & !missing(abund)) {
    ## factors will mess things up
    spp <- as.character(spp)
    
    ## if power missing, set large for numeric approx
    if(missing(power)) {
      power <- rep(1000, length(spp))
      power[1] <- 1 # do this so re-scaling by min still allows E0 big
      e.given <- FALSE # to determine if power should be
      # returned as data
    } else {
      e.given <- TRUE
    }
    
    ## account for possible aggregation of individuals
    if(any(abund > 1)) {
      spp <- rep(spp, abund)
      power <- rep(power, abund)
      abund <- rep(1, length(spp))
    }
    
    ## if no theoretical minimum metabolic rate set, set to min of
    ## data
    if(missing(minE)) minE <- min(power)
    power <- power/minE
    
    ## combine data, potentially e too if given
    dats <- data.frame(s=spp, n=abund)
    if(e.given) dats$e <- power
    
    ## calculate state variables from data
    S0 <- length(unique(spp))
    N0 <- sum(abund)
    E0 <- sum(power*abund)
    
  } else if(is.null(E0)) {
    E0 <- 10^5 # make very large so it has no effect
    e.given <- FALSE
    dats <- NULL
  } else {
    e.given <- TRUE
    dats <- NULL
  }
  
  ## if E0 given but no minE set it here to 1
  if(missing(minE)) minE <- 1
  
  ## calculate ecosystem structure funciton
  thisESF <- .makeESF(s0=S0, n0=N0, e0=E0)
  thisESF$emin <- minE
  
  ## include data if applicable
  if(exists('dats')) thisESF$data <- dats
  
  ## to be output
  out <- thisESF # needs to be `thisESF' so that data element is only
  # returned only if actual data were given
  
  ## remove E0 state variable if it was in fact not given
  if(!e.given) out$state.var['E0'] <- NA
  
  ## make returned object of class METE
  class(out) <- 'meteESF'
  
  return(out)
}

#=============================================================================
.makeESF <- function(s0,n0,e0) {
  esf.par <- .mete.lambda(s0,n0,e0)
  esf.par.info <- esf.par[-1]
  esf.par <- esf.par[[1]]
  
  names(esf.par) <- c("la1","la2")
  
  thisZ <- .meteZ(esf.par["la1"],esf.par["la2"],s0,n0,e0)
  
  return(list(La=esf.par,La.info=esf.par.info,Z=thisZ,state.var=c(S0=s0,N0=n0,E0=e0)))
}


#===========================================================================
.mete.lambda <- function(S0, N0, E0) {
  ## reasonable starting values
  init.la2 <- S0/(E0-N0)
  beta.guess <- 0.01
  
  init.beta <- nlm(function(b) {
    ## options set to surpress warning messages just for optimization
    orig.warn <- options(warn=-1)
    
    out <- (b*log(1/b) - 1/2^8)^2
    
    return(out)
  }, p=0.001)
  
  if(init.beta$code < 4) {	# was there some level of convergence?
    init.beta <- init.beta$estimate
  } else {
    init.beta <- beta.guess
  }
  
  init.la1 <- init.beta - init.la2
  
  ## the solution
  la.sol <- nleqslv::nleqslv(x=c(la1 = init.la1, la2 = init.la2), 
                    fn = .la.syst2, S0=S0,N0=N0,E0=E0)
  
  return(list(lambda=c(la1=la.sol$x[1], la2=la.sol$x[2]), 
              syst.vals=la.sol$fvec, converg=la.sol$termcd,
              mesage=la.sol$message, nFn.calc=la.sol$nfcnt, nJac.calc=la.sol$njcnt))
}

#==========================================================================
.la.syst2 <- function(La, S0, N0, E0) {
  ## options set to surpress warning messages just for optimization
  orig.warn <- options(warn=-1)
  
  ## params
  b <- La[1] + La[2]
  s <- La[1] + E0*La[2]
  
  n <- 1:N0
  
  ## expressions
  g.bn <- exp(-b*n)
  g.sn <- exp(-s*n)
  
  univ.denom <- sum((g.bn - g.sn)/n)
  rhs.7.19.num <- sum(g.bn - g.sn)
  rhs.7.20.num <- sum(g.bn - E0*g.sn)
  
  ##  the two functions to solve
  f <- rep(NA, 2)
  f[1] <- rhs.7.19.num/univ.denom - N0/S0
  f[2] <- (1/La[2]) + rhs.7.20.num/univ.denom - E0/S0
  
  ## return warning behavior to original
  options(warn=orig.warn$warn)
  
  return(f)
}

#
#tryS0 <- 64
#tryN0 <- 2^4*tryS0
#tryE0 <- 2^10*tryN0
#mete.lambda(tryS0,tryN0,tryE0)

#===========================================================================
##  function to return Z, the normalizing constant of R as well as
##	the simplifying parameters beta and sigma

.meteZ <- function(la1,la2,S0,N0,E0) {
  beta <- la1 + la2
  sigma <- la1 + E0*la2
  
  t1 <- S0/(la2*N0)
  t2 <- (exp(-beta) - exp(-beta*(N0+1)))/(1-exp(-beta))
  t3 <- (exp(-sigma) - exp(-sigma*(N0+1)))/(1-exp(-sigma))
  
  Z <- t1*(t2 - t3)
  
  return(Z)
}


