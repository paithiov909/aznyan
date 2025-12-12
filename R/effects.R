#' BlurHash-style DCT reconstruction
#'
#' Reconstructs a low-frequency approximation of an image using a BlurHash-like
#' discrete cosine transform (DCT) basis.
#' The image is first converted to linear RGB,
#' projected onto a grid of cosine components,
#' and then reconstructed back into an sRGB image
#' using only the specified number of horizontal and vertical components.
#' This produces a smooth, compressed representation
#' capturing the coarse structure and color of the input.
#'
#' @param nr A `nativeRaster` object.
#' @param x_comps An integer scalar specifying the number of horizontal DCT
#' components to use.
#' Must be greater than `0`. Larger values capture more detail.
#' @param y_comps An integer scalar specifying the number of vertical DCT
#' components to use.
#' Must be greater than `0`. Larger values capture more detail.
#' @returns A `nativeRaster` object.
#' @export
blurhash <- function(nr, x_comps = 6, y_comps = 6) {
  out <- azny_blurhash(cast_nr(nr), nrow(nr), ncol(nr), x_comps, y_comps)
  as_nr(out)
}

#' Diffusion-based smoothing and enhancement
#'
#' Applies an iterative diffusion-style filter to a `nativeRaster` image.
#' This custom process repeatedly blurs a gamma-transformed version of the
#' image and accumulates the diffused values with a decaying gain factor.
#' The result is then inverse–gamma–corrected, producing a soft, glowy,
#' detail-enhancing effect reminiscent of multi-scale diffusion or
#' photographic bloom.
#'
#' @param nr A `nativeRaster` object.
#' @param factor A numeric scalar controlling the decay factor used at each
#' iteration. Larger values reduce the contribution of later diffusion steps.
#' @param offset A numeric scalar added to the iteration index when computing
#' the decaying gain. Helps adjust the early-iteration weighting.
#' @param iter An integer scalar giving the number of diffusion iterations to
#' perform. More iterations strengthen the smoothing and glow effects.
#' @param gamma A numeric scalar specifying the gamma exponent applied before
#' diffusion (and inverted afterward). Values greater than `1` emphasize
#' bright regions.
#' @param sigma An integer scalar giving the initial Gaussian blur radius
#' (converted to a standard deviation internally). The value is squared on
#' each iteration, producing progressively wider diffusion.
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
