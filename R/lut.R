#' Apply a 3D LUT to a PNG image
#'
#' @note
#' This function is incomplete. The result seems incorrect at the moment.
#'
#' @param nr A `nativeRaster` object.
#' @param lut The path to the 3D LUT to apply.
#' @param is_r_fastest Whether the LUT is arranged in R-fastest order
#' ("x" is the fastest dimension and "z" is the slowest).
#' If `FALSE`, assumes it's B-fastest
#' ("x" is the slowest dimension and "z" is the fastest).
#' @param intensity This is for debugging purposes.
#' @returns A `nativeRaster` object.
#' @export
apply_cube <- function(nr, lut, is_r_fastest = TRUE, intensity = 1.0) {
  if (intensity < 0.0 || intensity > 1.0) {
    rlang::abort("`intensity` must be between 0.0 and 1.0")
  }
  lut <- as.matrix(lut)
  cube_size <- nrow(lut)^(1 / 3)
  out <- azny_apply_cube(cast_nr(nr), nrow(nr), ncol(nr), lut, as.integer(cube_size), intensity, is_r_fastest)
  as_nr(out)
}

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
