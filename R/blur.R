#' Median blur
#'
#' @param nr A `nativeRaster` object.
#' @param ksize The size of kernel.
#' @returns A `nativeRaster` object.
#' @export
median_blur <- function(nr, ksize = 1) {
  out <- azny_medianblur(as.integer(nr), nrow(nr), ncol(nr), ksize)
  enclass(out)
}

#' Box blur
#'
#' @param png A `nativeRaster` object.
#' @param box_w The width of box.
#' @param box_h The height of box.
#' @param normalize Whether normalize.
#' @param border The type of pixel extrapolation method.
#' @returns A `nativeRaster` object.
#' @export
box_blur <- function(
  nr,
  box_w = 1,
  box_h = box_w,
  normalize = TRUE,
  border = c(3, 4, 0, 1, 2)
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_boxblur(
    as.integer(nr),
    nrow(nr),
    ncol(nr),
    box_w,
    box_h,
    normalize,
    border
  )
  enclass(out)
}

#' Gaussian blur
#'
#' @param nr A `nativeRaster` object.
#' @param box_w The width of box.
#' @param box_h The height of box.
#' @param sigma_x The sigma of x.
#' @param sigma_y The sigma of y.
#' @param border The type of pixel extrapolation method.
#' @returns A `nativeRaster` object.
#' @export
gaussian_blur <- function(
  nr,
  box_w = 1,
  box_h = box_w,
  sigma_x = 0,
  sigma_y = sigma_x,
  border = c(3, 4, 0, 1, 2)
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_gaussianblur(
    as.integer(nr),
    nrow(nr),
    ncol(nr),
    box_w,
    box_h,
    sigma_x,
    sigma_y,
    border
  )
  enclass(out)
}

#' Bilateral filter
#'
#' @param nr A `nativeRaster` object.
#' @param d The size of kernel.
#' @param sigmacolor The sigma of color.
#' @param sigmaspace The sigma of space.
#' @param border The type of pixel extrapolation method.
#' @param alphasync Whether sync alpha.
#' @returns A `nativeRaster` object.
#' @export
bilateral_filter <- function(
  nr,
  d = 5,
  sigmacolor = 1,
  sigmaspace = 1,
  border = c(3, 4, 0, 1, 2),
  alphasync = TRUE
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_bilateralblur(
    as.integer(nr),
    nrow(nr),
    ncol(nr),
    d,
    sigmacolor,
    sigmaspace,
    border,
    alphasync
  )
  enclass(out)
}
