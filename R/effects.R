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
#'  components to use.
#'  Must be greater than `0`. Larger values capture more detail.
#' @param y_comps An integer scalar specifying the number of vertical DCT
#'  components to use.
#'  Must be greater than `0`. Larger values capture more detail.
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
#'  iteration. Larger values reduce the contribution of later diffusion steps.
#' @param offset A numeric scalar added to the iteration index when computing
#'  the decaying gain. Helps adjust the early-iteration weighting.
#' @param iter An integer scalar giving the number of diffusion iterations to
#'  perform. More iterations strengthen the smoothing and glow effects.
#' @param gamma A numeric scalar specifying the gamma exponent applied before
#'  diffusion (and inverted afterward). Values greater than `1` emphasize
#'  bright regions.
#' @param sigma An integer scalar giving the initial Gaussian blur radius
#'  (converted to a standard deviation internally). The value is squared on
#'  each iteration, producing progressively wider diffusion.
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

#' Modulation filter
#'
#' @description
#' Weaves short line segments across an image by scanning pixels and triggering
#' strokes based on accumulated luminance.
#'
#' This effect walks through the image in the selected `direction`.
#' At each pixel, luminance is accumulated and compared with `phase`.
#' When the threshold is reached,
#' a stroke event may start depending on `init` and `interval`,
#' and `step` pixels are drawn from `fg`; otherwise pixels are taken from `bg`.
#'
#' @param nr A `nativeRaster` object.
#' @param fg A `nativeRaster` object used as the foreground source
#'  for stroke pixels. It must have the same dimensions as `nr`.
#' @param bg A `nativeRaster` object used as the background source
#'  for non-stroke pixels. It must have the same dimensions as `nr`.
#' @param omega A positive numeric scalar scaling
#'  how fast luminance accumulates per pixel.
#' @param phase A positive numeric scalar giving the luminance threshold
#'  for triggering events.
#' @param init A positive integer scalar
#'  giving the number of stroke events to emit in one cycle.
#' @param interval A non-negative integer scalar
#'  giving the number of trigger events to skip between cycles.
#' @param step A non-negative integer scalar
#'  giving the stroke length in pixels for each event.
#' @param invert A logical scalar
#'  indicating whether bright pixels (instead of dark pixels)
#'  contribute more strongly to triggering.
#' @param direction An integer giving the scan direction
#'  * `3` = left-to-right
#'  * `0` = right-to-left
#'  * `1` = top-to-bottom
#'  * `2` = bottom-to-top
#' @returns A `nativeRaster` object.
#' @export
lineweave <- function(
  nr,
  fg = nr,
  bg = blurhash(nr, 3, 3),
  omega = 10,
  phase = 5,
  init = 1,
  interval = 1,
  step = 2,
  invert = FALSE,
  direction = c(3, 0, 1, 2)
) {
  check_nr_dim(nr, fg)
  check_nr_dim(nr, bg)
  if (init <= 0) {
    cli::cli_abort("`init` must be a positive integer.")
  }

  direction <- int_match(direction, "direction", c(0, 1, 2, 3))

  out <- azny_lineweave(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    omega,
    phase,
    as.integer(init),
    as.integer(interval),
    as.integer(step),
    invert,
    direction,
    cast_nr(fg, "fg"),
    cast_nr(bg, "bg")
  )
  as_nr(out)
}
