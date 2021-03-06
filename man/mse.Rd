% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/residuals.meteDist.R
\name{mse}
\alias{mse}
\alias{mse.meteDist}
\title{Computes mean squared error for rank or cdf}
\usage{
mse(x, ...)

\method{mse}{meteDist}(x, type = c("rank", "cumulative"), relative = TRUE,
  log = FALSE, ...)
}
\arguments{
\item{x}{a \code{meteDist} object}

\item{...}{arguments to be passed to methods}

\item{type}{'rank' or 'cumulative'}

\item{relative}{logical; if true use relative MSE}

\item{log}{logical; if TRUE calculate MSE on logged distirbution. If FALSE use arithmetic scale.}
}
\value{
numeric; the value of the mean squared error.
}
\description{
\code{mse.meteDist} computes mean squared error for rank or cdf between METE prediction and data
}
\details{
See Examples.
}
\examples{
data(arth)
esf1 <- meteESF(spp=arth$spp,
                abund=arth$count,
                power=arth$mass^(.75),
                minE=min(arth$mass^(.75)))
sad1 <- sad(esf1)
mse(sad1, type='rank', relative=FALSE)
ebar1 <- ebar(esf1)
mse(ebar1)

}
\author{
Andy Rominger <ajrominger@gmail.com>, Cory Merow
}
\references{
Harte, J. 2011. Maximum entropy and ecology: a theory of abundance, distribution, and energetics. Oxford University Press.
}
\seealso{
mseZ.meteDist
}

