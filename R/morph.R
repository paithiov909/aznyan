#' Morphological operations (grayscale or RGB)
#'
#' Applies morphological image-processing operations to a `nativeRaster` image.
#' Depending on `use_rgb`, operations are applied either to the grayscale image
#' masked by the alpha channel or independently to each RGB channel with
#' per-channel structuring elements. Supported operations include erosion,
#' dilation, opening, closing, gradient, and related transforms.
#'
#' ## Kernel specification
#' The shape of the structuring element is controlled by `ktype`, and its size
#' is determined by `ksize`.
#'
#' - When `use_rgb = FALSE`, `ksize` must be a single non-negative integer.
#' - When `use_rgb = TRUE`, `ksize` must be a length-3 integer vector, allowing
#'   separate kernel sizes for the R, G, and B channels.
#'
#' The location of the anchor (kernel origin) can be specified via `anchor`.
#' Use `c(-1, -1)` for the default centered anchor.
#'
#' ## Alpha handling
#' If `alphasync = TRUE`, the same morphological operation is applied to the
#' alpha channel. Otherwise, the alpha channel is preserved.
#'
#' ## Options
#' `ktype` corresponds to:
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
#' `border` corresponds to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param ksize An integer vector specifying kernel size(s).
#'
#' * Length 1 (grayscale mode): kernel radius.
#' * Length 3 (RGB mode): per-channel kernel radii.
#'
#'  Must be non-negative.
#' @param ktype An integer scalar selecting the structuring element shape.
#'  One of `0, 1, 2`, corresponding to OpenCV kernel types.
#' @param mode An integer scalar selecting the morphological operation.
#'  One of `0–7`, mapped to OpenCV operation modes (`morphologyEx` operations).
#' @param border An integer scalar selecting the border-handling mode.
#'  One of `0–4`, corresponding to OpenCV's border modes.
#' @param iterations An integer scalar giving the number of repetitions of the
#'  operation. Must be grater than 0.
#' @param alphasync A logical scalar. If `TRUE`, apply the morphological
#'  operation to the alpha channel as well.
#' @param use_rgb A logical scalar. If `TRUE`, apply the operation independently
#'  to each RGB channel; if `FALSE`, apply it to a grayscale image derived from
#'  masked RGB.
#' @param anchor An integer vector of length 2 specifying the anchor point
#'  (kernel origin). Use `c(-1, -1)` for the default centered anchor.
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
    cli::cli_abort("ksize must be >= 0")
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
