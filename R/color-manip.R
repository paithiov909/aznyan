#' Gamma and inverse gamma in 'Rec.709' color space
#'
#' @param x A numeric vector.
#' @returns A numeric vector.
#' @rdname rec709
#' @name rec709
NULL

#' @rdname rec709
#' @export
decode_rec709 <- function(x) azny_decode_rec709(x)

#' @rdname rec709
#' @export
encode_rec709 <- function(x) azny_encode_rec709(x)

#' Conversion between RGB and HLS colors
#'
#' @param x An integer matrix with 3 rows.
#' @returns An integer matrix of the same size as `x`
#' @rdname rgb-hls
#' @name rgb-hls
NULL

#' @rdname rgb-hls
#' @export
rgb2hls <- function(x) azny_rgb_to_hls(x)

#' @rdname rgb-hls
#' @export
hls2rgb <- function(x) azny_hls_to_rgb(x)

#' Color manipulation
#'
#' @param nr A `nativeRaster` object.
#' @param intensity A numeric scalar.
#' @param depth An integer scalar.
#' @param alpha A numeric scalar in range `[0, 1]`.
#' Alpha value to be reset for transparency.
#' @param rad A numeric scalar. Rotation angle in radian.
#' @param max An integer scalar. The maximum value of the color code.
#' @returns A `nativeRaster` object.
#' @rdname color-manip
#' @name color-manip
NULL

#' @rdname color-manip
#' @export
unpremul <- function(nr, max = 255L) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- ret[1:3, ] / (ret[4, ] / max)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
restore_transparency <- function(nr, alpha = 1) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  ret[4, ] <- clamp(alpha * 255, 0, 255)
  as_nr(azny_pack_integers(ret[1:3, ], ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
hue_rotate <- function(nr, rad) {
  cosv <- cos(rad)
  sinv <- sin(rad)
  mat <- c(
    # Reds
    0.213 + cosv * 0.787 - sinv * 0.213,
    0.715 - cosv * 0.715 - sinv * 0.715,
    0.072 - cosv * 0.072 + sinv * 0.928,
    # Greens
    0.213 - cosv * 0.213 + sinv * 0.143,
    0.715 + cosv * 0.285 + sinv * 0.140,
    0.072 - cosv * 0.072 - sinv * 0.283,
    # Blues
    0.213 - cosv * 0.213 - sinv * 0.787,
    0.715 - cosv * 0.715 + sinv * 0.715,
    0.072 + cosv * 0.928 + sinv * 0.072
  )
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- rbind(
    mat[1] * ret[1, ] + mat[2] * ret[2, ] + mat[3] * ret[3, ],
    mat[4] * ret[1, ] + mat[5] * ret[2, ] + mat[6] * ret[3, ],
    mat[7] * ret[1, ] + mat[8] * ret[2, ] + mat[9] * ret[3, ]
  ) |>
    clamp(0, 255)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
contrast <- function(nr, intensity) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp((ret[1:3, ] / 255 - 0.5) * (1 + intensity) + 0.5, 0, 1) * 255
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
brighten <- function(nr, intensity) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp(ret[1:3, ] * (1 + intensity), 0, 255)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
saturate <- function(nr, intensity) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  hls <- rgb2hls(ret[1:3, ])
  hls[2, ] <- (azny_saturate_value(hls[2, ] / 255, intensity) * 255) |>
    clamp(0, 255) |>
    as.integer()
  rgb <- hls2rgb(hls)
  as_nr(azny_pack_integers(rgb * 1, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
grayscale <- function(nr) {
  # TODO: replace with cv::cvtColor
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- t(colSums(ret[1:3, ]) / 3) %x% c(1, 1, 1)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
sepia <- function(nr, intensity = 1, depth = 20) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- rbind(
    ret[1, ] + depth * 2,
    ret[2, ] + depth,
    colSums(ret[1:3, ]) / 3
  ) |>
    clamp(0, 255)
  rgb[3, ] <- clamp(rgb[3, ] - (rgb[3, ] * intensity), 0, 255)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' Create native raster filled with color
#'
#' @param width,height A positive integer scalar.
#' @param color Color name or hex code.
#' @returns A `nativeRaster` object.
#' @export
fill_with <- function(width, height, color) {
  packed_int <-
    grDevices::col2rgb(color[1], alpha = TRUE) |>
    rlang::as_function(
      ~ {
        x <- as.double(.)
        azny_pack_integers(x[1:3], x[4], 1, 1)
      }
    )()
  out <- rep(packed_int, width * height)
  dim(out) <- c(height, width)
  as_nr(out)
}
