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
  out <- rep_len(packed_int, width * height)
  dim(out) <- c(height, width)
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
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- clamp(ret[1:3, ] * (1 + intensity), 0, 255)
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
duotone <- function(nr, color_a = "yellow", color_b = "navy", gamma = 2.2) {
  sz <- dim(nr)
  color_a <- fill_with(sz[1], sz[2], color_a) |> nr_to_rgba("color_a")
  color_b <- fill_with(sz[1], sz[2], color_b) |> nr_to_rgba("color_b")
  ret <- nr_to_rgba(nr, "nr")
  luminance <- clamp(gray(ret[1:3, ])^(1 / gamma), 0, 1)
  rgb <- mix(color_a[1:3, ], color_b[1:3, ], luminance)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
grayscale <- function(nr) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- t(colSums(ret[1:3, ]) / 3) %x% c(1, 1, 1)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
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
invert <- function(nr) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- 255 - ret[1:3, ]
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
linocut <- function(nr, ink = "navy", paper = "snow", threshold = 0.4) {
  sz <- dim(nr)
  ink <- fill_with(sz[1], sz[2], ink) |> nr_to_rgba("ink")
  paper <- fill_with(sz[1], sz[2], paper) |> nr_to_rgba("paper")
  ret <- nr_to_rgba(nr, "nr")
  luminance <- step(gray(ret[1:3, ]), threshold)
  rgb <- mix(paper[1:3, ], ink[1:3, ], luminance)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
posterize <- function(nr, shades = 4) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- floor(ret[1:3, ] / 255 * shades) / as.integer(shades - 1)
  as_nr(azny_pack_integers(rgb * 255, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
reset_alpha <- function(nr, alpha = 1) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  ret[4, ] <- clamp(alpha * 255, 0, 255)
  as_nr(azny_pack_integers(ret[1:3, ], ret[4, ], sz[1], sz[2]))
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
sepia <- function(nr, intensity, depth = 20) {
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

#' @rdname color-manip
#' @export
set_matte <- function(nr, color = "green") {
  rgb_int <-
    grDevices::col2rgb(color[1], alpha = FALSE)
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  ret[1, ][ret[4, ] != 255] <- rgb_int[1, ] * 1
  ret[2, ][ret[4, ] != 255] <- rgb_int[2, ] * 1
  ret[3, ][ret[4, ] != 255] <- rgb_int[3, ] * 1
  as_nr(azny_pack_integers(ret[1:3, ], ret[4, ], sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
solarize <- function(nr, threshold = 0.5) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  intensity <- colSums(ret[1:3, ] / 255) / 3
  rgb <- ifelse(intensity > threshold, 255 - ret[1:3, ], ret[1:3, ])
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}

#' @rdname color-manip
#' @export
unpremul <- function(nr, max = 255L) {
  sz <- dim(nr)
  ret <- nr_to_rgba(nr, "nr")
  rgb <- ret[1:3, ] / (ret[4, ] / max)
  as_nr(azny_pack_integers(rgb, ret[4, ] * 1, sz[1], sz[2]))
}
