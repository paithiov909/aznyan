#' Conversion between RGB and HLS color spaces
#'
#' @param x An integer matrix with 3 rows.
#' @returns An integer matrix of the same size as `x`
#' @rdname rgb-hls
#' @name rgb-hls
NULL

#' @rdname rgb-hls
#' @export
rgb2hls <- function(x) azny_rgb_to_hls(floor(x))

#' @rdname rgb-hls
#' @export
hls2rgb <- function(x) azny_hls_to_rgb(floor(x))

#' Create a native raster filled with a color
#'
#' @param color Color name or hex code.
#' @param width,height A positive integer scalar.
#' @returns A `nativeRaster` object.
#' @export
fill_with <- function(color, width, height) {
  packed_int <- colorfast::col_to_int(color[1])
  out <- matrix(packed_int, nrow = height, ncol = width)
  as_nr(out)
}

#' Color manipulation
#'
#' @param nr A `nativeRaster` object.
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
brighten <- function(nr, intensity) {
  # sz <- dim(nr)
  # ret <- nr_to_rgba(nr, "nr")
  # rgb <- clamp(ret[1:3, ] * (1 + intensity), 0, 255)
  # as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
  as_nr(azny_brighten(nr, nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
contrast <- function(nr, intensity) {
  # sz <- dim(nr)
  # ret <- nr_to_rgba(nr, "nr")
  # rgb <- clamp((ret[1:3, ] / 255 - 0.5) * (1 + intensity) + 0.5, 0, 1) * 255
  # as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
  as_nr(azny_contrast(nr, nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
duotone <- function(nr, color_a = "yellow", color_b = "navy", gamma = 2.2) {
  color_a <- colorfast::col_to_rgb(color_a[1])
  color_b <- colorfast::col_to_rgb(color_b[1])
  as_nr(
    azny_duotone(
      nr,
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
  as_nr(azny_grayscale(nr, nrow(nr), ncol(nr)))
}

#' @rdname color-manip
#' @export
hue_rotate <- function(nr, rad) {
  as_nr(azny_hue_rotate(nr, nrow(nr), ncol(nr), rad))
}

#' @rdname color-manip
#' @export
invert <- function(nr) {
  as_nr(azny_invert(nr, nrow(nr), ncol(nr)))
}

#' @rdname color-manip
#' @export
linocut <- function(nr, ink = "navy", paper = "snow", threshold = 0.4) {
  ink <- colorfast::col_to_rgb(ink[1])
  paper <- colorfast::col_to_rgb(paper[1])
  as_nr(
    azny_linocut(
      nr,
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
  as_nr(azny_posterize(nr, nrow(nr), ncol(nr), shades))
}

#' @rdname color-manip
#' @export
reset_alpha <- function(nr, alpha = 1) {
  as_nr(azny_reset_alpha(nr, nrow(nr), ncol(nr), alpha))
}

#' @rdname color-manip
#' @export
saturate <- function(nr, intensity) {
  as_nr(azny_saturate(nr, nrow(nr), ncol(nr), intensity))
}

#' @rdname color-manip
#' @export
sepia <- function(nr, intensity, depth = 20) {
  as_nr(azny_sepia(nr, nrow(nr), ncol(nr), intensity, depth))
}

#' @rdname color-manip
#' @export
set_matte <- function(nr, color = "green") {
  rgb_int <- colorfast::col_to_rgb(color[1])
  as_nr(
    azny_set_matte(
      nr,
      nrow(nr),
      ncol(nr),
      as.integer(rgb_int[, 1])
    )
  )
}

#' @rdname color-manip
#' @export
solarize <- function(nr, threshold = 0.5) {
  as_nr(azny_solarize(nr, nrow(nr), ncol(nr), threshold))
}

#' @rdname color-manip
#' @export
unpremul <- function(nr, max = 255L) {
  as_nr(azny_unpremul(nr, nrow(nr), ncol(nr), max))
}
