#' Read and write images
#'
#' @description
#' These functions provide convenient helpers for reading still images,
#' writing still images, and creating animated image files.
#'
#' Since the underlying image writers always treat the input as 4 channels images,
#' writing with some formats would fail even if the linked 'OpenCV' library supports it.
#'
#' @details
#' - `read_still()`:
#'   Reads a still image file and converts it into a `nativeRaster`.
#' - `read_data()`:
#'   Reads image data from a raw vector and converts it into a `nativeRaster`.
#' - `write_still()`:
#'   Writes a still image file from a `nativeRaster`.
#' - `write_data()`:
#'   Writes and returns the image data as a raw vector.
#' - `write_animation()`:
#'   Writes an animated image file from a sequence of image files.
#'
#' @param filename A file name.
#'  For `read_still()`, the path to the input image file.
#'  For `write_still()` and `write_animation()`, the output file name.
#' @param x A raw vector containing image data.
#' @param nr A `nativeRaster` object.
#' @param ext File extension (e.g., ".jpg", ".png")
#'  to specify the output format.
#' @param quality Image quality.
#'  For `write_animation()`, when the output format is not WebP,
#'  this parameter is ignored.
#' @param frames A character vector of file names representing animation frames.
#' @param delay Frame delay in seconds.
#'  Internally converted to milliseconds, with a minimum of 10ms.
#' @param loop_count Number of animation loops.
#'  A value of `0` means infinite looping.
#'
#' @returns
#' - `read_still()` and `read_data()` return a `nativeRaster` object.
#' - `write_still()` and `write_animation()` invisibly return `filename`.
#' - `write_data()` returns a raw vector containing the image data.
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
read_data <- function(x) {
  if (!is.raw(x)) {
    cli::cli_abort("`x` must be a raw vector containing image data.")
  }
  as_nr(azny_read_data(x))
}

#' @rdname image-io
#' @export
write_still <- function(nr, filename = "azny-still.png") {
  invisible(azny_write_still(filename, cast_nr(nr), nrow(nr), ncol(nr)))
}

#' @rdname image-io
#' @export
write_data <- function(nr, ext = ".jpeg", quality = 80) {
  ext <- tolower(ext)
  azny_write_data(ext, cast_nr(nr), nrow(nr), ncol(nr), as.integer(quality))
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
