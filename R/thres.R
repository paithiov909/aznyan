#' Image thresholding
#'
#' @param png A raw vector of PNG image.
#' @param threshold The threshold value.
#' @param maxv The maximum value.
#' @param bsize The block size.
#' @param C The C value for adaptive thresholding.
#' @param mode The mode of thresholding.
#' @param invert Whether to invert the result in adaptive thresholding.
#' @returns A raw vector of PNG image.
#'
#' @rdname thres
#' @name thres
#' @aliases adpthres
NULL

#' @rdname thres
#' @export
thres <- function(png,
                  threshold = 100,
                  maxv = 255,
                  mode = c(0, 1, 2, 3, 4, 5, 6)) {
  if (threshold < 0 || threshold > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`maxv` must be in range [0, 255]")
  }
  mode <- int_match(mode, "mode", c(0, 1, 2, 3, 4, 5, 6))
  azny_thres(png, threshold, maxv, mode)
}

#' @rdname thres
#' @export
adpthres <- function(png,
                     maxv = 255,
                     bsize = 1,
                     C = 5, # nolint
                     mode = c(0, 1),
                     invert = FALSE) {
  if (maxv < 0 || maxv > 255) {
    rlang::abort("`threshold` must be in range [0, 255]")
  }
  if (bsize < 1 || bsize > 50) {
    rlang::abort("`bsize` must be in range [1, 50]")
  }
  mode <- int_match(mode, "mode", c(0, 1))
  azny_adpthres(png, mode, maxv, bsize, as.integer(invert), C)
}
