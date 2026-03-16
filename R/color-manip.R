#' Color manipulation
#'
#' @param nr A `nativeRaster` object.
#' @param lut A 256x3 double matrix in range `[0, 255]`.
#' @param intensity A numeric scalar.
#' @param depth,shades A positive integer scalar.
#' @param gamma A numeric scalar. The gamma exponent.
#' @param rad A numeric scalar. The rotation angle in radians.
#' @param color,color_a,color_b,ink,paper A character string;
#'  color name or hex code.
#' @param alpha,threshold A numeric scalar in range `[0, 1]`.
#' @param max An integer scalar. The maximum value of the color code.
#' @returns A `nativeRaster` object.
#' @rdname color-manip
#' @name color-manip
NULL

#' @rdname color-manip
#' @export
apply_lut1d <- function(nr, lut) {
  if (!all(is.finite(lut)) || !all(lut >= 0) || !all(lut <= 255)) {
    cli::cli_abort("`lut` must be a double matrix in range [0, 255].")
  }
  as_nr(azny_lut1d(cast_nr(nr), nrow(nr), ncol(nr), lut))
}

#' @rdname color-manip
#' @export
brighten <- function(nr, intensity) {
  as_nr(azny_brighten(cast_nr(nr), nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
contrast <- function(nr, intensity) {
  as_nr(azny_contrast(cast_nr(nr), nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
duotone <- function(nr, color_a = "yellow", color_b = "navy", gamma = 2.2) {
  color_a <- colorfast::col_to_rgb(color_a[1])
  color_b <- colorfast::col_to_rgb(color_b[1])
  as_nr(
    azny_duotone(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      as.integer(color_a[, 1]),
      as.integer(color_b[, 1]),
      gamma
    )
  )
}

#' @rdname color-manip
#' @export
grayscale <- function(nr) {
  as_nr(azny_grayscale(cast_nr(nr), nrow(nr), ncol(nr)))
}

#' @rdname color-manip
#' @export
hue_rotate <- function(nr, rad) {
  as_nr(azny_hue_rotate(cast_nr(nr), nrow(nr), ncol(nr), rad))
}

#' @rdname color-manip
#' @export
invert <- function(nr) {
  as_nr(azny_invert(cast_nr(nr), nrow(nr), ncol(nr)))
}

#' @rdname color-manip
#' @export
linocut <- function(nr, ink = "navy", paper = "snow", threshold = 0.4) {
  ink <- colorfast::col_to_rgb(ink[1])
  paper <- colorfast::col_to_rgb(paper[1])
  as_nr(
    azny_linocut(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      as.integer(ink[, 1]),
      as.integer(paper[, 1]),
      threshold
    )
  )
}

#' @rdname color-manip
#' @export
posterize <- function(nr, shades = 4) {
  as_nr(azny_posterize(cast_nr(nr), nrow(nr), ncol(nr), shades))
}

#' @rdname color-manip
#' @export
reset_alpha <- function(nr, alpha = 1) {
  as_nr(azny_reset_alpha(cast_nr(nr), nrow(nr), ncol(nr), alpha))
}

#' @rdname color-manip
#' @export
saturate <- function(nr, intensity) {
  as_nr(azny_saturate(cast_nr(nr), nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
sepia <- function(nr, intensity, depth = 20) {
  as_nr(azny_sepia(cast_nr(nr), nrow(nr), ncol(nr), intensity, depth))
}

#' @rdname color-manip
#' @export
set_matte <- function(nr, color = "green") {
  rgb_int <- colorfast::col_to_rgb(color[1])
  as_nr(
    azny_set_matte(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      as.integer(rgb_int[, 1])
    )
  )
}

#' @rdname color-manip
#' @export
solarize <- function(nr, threshold = 0.5) {
  as_nr(azny_solarize(cast_nr(nr), nrow(nr), ncol(nr), threshold))
}

#' @rdname color-manip
#' @export
unpremul <- function(nr, max = 255L) {
  as_nr(azny_unpremul(cast_nr(nr), nrow(nr), ncol(nr), max))
}
