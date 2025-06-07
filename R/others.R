#' Mean shift filter
#'
#' @param png A raw vector of PNG image.
#' @param sp,sr The parameters of mean shift.
#' @param max_level The maximum level of mean shift.
#' @returns A raw vector of PNG image.
#' @export
mean_shift <- function(png, sp = 10, sr = 30, max_level = 1) {
  azny_meanshift(png, sp, sr, as.integer(max_level))
}

#' Preserve-edge filter
#'
#' @param png A raw vector of PNG image.
#' @param sgmS,sgmR The parameters of edge preserving filter.
#' @param recursive Whether to use recursive mode.
#' @returns A raw vector of PNG image.
#' @export
preserve_edge <- function(png,
                          sgmS = 600, # nolint
                          sgmR = 40, # nolint
                          recursive = TRUE) {
  azny_preserve_edges(png, sgmS, sgmR, recursive)
}
