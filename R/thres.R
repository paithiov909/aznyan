#' Image thresholding
#'
#' @description
#' Applies thresholding to an image.
#'
#' For `thres`, `mode` is an integer scalar in range `[0, 6]` corresponding to:
#'
#' 0. cv::THRESH_BINARY
#' 1. cv::THRESH_BINARY_INV
#' 2. cv::THRESH_TRUNC
#' 3. cv::THRESH_TOZERO
#' 4. cv::THRESH_TOZERO_INV
#' 5. cv::THRESH_OTSU
#' 6. cv::THRESH_TRIANGLE
#'
#' And for `adpthres`, `mode` is an integer scalar `0` or `1` corresponding to:
#'
#' 0. cv::ADAPTIVE_THRESH_MEAN_C
#' 1. cv::ADAPTIVE_THRESH_GAUSSIAN_C
#'
#' @param nr A `nativeRaster` object.
#' @param threshold A numeric scalar. Threshold value.
#' @param maxv A numeric scalar. Max value to use with some thresholding modes.
#' @param bsize A numeric scalar.
#' The size of a pixel neighborhood that is used to calculate a threshold value for the pixel.
#' @param C The C value for adaptive thresholding.
#' @param mode An integer scalar. The mode of thresholding.
#' @param invert A logical scalar.
#' Whether to invert the result in adaptive thresholding.
#' @returns A `nativeRaster` object.
#' @rdname thres
#' @name thres
#' @aliases adpthres
NULL

#' @rdname thres
#' @export
thres <- function(
  nr,
  threshold = 100,
  maxv = 255,
  mode = c(0, 1, 2, 3, 4, 5, 6)
) {
  if (threshold < 0 || threshold > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`maxv` must be in range [0, 255]")
  }
  mode <- int_match(mode, "mode", c(0, 1, 2, 3, 4, 5, 6))
  out <- azny_thres(cast_nr(nr), nrow(nr), ncol(nr), threshold, maxv, mode)
  as_nr(out)
}

#' @rdname thres
#' @export
adpthres <- function(
  nr,
  maxv = 255,
  bsize = 1,
  C = 5, # nolint
  mode = c(0, 1),
  invert = FALSE
) {
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (bsize < 1 || bsize > 50) {
    rlang::abort("`bsize` must be in range [1, 50]")
  }
  mode <- int_match(mode, "mode", c(0, 1))
  out <- azny_adpthres(
    cast_nr(nr),
    nrow(nr),
    ncol(nr),
    as.logical(mode),
    maxv,
    bsize,
    invert,
    C
  )
  as_nr(out)
}
