% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lut.R
\name{apply_cube}
\alias{apply_cube}
\title{Apply a 3D LUT to a PNG image}
\usage{
apply_cube(png, lut, is_r_fastest = TRUE, intensity = 1)
}
\arguments{
\item{png}{A raw vector of PNG image to apply the LUT to.}

\item{lut}{The path to the 3D LUT to apply.}

\item{is_r_fastest}{Whether the LUT is arranged in R-fastest order
("x" is the fastest dimension and "z" is the slowest).
If \code{FALSE}, assumes it's B-fastest
("x" is the slowest dimension and "z" is the fastest).}

\item{intensity}{This is for debugging purposes.}
}
\value{
A raw vector of PNG image.
}
\description{
Apply a 3D LUT to a PNG image
}
\note{
This function is incomplete. The result seems incorrect at the moment.
}
