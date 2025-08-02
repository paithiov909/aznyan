#' Morphology
#'
#' @description
#' Applies morphological transformations to an image.
#'
#' `ktype` refers to:
#'
#' 0. cv::MORPH_RECT
#' 1. cv::MORPH_CROSS
#' 2. cv::MORPH_ELLIPSE
#'
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
#' @param ksize A numeric vector of length 3. The kernel size.
#' @param ktype An integer scalar.
#' The type of kernel. See description.
#' @param mode An integer scalar.
#' The type of morphological operation. See description.
#' @param border An integer scalar.
#' The type of pixel extrapolation method.
#' @param iterations An integer scalar.
#' Number of times to apply the transformation.
#' @param alphasync A logical scalar.
#' If `TRUE`, applies the transformation separately to the alpha channel.
#' @param use_rgb A logical scalar.
#' If `TRUE`, applies morphology separately for each color channel
#' and combines them.
#' @param anchor An integer vector of length 2.
#' Anchor position with the kernel. The default value means the center of the kernel.
#' @returns A `nativeRaster` object.
#' @export
morphology <- function(
  nr,
  ksize = c(2, 2, 2),
  ktype = c(0, 1, 2),
  mode = c(0, 1, 2, 3, 4, 5, 6, 7),
  border = c(3, 4, 0, 1, 2),
  iterations = 1,
  alphasync = FALSE,
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
      cast_nr(nr),
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
      cast_nr(nr),
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
  as_nr(out)
}
