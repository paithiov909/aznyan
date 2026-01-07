#' Read and write images
#'
#' @description
#' These functions provide convenient helpers for reading still images,
#' writing still images, and creating animated image files.
#'
#' @details
#' - `read_still()`:
#'   Reads a still image file and converts it into a `nativeRaster`.
#' - `write_still()`:
#'   Writes a still image file from a `nativeRaster`.
#' - `write_animation()`:
#'   Writes an animated image file from a sequence of image files.
#'
#' @param filename A file name.
#'  For `read_still()`, the path to the input image file.
#'  For `write_still()` and `write_animation()`, the output file name.
#' @param nr A `nativeRaster` object.
#' @param frames A character vector of file names representing animation frames.
#' @param delay Frame delay in seconds.
#'  Internally converted to milliseconds, with a minimum of 10ms.
#' @param quality Image quality for WebP animation.
#'  For other image formats, this argument is ignored.
#' @param loop_count Number of animation loops.
#'  A value of `0` means infinite looping.
#'
#' @returns
#' - `read_still()` returns a `nativeRaster` object.
#' - `write_still()` and `write_animation()` invisibly returns `filename`.
#'
#' @rdname image-io
#' @name image-io
NULL

#' @rdname image-io
#' @export
read_still <- function(filename) {
  as_nr(azny_read_still(filename))
}

#' @rdname image-io
#' @export
write_still <- function(nr, filename = "azny-still.png") {
  invisible(azny_write_still(filename, nr, nrow(nr), ncol(nr)))
}

#' @rdname image-io
#' @export
write_animation <- function(
  frames,
  filename = "azny-anime.webp",
  delay = 1 / 12,
  quality = 80,
  loop_count = 0
) {
  delay <- max(10, floor(delay * 1000), na.rm = TRUE) # in milliseconds
  loop_count <- max(0, loop_count, na.rm = TRUE)
  invisible(azny_write_animation(
    frames,
    filename,
    as.integer(delay),
    quality,
    loop_count
  ))
}
