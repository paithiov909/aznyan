#' Median blur
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @returns A raw vector of PNG image.
#' @export
median_blur <- function(png, ksize) {
  azny_medianblur(png, ksize)
}

#' Box blur
#'
#' @param png A raw vector of PNG image.
#' @param box_w The width of box.
#' @param box_h The height of box.
#' @param normalize Whether normalize.
#' @param border The type of pixel extrapolation method.
#' @returns A raw vector of PNG image.
#' @export
box_blur <- function(png,
                     box_w, box_h = box_w,
                     normalize = TRUE,
                     border = c(4, 0, 1, 2, 3)) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_boxblur(png, box_w, box_h, normalize, border)
}

#' Gaussian blur
#'
#' @param png A raw vector of PNG image.
#' @param box_w The width of box.
#' @param box_h The height of box.
#' @param sigma_x The sigma of x.
#' @param sigma_y The sigma of y.
#' @param border The type of pixel extrapolation method.
#' @returns A raw vector of PNG image.
#' @export
gaussian_blur <- function(png,
                          box_w, box_h = box_w,
                          sigma_x, sigma_y = sigma_x,
                          border = c(4, 0, 1, 2, 3)) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_gaussianblur(png, box_w, box_h, sigma_x, sigma_y, border)
}
