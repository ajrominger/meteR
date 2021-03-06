% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meteESF.R
\name{predictESF}
\alias{predictESF}
\title{predictESF}
\usage{
predictESF(esf, abund, power)
}
\arguments{
\item{esf}{A fitted object of class \code{meteESF}}

\item{abund}{A vector of abundances}

\item{power}{A vector of metabolic rates}
}
\value{
a data.frame with abundance, power, and the predicted value of the ESF
}
\description{
\code{predict} predicts the probabilities for given combinations of abundance and energ from the  ``ecosystem structure
function'' \eqn{R(n,\epsilon)}
}
\details{
Uses a fitted object of class \code{meteESF} and user supplied values of abundance and power to predict values of the ESF
}
\examples{
## case where complete data availible
esf1 <- meteESF(spp=arth$spp,
                abund=arth$count,
                power=arth$mass^(.75),
                minE=min(arth$mass^(.75)))
predictESF(esf1,
           abund=c(10,3),
           power=c(.01,3))

}
\author{
Andy Rominger <ajrominger@gmail.com>, Cory Merow
}
\references{
Harte, J. 2011. Maximum entropy and ecology: a theory of abundance, distribution, and energetics. Oxford University Press.
}
\seealso{
meteESF
}
\keyword{METE,}
\keyword{MaxEnt,}
\keyword{ecosystem}
\keyword{function}
\keyword{lagrange}
\keyword{multiplier,}
\keyword{structure}

