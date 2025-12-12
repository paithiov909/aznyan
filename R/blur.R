#' Blur filters
#'
#' @details
#' `border` corresponds to the OpenCV extrapolation types:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param ksize An integer scalar specifying the kernel size.
#' The actual kernel size becomes `2 * ksize + 1`.
#' @param box_w An integer scalar controlling the half-size of the kernel in
#' the horizontal direction. The actual kernel width becomes `2 * box_w - 1`.
#' @param box_h An integer scalar controlling the half-size of the kernel in
#' the vertical direction. Defaults to `box_w`. The actual kernel height
#' becomes `2 * box_h - 1`.
#' @param normalize A logical scalar
#' specifying whether the kernel is normalized by its area or not.
#' Defaults to `TRUE`.
#' @param sigma_x,sigma_y A numeric scalar giving the standard deviation of the
#' Gaussian kernel along the x-axis. A value of `0` lets OpenCV compute it
#' automatically from the kernel size.
#' @param border An integer scalar specifying the border-handling mode.
#' One of `0, 1, 2, 3, 4`, corresponding to OpenCV's border modes.
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

#' Convolution with a custom kernel
#'
#' Applies a custom convolution kernel to a `nativeRaster` image.
#' This function wraps OpenCV's `filter2D`,
#' allowing arbitrary linear filters
#' such as sharpening, blurring, or edge detection.
#' Optionally, the same convolution can be applied to the alpha channel.
#'
#' @details
#' `border` corresponds to the OpenCV extrapolation types:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param kernel A numeric matrix giving the convolution kernel.
#' Larger or weighted matrices can be used to define custom filters.
#' The matrix is  passed directly to OpenCV,
#' which normalizes nothing automatically.
#' @param border An integer scalar specifying the border-handling mode.
#' One of `0, 1, 2, 3, 4`, corresponding to OpenCV's border modes.
#' See package documentation for details.
#' @param alphasync A logical scalar.
#' If `TRUE`, the convolution is also applied to the alpha channel;
#' if `FALSE`, the alpha channel is preserved as-is.
#' @returns A `nativeRaster` object.
#' @export
convolve <- function(
  nr,
  kernel = matrix(c(0, -1, 0, -1, 5, -1, 0, -1, 0), 3, 3),
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

#' Softmax-guided edge-aware smoothing (Kuwahara-like)
#'
#' @description
#' This filter produces a painting-like, edge-aware smoothing effect inspired by
#' the Kuwahara filter, but it does *not* implement the classical four-region
#' Kuwahara algorithm.
#'
#' Instead, it estimates local variance using `kernel1` and
#' applies a softmax-like weighting (`exp(-beta * variance)`) to emphasize
#' smoother directions, then computes a weighted average using `kernel2`.
#' The method originates from the idea described in
#' <https://qiita.com/Cartelet/items/7773cd56c7ce016476d9>.
#'
#' @details
#' `border` corresponds to the OpenCV extrapolation types:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param kernel1 A numeric matrix used to compute local mean and variance.
#' @param kernel2 A numeric matrix used to compute the final weighted average.
#' @param beta A double scalar controlling the sharpness of softmax weighting.
#' Higher values make the filter more strongly directional.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @returns A `nativeRaster` object.
#' @export
kuwahara_filter <- function(
  nr,
  kernel1 = kernel_cone(7),
  kernel2 = kernel_cone(5),
  beta = 30,
  border = c(3, 4, 0, 1, 2)
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  out <- azny_kuwahara(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    kernel1,
    kernel2,
    beta,
    border
  )
  as_nr(out)
}

#' Bilateral filter
#'
#' Apply a bilateral filter to a `nativeRaster` image. This edge-preserving
#' smoothing technique reduces noise while retaining sharp boundaries by
#' considering both spatial distance and color similarity.
#'
#' @details
#' `border` corresponds to the OpenCV extrapolation types:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param d An integer scalar specifying the diameter of the pixel neighborhood
#' used for filtering. If set to a non-positive value, OpenCV computes the
#' diameter from the sigmas.
#' @param sigmacolor A numeric scalar giving the filter sigma in color space.
#' Larger values allow blending of pixels with greater color differences.
#' @param sigmaspace A numeric scalar giving the filter sigma in coordinate
#' space. Larger values increase the spatial extent of smoothing.
#' @param border An integer scalar specifying the border-handling mode.
#' One of `0, 1, 2, 3, 4`,
#' corresponding to OpenCV's bilateral filter border modes.
#' @param alphasync A logical scalar.
#' If `TRUE`, the same bilateral filter is applied to the alpha channel;
#' if `FALSE`, the alpha channel is preserved.
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
  out <- azny_bilateral(
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
