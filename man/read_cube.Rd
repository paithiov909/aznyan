% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lut-io.R
\name{read_cube}
\alias{read_cube}
\title{Read a 3D LUT file}
\usage{
read_cube(file, verbose = TRUE)
}
\arguments{
\item{file}{The path to a LUT file.
Currently supports \code{.cube} and \code{.smcube} files.}

\item{verbose}{Whether to print debug messages.}
}
\value{
A data frame with columns \code{x}, \code{y} and \code{z}.
}
\description{
Reads a 3D LUT file and returns its data points as a data frame.
This function supports 3D, 3-channel LUTs only.
}
\seealso{
\href{https://github.com/aras-p/smol-cube}{aras-p/smol-cube}
}
