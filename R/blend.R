#' Blend modes
#'
#' Blends two `nativeRaster` objects with the specified blend mode.
#'
#' @param src,dst A `nativeRaster` object.
#' @returns A `nativeRaster` object.
#' @rdname blend
#' @name blend-mode
NULL

#' @rdname blend
#' @export
blend_alpha <- function(src, dst) {
  check_nr_dim(src, dst)
  as_nr(azny_blend_alpha(src, dst, nrow(src), ncol(src)))
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
