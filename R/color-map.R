#' Apply a color map
#'
#' Maps grayscale or hue values of a `nativeRaster` image to a predefined color
#' lookup table (OpenCV colormaps). The input can be derived either from the
#' grayscale intensity or from the hue channel in HSV space. The mapped values
#' replace the image's color channels while preserving the alpha channel.
#'
#' ## Options
#' `map` corresponds to:
#'
#' 0. cv::COLORMAP_AUTUMN
#' 1. cv::COLORMAP_BONE
#' 2. cv::COLORMAP_JET
#' 3. cv::COLORMAP_WINTER
#' 4. cv::COLORMAP_RAINBOW
#' 5. cv::COLORMAP_OCEAN
#' 6. cv::COLORMAP_SUMMER
#' 7. cv::COLORMAP_SPRING
#' 8. cv::COLORMAP_COOL
#' 9. cv::COLORMAP_HSV
#' 10. cv::COLORMAP_PINK
#' 11. cv::COLORMAP_HOT
#' 12. cv::COLORMAP_PARULA
#' 13. cv::COLORMAP_MAGMA
#' 14. cv::COLORMAP_INFERNO
#' 15. cv::COLORMAP_PLASMA
#' 16. cv::COLORMAP_VIRIDIS
#' 17. cv::COLORMAP_CIVIDIS
#' 18. cv::COLORMAP_TWILIGHT
#' 19. cv::COLORMAP_TWILIGHT_SHIFTED
#' 20. cv::COLORMAP_TURBO
#' 21. cv::COLORMAP_DEEPGREEN
#'
#' @param nr A `nativeRaster` object.
#' @param map An integer scalar specifying the colormap ID.
#' Must be one of `0–21`, corresponding to OpenCV's built-in color maps.
#' @param use_hsv A logical scalar.
#' If `TRUE`, the hue channel (HSV_FULL) is used as the input to the colormap;
#' if `FALSE`, a grayscale conversion is used instead.
#' @param inverse A logical scalar. If `TRUE`, the input channel is inverted
#' (`255 - value`) before applying the colormap.
#' @returns A `nativeRaster` object.
#' @export
color_map <- function(nr, map = 0, use_hsv = FALSE, inverse = FALSE) {
  map <- int_match(map, "map", seq_len(22) - 1)
  out <- azny_color_map(cast_nr(nr), nrow(nr), ncol(nr), map, use_hsv, inverse)
  as_nr(out)
}
