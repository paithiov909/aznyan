#' Median blur
#'
#' @param png A raw vector of PNG image.
#' @param ksize The size of kernel.
#' @returns A raw vector of PNG image.
#' @export
median_blur <- function(png, ksize = 1) {
  out <- azny_medianblur(as.integer(png), nrow(png), ncol(png), ksize)
  class(out) <- c("nativeRaster", class(out))
  out
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
                     box_w = 1, box_h = box_w,
                     normalize = TRUE,
                     border = c(3, 4, 0, 1, 2)) {
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
                          box_w = 1, box_h = box_w,
                          sigma_x = 0, sigma_y = sigma_x,
                          border = c(3, 4, 0, 1, 2)) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_gaussianblur(png, box_w, box_h, sigma_x, sigma_y, border)
}

#' Bilateral filter
#'
#' @param png A raw vector of PNG image.
#' @param d The size of kernel.
#' @param sigmacolor The sigma of color.
#' @param sigmaspace The sigma of space.
#' @param border The type of pixel extrapolation method.
#' @param alphasync Whether sync alpha.
#' @returns A raw vector of PNG image.
#' @export
bilateral_filter <- function(png,
                             d = 5,
                             sigmacolor = 1, sigmaspace = 1,
                             border = c(3, 4, 0, 1, 2),
                             alphasync = TRUE) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  azny_bilateralblur(png, d, sigmacolor, sigmaspace, border, alphasync)
}
