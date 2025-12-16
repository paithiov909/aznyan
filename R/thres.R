#' Thresholding and adaptive thresholding
#'
#' Performs global (fixed) thresholding or adaptive thresholding on a
#' `nativeRaster` image.
#' Both functions operate on a grayscale conversion of the input
#' and return a 3-channel binary (0/`maxv`) image with the original alpha
#' preserved.
#'
#' ## `thres()`
#'
#' Applies a fixed threshold to the grayscale image.
#' Pixels with values greater than `threshold`
#' (depending on the thresholding mode) are set to `maxv`;
#' others are set to `0`.
#' The behavior is controlled by the thresholding `mode`, which corresponds to
#' OpenCV's threshold types.
#'
#' ## `adpthres()`
#'
#' Applies adaptive thresholding, where the threshold value is computed locally
#' for each pixel based on a neighborhood mean or Gaussian-weighted sum. The
#' block size and constant `C` adjust how the local threshold is computed.
#'
#' ## Options
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
#' @param nr A `nativeRaster` object.
#' @param threshold A numeric scalar in `[0, 255]` specifying the fixed
#' threshold value.
#' @param maxv A numeric scalar in `[0, 255]`.
#'
#' * For `thres()`: A numeric scalar in `[0, 255]` giving the value assigned to
#'   "foreground" pixels.
#' * For `adpthres()`: A numeric scalar in `[0, 255]`
#'   specifying the output value for "foreground" pixels.
#'
#' @param bsize An integer scalar in `[1, 50]` giving the neighborhood radius.
#'  The actual window size is computed as `2 * bsize + 1`.
#' @param C A numeric scalar subtracted from the local threshold
#'  (used by OpenCV). Controls how strong the threshold offset is.
#' @param mode An integer scalar specifying the thresholding mode.
#'
#' * For `thres()`: An integer scalar selecting the thresholding mode.
#'   Must be one of `0–6`, corresponding to OpenCV's threshold flags.
#' * For `adpthres()`: An integer scalar selecting the binary mode.
#'   `0` (`THRESH_BINARY_INV`) or `1` (`THRESH_BINARY`).
#'
#' @param invert A logical scalar.
#'  If `TRUE`, invert the local thresholding result.
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
