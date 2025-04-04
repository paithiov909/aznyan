#' Diffusion filter
#'
#' @param png A raw vector of PNG image.
#' @param factor The factor of diffusion.
#' @param offset The offset of diffusion.
#' @param iter The iteration of diffusion.
#' @param gamma The gamma of diffusion.
#' @param sigma The sigma of diffusion.
#' @returns A raw vector of PNG image.
#' @export
diffusion_filter <- function(png,
                             factor = 5, offset = 0.1,
                             iter = 3,
                             gamma = 1.3,
                             sigma = 2) {
  azny_diffusion(png, iter, factor, offset, gamma, sigma)
}
