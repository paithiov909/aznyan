#' Edge extraction
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
#' @param ksize An integer scalar.
#' The size of kernel.
#' @param asize An integer scalar.
#' The size of aperture for Sobel operation.
#' @param balp A logical scalar.
#' If `TRUE`, resets transparency by thresholding.
#' @param use_rgb A logical scalar.
#' If `TRUE`, extracts edges separately for each color channel
#' and combines them.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @param dx,dy An integer scalar.
#' Order of derivative for Sobel filter.
#' @param thres1,thres2 A numeric scalar.
#' Thresholds for the hysteresis procedure.
#' @param grad A logical scalar.
#' Flag to be passed to `L2gradient`.
#' @param scale,delta A numeric scalar.
#' Optional parameters.
#' @returns A `nativeRaster` object.
#' @rdname edge-extract
#' @name edge-extract
NULL

#' @rdname edge-extract
#' @export
sobel_filter <- function(
  nr,
  ksize = 3,
  balp = TRUE,
  use_rgb = TRUE,
  border = c(3, 4, 0, 1, 2),
  dx = 1,
  dy = dx,
  scale = 1.0,
  delta = 0.0
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    out <- azny_sobelrgb(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      ksize,
      balp,
      dx,
      dy,
      border,
      scale,
      delta
    )
  } else {
    out <- azny_sobelfilter(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      ksize,
      balp,
      dx,
      dy,
      border,
      scale,
      delta
    )
  }
  as_nr(out)
}

#' @rdname edge-extract
#' @export
laplacian_filter <- function(
  nr,
  ksize = 3,
  balp = TRUE,
  use_rgb = TRUE,
  border = c(3, 4, 0, 1, 2),
  scale = 1.0,
  delta = 0.0
) {
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))
  if (use_rgb) {
    out <- azny_laplacianrgb(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      ksize,
      balp,
      border,
      scale,
      delta
    )
  } else {
    out <- azny_laplacianfilter(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      ksize,
      balp,
      border,
      scale,
      delta
    )
  }
  as_nr(out)
}

#' @rdname edge-extract
#' @export
canny_filter <- function(
  nr,
  asize = 2,
  balp = FALSE,
  use_rgb = TRUE,
  thres1 = 100.0,
  thres2 = 200.0,
  grad = TRUE
) {
  if (use_rgb) {
    out <- azny_cannyrgb(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      asize,
      balp,
      grad,
      thres1,
      thres2
    )
  } else {
    out <- azny_cannyfilter(
      cast_nr(nr),
      nrow(nr),
      ncol(nr),
      asize,
      balp,
      grad,
      thres1,
      thres2
    )
  }
  as_nr(out)
}
