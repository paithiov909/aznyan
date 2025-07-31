#' Blend modes
#'
#' @param dst A `nativeRaster` object.
#' @param src A `nativeRaster` object.
#' @returns A `nativeRaster` object.
#' @rdname blend
#' @name blend
NULL

#' Cast native raster into 4*(w*h)-dimensional integer matrix
#' @importFrom colorfast col_to_rgb int_to_col
#' @noRd
nr_to_rgba <- function(nr, nm) {
  cast_nr(nr, nm) |>
    int_to_col() |>
    col_to_rgb()
}

#' @noRd
clamp <- function(x, min, max) {
  pmin(pmax(x, min), max)
}

#' Alpha blending
#' @param x1,x2 Alpha values.
#' @param cap Maximum alpha value.
#' @noRd
alpha <- function(x1, x2, cap = 1) {
  x1 + x2 - (cap - x1)
}

#' NTSC (luma only)
#' @noRd
gray <- function(x) {
  x[1:3, ] <- x[1:3, ] * c(0.299, 0.587, 0.114)
  x / 255
}

#' @rdname blend
#' @export
blend_darken <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgba <- pmin(src, dst) * 1 ## coerce to doubles
  rgba[4, ] <- alpha(src[4, ], dst[4, ], cap = 255)
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_multiply <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- src * dst * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_colorburn <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(1 - (1 - dst) / src, 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_lighten <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgba <- pmax(src, dst) * 1 ## coerce to doubles
  rgba[4, ] <- alpha(src[4, ], dst[4, ], cap = 255)
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_screen <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- (1 - (1 - dst) * (1 - src)) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_add <- function(src, dst) { ## linear dodge
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(src + dst, 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_colordodge <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(dst / (1 - src), 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_hardlight <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(src < 0.5,
    2 * src * dst,
    1 - 2 * (1 - src) * (1 - dst)
  ) |>
    clamp(0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_softlight <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(src < 0.5,
    (1 - 2 * src) * (dst^2) + 2 * dst * src,
    2 * dst * (1 - src) + sqrt(dst) * (2 * src - 1)
  ) |>
    clamp(0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_overlay <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(dst < 0.5,
    2 * src * dst,
    1 - (2 * (1 - src) * (1 - dst))
  ) |>
    clamp(0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_hardmix <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(src <= (1 - dst), 0, 255)
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_linearlight <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(dst + (2 * src) - 1, 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_vividlight <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(src < 0.5,
    1 - (1 - dst) / (2 * src),
    dst / (2 * (1 - src))
  ) |>
    clamp(0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_pinlight <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ifelse(dst < 0.5,
    pmin(src, 2 * dst) * 1,
    pmax(src, 2 * (dst - 0.5)) * 1
  ) |>
    clamp(0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_average <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- ((dst + src) / 2) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_exclusion <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- (src + dst - 2 * src * dst) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_difference <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- abs(dst - src) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_divide <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(dst / src, 0, 1) * 255 ## divide by zero -> `Inf`
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_subtract <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src") / 255
  dst <- nr_to_rgba(dst, "dst") / 255
  rgba <- clamp(dst - src, 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ]) * 255
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_luminosity <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgba <- clamp(gray(src) + (dst / 255) - gray(dst), 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ], cap = 255)
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}

#' @rdname blend
#' @export
blend_ghosting <- function(src, dst) {
  if (!identical(dim(src), dim(dst))) {
    rlang::abort("`src` and `dst` must have the same dimensions.")
  }
  sz <- dim(src)
  src <- nr_to_rgba(src, "src")
  dst <- nr_to_rgba(dst, "dst")
  rgba <- clamp(gray(dst) - gray(src) + (dst / 255) + (src / 255) / 5, 0, 1) * 255
  rgba[4, ] <- alpha(src[4, ], dst[4, ], cap = 255)
  as_nr(azny_pack_integers(rgba, sz[1], sz[2]))
}
