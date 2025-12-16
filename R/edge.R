#' Sobel edge detection (grayscale or RGB)
#'
#' Applies a Sobel filter to extract edges from a `nativeRaster` image. The
#' operation can be performed on a grayscale conversion or by aggregating
#' per-channel gradients from the RGB channels. The resulting edge intensity is
#' returned as a 3-channel grayscale image, with optional binary alpha masking.
#'
#' ## Grayscale mode (`use_rgb = FALSE`)
#' The image is converted to grayscale, normalized to `[0, 1]`, and the Sobel
#' derivative is computed using the specified derivative orders `dx`, `dy`, and
#' kernel size `ksize`. Edges are mapped to `[0, 255]`. When `balp = TRUE`,
#' the alpha channel is binarized based on the detected edges.
#'
#' ## RGB mode (`use_rgb = TRUE`)
#' Sobel derivatives are computed independently for each RGB channel and summed
#' to produce a combined edge response. The alpha channel is either binarized
#' from the edge map (`balp = TRUE`) or preserved from the input.
#'
#' ## Options
#' `border` corresponds to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param ksize An integer scalar giving the filter radius. The actual Sobel
#'  kernel size becomes `2 * ksize - 1`. Must be non-negative.
#' @param balp A logical scalar. If `TRUE`, the alpha channel is thresholded
#'  from the edge map; if `FALSE`, the alpha channel is preserved.
#' @param use_rgb A logical scalar. If `TRUE`, compute Sobel edges from each RGB
#'  channel and aggregate; if `FALSE`, compute on grayscale only.
#' @param border An integer scalar selecting the border-handling mode. One of
#'  `0–4`, corresponding to OpenCV border types.
#' @param dx An integer scalar specifying the order of the derivative in x.
#' @param dy An integer scalar specifying the order of the derivative in y.
#' @param scale A numeric scalar scaling the computed Sobel derivative.
#' @param delta A numeric scalar added to the results prior to scaling.
#' @returns A `nativeRaster` object.
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

#' Laplacian edge detection (grayscale or RGB)
#'
#' @description
#' Applies a Laplacian filter to detect edges in a `nativeRaster` image.
#'
#' The Laplacian operator computes second-order derivatives,
#' highlighting regions of rapid intensity change.
#'
#' The result is returned as a 3-channel grayscale image,
#' with optional binary alpha masking.
#'
#' @details
#' ## Grayscale mode (`use_rgb = FALSE`)
#' The input image is converted to grayscale, normalized to `[0, 1]`, and the
#' Laplacian operator is applied using a kernel of size `2 * ksize - 1`. The
#' output is rescaled to `[0, 255]`. When `balp = TRUE`, the alpha channel is
#' thresholded based on edge intensity.
#'
#' ## RGB mode (`use_rgb = TRUE`)
#' The Laplacian operator is applied independently to each RGB channel, and the
#' channelwise derivatives are summed to produce a combined edge map. The alpha
#' channel is determined either by thresholding (`balp = TRUE`) or by preserving
#' the original.
#'
#' ## Options
#' `border` corresponds to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param ksize An integer scalar specifying the kernel radius. The effective
#'  Laplacian kernel size becomes `2 * ksize - 1`. Must be non-negative.
#' @param balp A logical scalar. If `TRUE`, generate alpha from edge intensity
#'  by thresholding; if `FALSE`, preserve the original alpha.
#' @param use_rgb A logical scalar. If `TRUE`, compute Laplacian derivatives for
#'  each RGB channel separately; if `FALSE`, operate on grayscale only.
#' @param border An integer scalar selecting the border-handling mode. One of
#'  `0–4`, corresponding to OpenCV border modes.
#' @param scale A numeric scalar that scales the computed Laplacian derivative.
#' @param delta A numeric scalar added to the filtered result before scaling.
#' @returns A `nativeRaster` object.
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

#' Canny edge detection (grayscale or RGB)
#'
#' @description
#' Applies the Canny edge detector to a `nativeRaster` image.
#'
#' The filter can operate either on a grayscale conversion
#' or by aggregating edges detected independently from each RGB channel.
#'
#' The result is returned as a 3-channel
#' binary edge map, with optional alpha masking.
#'
#' @details
#' ## Grayscale mode (`use_rgb = FALSE`)
#' The input is converted to grayscale and passed to the Canny operator.
#' The aperture size of the Sobel derivative is `2 * asize - 1`. When
#' `balp = TRUE`, the alpha channel is thresholded from the detected edges.
#'
#' ## RGB mode (`use_rgb = TRUE`)
#' Canny is applied independently to each RGB channel, and the resulting edge
#' maps are summed to form a combined edge representation. The alpha channel is
#' either thresholded (`balp = TRUE`) or preserved from the input.
#'
#' ## Options
#' `border` corresponds to:
#'
#' 0. cv::BORDER_CONSTANT
#' 1. cv::BORDER_REPLICATE
#' 2. cv::BORDER_REFLECT
#' 3. cv::BORDER_REFLECT_101
#' 4. cv::BORDER_ISOLATED
#'
#' @param nr A `nativeRaster` object.
#' @param asize An integer scalar giving the aperture size parameter; the
#'  actual Sobel kernel size used internally by Canny is `2 * asize - 1`.
#' @param balp A logical scalar. If `TRUE`, derive the alpha channel from the
#'  detected edges by thresholding; if `FALSE`, preserve the input alpha.
#' @param use_rgb A logical scalar. If `TRUE`, compute edges per RGB channel
#'  and aggregate them; if `FALSE`, operate on grayscale only.
#' @param thres1 A numeric scalar giving the lower hysteresis threshold.
#' @param thres2 A numeric scalar giving the upper hysteresis threshold.
#' @param grad A logical scalar indicating whether to use a more accurate
#'  gradient calculation (`L2gradient = TRUE`) or the default (`FALSE`).
#' @returns A `nativeRaster` object.
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
