#' Fade pixels based on a mask image
#'
#' @description
#' Fades pixels of an image by modifying its alpha channel according to
#' values derived from a mask image.
#'
#' The mask image is first converted into a scalar fade factor, depending on
#' the selected channel specified by `with`. This fade factor is then multiplied
#' with the existing alpha channel of `nr`. The RGB channels of `nr` are not
#' modified.
#'
#' @details
#' The fade factor is always normalized to the range `[0, 1]` and is applied
#' by multiplying the existing alpha channel of `nr`. This means that already
#' transparent pixels remain transparent, and fully opaque pixels can only
#' become more transparent.
#'
#' This function does not modify RGB values. If you need to adjust RGB values
#' of transparent pixels (for example, to avoid color fringes before compositing),
#' consider using `set_matte()`.
#'
#' @param nr A `nativeRaster` object.
#' @param mask A `nativeRaster` object of the same dimensions as `nr`. Used as the
#'  source for computing fade factors.
#' @param with A character string specifying which channel of the mask image is
#'  used to compute the fade factor. One of:
#'
#'  * luma: Luma computed from RGB values using weights `c(0.299, 0.587, 0.114)`.
#'  * hue: Hue component of the mask image in the HLS color space.
#'  * luminance: Luminance (L) component of the mask image in the HLS color space.
#'  * saturation: Saturation (S) component of the mask image in the HLS color space.
#'
#' @param range An optional numeric vector of length 2. If specified, the fade
#'  factor is binarized so that only values within the given range are kept.
#'  Pixels outside the range become fully transparent.
#' @param invert A logical scalar.
#'  If `TRUE`, the mask image is inverted before computing the fade factor.
#' @returns A `nativeRaster` object.
#' @export
fade_with <- function(
  nr,
  mask = nr,
  with = c("luma", "hue", "luminance", "saturation"),
  range = NULL,
  invert = FALSE
) {
  check_nr_dim(nr, mask)
  with <- rlang::arg_match(with)

  sz <- dim(nr)
  nr <- nr_to_rgba(nr, "nr")
  mask <- nr_to_rgba(mask, "mask")

  if (invert) {
    mask <- 255L - mask
  }
  f <- switch(
    with,
    luma = fader_with_luma(mask),
    hue = fader_with_hue(mask),
    luminance = fader_with_luminance(mask),
    saturation = fader_with_saturation(mask)
  )
  if (!is.null(range)) {
    f <- as.double(f >= min(range) & f <= max(range))
  }

  as_nr(
    azny_pack_integers(
      nr[1:3, ] * 1,
      nr[4, ] * f,
      sz[1],
      sz[2]
    )
  )
}

#' @noRd
fader_with_luma <- function(mask) {
  t(colSums(gray(mask[1:3, ])))
}

#' @noRd
fader_with_hue <- function(mask) {
  t(rgb2hls(mask[1:3, ])[1, ]) / 180
}

#' @noRd
fader_with_luminance <- function(mask) {
  t(rgb2hls(mask[1:3, ])[2, ]) / 255
}

#' @noRd
fader_with_saturation <- function(mask) {
  t(rgb2hls(mask[1:3, ])[3, ]) / 255
}
