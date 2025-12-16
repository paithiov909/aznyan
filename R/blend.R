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
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- alpha(src, dst) * 255
  as_nr(azny_pack_integers(rgba[1:3, ], rgba[4, ], sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_darken <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgb <- pmin(src[1:3, ], dst[1:3, ]) * 1 ## coerce to doubles
  a <- alpha(src[4, ] / 255, dst[4, ] / 255) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_multiply <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- src[1:3, ] * dst[1:3, ] * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_colorburn <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(1 - (1 - dst[1:3, ]) / src[1:3, ], 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_lighten <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgb <- pmax(src[1:3, ], dst[1:3, ]) * 1 ## coerce to doubles
  a <- alpha(src[4, ] / 255, dst[4, ] / 255) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_screen <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(1 - (1 - dst[1:3, ]) * (1 - src[1:3, ]), 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_add <- function(src, dst) {
  ## linear dodge
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(src[1:3, ] + dst[1:3, ], 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_colordodge <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(dst[1:3, ] / (1 - src[1:3, ]), 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_hardlight <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(
    src[1:3, ] < 0.5,
    2 * src[1:3, ] * dst[1:3, ],
    1 - 2 * (1 - src[1:3, ]) * (1 - dst[1:3, ])
  ) |>
    clamp(0, 1) *
    255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_softlight <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(
    src[1:3, ] < 0.5,
    (1 - 2 * src[1:3, ]) * (dst[1:3, ]^2) + 2 * dst[1:3, ] * src[1:3, ],
    2 * dst[1:3, ] * (1 - src[1:3, ]) + sqrt(dst[1:3, ]) * (2 * src[1:3, ] - 1)
  ) |>
    clamp(0, 1) *
    255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_overlay <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(
    dst[1:3, ] < 0.5,
    2 * src[1:3, ] * dst[1:3, ],
    1 - (2 * (1 - src[1:3, ]) * (1 - dst[1:3, ]))
  ) |>
    clamp(0, 1) *
    255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_hardmix <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(src[1:3, ] <= (1 - dst[1:3, ]), 0, 255)
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_linearlight <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(dst[1:3, ] + (2 * src[1:3, ]) - 1, 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_vividlight <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(
    src[1:3, ] < 0.5,
    1 - (1 - dst[1:3, ]) / (2 * src[1:3, ]),
    dst[1:3, ] / (2 * (1 - src[1:3, ]))
  ) |>
    clamp(0, 1) *
    255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_pinlight <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ifelse(
    dst[1:3, ] < 0.5,
    pmin(src[1:3, ], 2 * dst[1:3, ]) * 1,
    pmax(src[1:3, ], 2 * (dst[1:3, ] - 0.5)) * 1
  ) |>
    clamp(0, 1) *
    255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_average <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- ((dst[1:3, ] + src[1:3, ]) / 2) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_exclusion <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- (src[1:3, ] + dst[1:3, ] - 2 * src[1:3, ] * dst[1:3, ]) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_difference <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- abs(dst[1:3, ] - src[1:3, ]) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_divide <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(dst[1:3, ] / src[1:3, ], 0, 1) * 255 ## divide by zero -> `Inf`
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_subtract <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgb <- clamp(dst[1:3, ] - src[1:3, ], 0, 1) * 255
  a <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_luminosity <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgb <- clamp(gray(src[1:3, ]) + (dst[1:3, ] / 255) - gray(dst[1:3, ]), 0, 1) *
    255
  a <- alpha(src[4, ] / 255, dst[4, ] / 255) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_ghosting <- function(src, dst) {
  check_nr_dim(src, dst)
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgb <- clamp(
    gray(dst[1:3, ]) -
      gray(src[1:3, ]) +
      (dst[1:3, ] / 255) +
      (src[1:3, ] / 255) / 5,
    0,
    1
  ) *
    255
  a <- alpha(src[4, ] / 255, dst[4, ] / 255) * 255
  as_nr(azny_pack_integers(rgb, a, sz[1], sz[2]))
}
