#' Diffusion filter
#'
#' @param nr A `nativeRaster` object.
#' @param factor,offset The parameters of diffusion.
#' @param iter The iteration of diffusion step.
#' @param gamma A numeric scalar. The gamma value for preprocessing.
#' @param sigma A numeric scalar.
#' The sigma of gaussian blur for preprocessing.
#' @returns A `nativeRaster` object.
#' @export
diffusion_filter <- function(
  nr,
  factor = 5,
  offset = 0.1,
  iter = 3,
  gamma = 1.3,
  sigma = 2
) {
  out <- azny_diffusion(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    iter,
    factor,
    offset,
    gamma,
    sigma
  )
  as_nr(out)
}
