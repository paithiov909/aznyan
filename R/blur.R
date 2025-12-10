#' Blur filters
#'
#' @details
#' `border` refers to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param ksize,box_w,box_h A numeric scalar. The kernel size.
#' @param sigma_x,sigma_y A numeric scalar.
#' The standard deviation of the Gaussian kernel in X and Y direction.
#' If both are 0, they are computed from `ksize`.
#' @param normalize A logical scalar.
#' Whether the kernel is normalized by its area or not.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @returns A `nativeRaster` object.
#' @rdname blur
#' @name blur
NULL

#' @rdname blur
#' @export
median_blur <- function(nr, ksize = 1) {
  out <- azny_medianblur(cast_nr(nr), nrow(nr), ncol(nr), ksize)
  as_nr(out)
}

#' @rdname blur
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
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    box_w,
    box_h,
    normalize,
    border
  )
  as_nr(out)
}

#' @rdname blur
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
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    box_w,
    box_h,
    sigma_x,
    sigma_y,
    border
  )
  as_nr(out)
}

#' Bilateral filter
#'
#' Applies bilateral filtering to an image.
#' It can be used to reduce noise while keeping edges sharp.
#' However, it is very slow compared to most filters.
#'
#' @details
#' `border` refers to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param d An integer scalar.
#' Diameter of each pixel neighborhood that is used during filtering.
#' If it is non-positive, it is computed from `sigmaspace`.
#' @param sigmacolor A double scalar.
#' Filter sigma in the color space.
#' A larger value of the parameter means that farther colors
#' within the pixel neighborhood will be mixed together,
#' resulting in larger areas of semi-equal color.
#' @param sigmaspace A double scalar.
#' Filter sigma in the coordinate space.
#' A larger value of the parameter means
#' that farther pixels will influence each other
#' as long as their colors are close enough.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @param alphasync A logical scalar.
#' If `TRUE`, filtering is applied separately to the alpha channel.
#' @returns A `nativeRaster` object.
#' @export
bilateral_filter <- function(
  nr,
  d = 5,
  sigmacolor = 1,
  sigmaspace = 1,
  border = c(3, 4, 0, 1, 2),
  alphasync = FALSE
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_bilateralblur(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    d,
    sigmacolor,
    sigmaspace,
    border,
    alphasync
  )
  as_nr(out)
}

#' Convolution with a custom kernel
#'
#' @details
#' `border` refers to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param kernel A numeric matrix that represents a kernel.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @param alphasync A logical scalar.
#' If `TRUE`, filtering is applied separately to the alpha channel.
#' @returns A `nativeRaster` object.
#' @export
kernel_blur <- function(
  nr,
  kernel =  matrix(c(0, -1, 0, -1, 5, -1, 0, -1, 0), 3, 3),
  border = c(3, 4, 0, 1, 2),
  alphasync = FALSE
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_convolve(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    kernel,
    border,
    alphasync
  )
  as_nr(out)
}
