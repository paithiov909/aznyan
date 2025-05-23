% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/misc.R
\name{resize}
\alias{resize}
\title{Resize image}
\usage{
resize(
  png,
  wh = c(1, 1),
  resize_mode = c(1, 2, 3, 4, 5, 6, 0),
  set_size = FALSE
)
}
\arguments{
\item{png}{A raw vector of PNG image.}

\item{wh}{The width and height.}

\item{resize_mode}{The resize mode.}

\item{set_size}{Whether \code{wh} is actual width and height instead of coef.}
}
\description{
Resize image
}
