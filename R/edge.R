#' Sobel filter
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @param balp Whether to remove black background.
#' @param dx The direction of Sobel filter.
#' @param dy The direction of Sobel filter.
#' @param border The type of pixel extrapolation method.
#' @param use_rgb Whether to use RGB Sobel filter.
#' @param scale The scale of Sobel filter.
#' @param delta The delta of Sobel filter.
#' @returns A raw vector of PNG image.
#' @export
sobel_filter <- function(png, ksize = 3,
                         balp = TRUE,
                         dx = 1, dy = dx,
                         border = c(3, 4, 0, 1, 2),
                         use_rgb = TRUE,
                         scale = 1.0,
                         delta = 0.0) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    azny_sobelrgb(png, ksize, balp, dx, dy, border, scale, delta)
  } else {
    azny_sobelfilter(png, ksize, balp, dx, dy, border, scale, delta)
  }
}

laplacian_filter <- function() {}

canny_filter <- function() {}
