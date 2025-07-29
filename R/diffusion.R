#' Diffusion filter
#'
#' @param nr A `nativeRaster` object.
#' @param factor The factor of diffusion.
#' @param offset The offset of diffusion.
#' @param iter The iteration of diffusion.
#' @param gamma The gamma of diffusion.
#' @param sigma The sigma of diffusion.
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
