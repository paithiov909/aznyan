#' Read a 3D LUT file
#'
#' @param lut The path to cube LUT file.
#' @param verbose Whether to print debug messages.
#' @returns A data frame with columns `x`, `y` and `z`.
#' @export
read_cube <- function(lut, verbose = TRUE) {
  # Assuming it's a 3-channel, 3D cube
  d <- matrix(azny_read_cube(lut, verbose), ncol = 3, byrow = TRUE)
  ret <- as.data.frame(d)
  colnames(ret) <- c("x", "y", "z")
  class(ret) <- c("tbl_df", "tbl", class(ret))
  ret
}

#' Apply a 3D LUT to a PNG image
#'
#' @note
#' This function is incomplete. The result seems incorrect at the moment.
#'
#' @param png A raw vector of PNG image to apply the LUT to.
#' @param lut The path to the 3D LUT to apply.
#' @param is_r_fastest Whether the LUT is arranged in R-fastest order
#' ("x" is the fastest dimension and "z" is the slowest).
#' If `FALSE`, assumes it's B-fastest
#' ("x" is the slowest dimension and "z" is the fastest).
#' @param intensity This is for debugging purposes.
#' @returns A raw vector of PNG image.
#' @export
apply_cube <- function(png, lut, is_r_fastest = TRUE, intensity = 1.0) {
  stopifnot(
    intensity >= 0.0,
    intensity <= 1.0
  )
  lut <- as.matrix(lut)
  cube_size <- nrow(lut)^(1 / 3)
  azny_apply_cube(png, lut, as.integer(cube_size), intensity, is_r_fastest)
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

#' Matrices to convert between color spaces
#' @rdname conversion-mat
#' @name conversion-mat
NULL

#' @rdname conversion-mat
#' @export
M_Rec709_to_sRGB <- matrix( # nolint
  c(0.9154, 0.0762, 0.0000, 0.0414, 0.9586, 0.0000, 0.0115, 0.1188, 0.8697),
  ncol = 3, byrow = TRUE
)

#' @rdname conversion-mat
#' @export
M_sRGB_to_Rec709 <- matrix( # nolint
  c(1.2249, -0.2247, 0.0000, -0.0420, 1.0420, 0.0000, -0.0197, -0.0786, 1.0983),
  ncol = 3, byrow = TRUE
)
