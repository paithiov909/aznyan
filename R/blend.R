#' Blend modes
#'
#' Blends two `nativeRaster` objects with the specified blend mode.
#'
#' @param src,dst A `nativeRaster` object.
#' @returns A `nativeRaster` object.
#' @rdname blend
#' @name blend-mode
NULL

#' Clip values between `min` and `max`
#'
#' @param x numerics
#' @param min,max numeric scalar
#' @returns numerics
#' @noRd
clamp <- function(x, min, max) {
  pmin(pmax(x, min), max)
}

#' Lerp
#'
#' @param x,y numerics
#' @param mask numeric scalar
#' @returns numerics
#' @noRd
mix <- function(x, y, mask) {
  mask <- clamp(mask, 0, 1)
  x * mask + y * (1 - mask)
}

#' Step
#'
#' @param x,y numerics
#' @param mask numeric scalar
#' @returns numerics
#' @noRd
step <- function(x, mask) {
  (x > mask) * 1
}

#' Alpha blending
#'
#' @param x1,x2 Alpha values.
#' @returns doubles
#' @noRd
alpha <- function(x1, x2) {
  clamp(x1 + x2 * (1 - x1), 0, 1)
}

#' NTSC grayscale
#'
#' @param x 3-channel matrix
#' @returns doubles
#' @noRd
gray <- function(x) {
  x <- x * c(0.299, 0.587, 0.114)
  x / 255
}

#' @rdname blend
#' @export
blend_over <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_over(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_darken <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_darken(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_multiply <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_multiply(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_colorburn <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_colorburn(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_lighten <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_lighten(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_screen <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_screen(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_add <- function(src, dst) {
  ## linear dodge
  check_nr_dim(src, dst)
  as_nr(azny_blend_add(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_colordodge <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_colordodge(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_hardlight <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_hardlight(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_softlight <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_softlight(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_overlay <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_overlay(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_hardmix <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_hardmix(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_linearlight <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_linearlight(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_vividlight <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_vividlight(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_pinlight <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_pinlight(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_average <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_average(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_exclusion <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_exclusion(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_difference <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_difference(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_divide <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_divide(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_subtract <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_subtract(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_luminosity <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_luminosity(src, dst, nrow(src), ncol(src)))
}

#' @rdname blend
#' @export
blend_ghosting <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_ghosting(src, dst, nrow(src), ncol(src)))
}
