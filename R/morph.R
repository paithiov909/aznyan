#' Morphology
#'
#' @details
#' `mode` is an integer scalar in range `[0, 7]` corresponding to:
#'
#' 0. cv::MORPH_ERODE
#' 1. cv::MORPH_DILATE
#' 2. cv::MORPH_OPEN
#' 3. cv::MORPH_CLOSE
#' 4. cv::MORPH_GRADIENT
#' 5. cv::MORPH_TOPHAT
#' 6. cv::MORPH_BLACKHAT
#' 7. cv::MORPH_HITMISS
#'
#' @param nr A `nativeRaster` object.
#' @param ksize The size of kernel.
#' @param ktype The type of kernel.
#' @param mode The mode of morphology.
#' @param border The type of pixel extrapolation method.
#' @param iterations The iteration of morphology.
#' @param alphasync Whether sync alpha.
#' @param use_rgb Whether to use RGB morphology.
#' @param anchor The anchor of morphology.
#' @returns A `nativeRaster` object.
#' @export
morphology <- function(
  nr,
  ksize = c(2, 2, 2),
  ktype = c(0, 1, 2),
  mode = c(0, 1, 2, 3, 4, 5, 6, 7),
  border = c(3, 4, 0, 1, 2),
  iterations = 1,
  alphasync = TRUE,
  use_rgb = TRUE,
  anchor = c(-1, -1)
) {
  if (!all(ksize >= 0)) {
    rlang::abort("ksize must be >= 0")
  }
  ktype <- int_match(ktype, "ktype", c(0, 1, 2))
  mode <- int_match(mode, "mode", c(0, 1, 2, 3, 4, 5, 6, 7))
  border <- int_match(border, "border", c(0, 1, 2, 3, 4))

  ksize <- as.integer(ksize)
  anchor <- as.integer(anchor)
  if (use_rgb) {
    out <- azny_morphologyrgb(
      as.integer(nr),
      nrow(nr),
      ncol(nr),
      ksize,
      ktype,
      mode,
      iterations,
      border,
      alphasync,
      anchor
    )
  } else {
    out <- azny_morphologyfilter(
      as.integer(nr),
      nrow(nr),
      ncol(nr),
      ksize[1],
      ktype,
      mode,
      iterations,
      border,
      alphasync,
      anchor
    )
  }
  enclass(out)
}
