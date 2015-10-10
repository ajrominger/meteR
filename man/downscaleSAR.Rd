% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/sar.R
\name{downscaleSAR}
\alias{downscaleSAR}
\title{Downscale the species area relationship (SAR)}
\usage{
downscaleSAR(x, A, A0, EAR = FALSE)
}
\arguments{
\item{x}{an object of class meteESF}

\item{A}{}

\item{A0}{}

\item{EAR}{logical. TRUE computes the endemics-area relatinship}
}
\value{
list
}
\description{
Downscale the species area relationship (SAR)
}
\examples{
esf=meteESF(spp=anbo$spp,
             abund=anbo$count)
}
\author{
Andy Rominger <ajrominger@gmail.com>, Cory Merow
}
\references{
Harte, J. 2011. Maximum entropy and ecology: a theory of abundance, distribution, and energetics. Oxford University Press.
}
