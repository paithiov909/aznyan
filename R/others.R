#' Mean shift filter
#'
#' @param nr A `nativeRaster` object.
#' @param sp,sr The parameters of mean shift.
#' @param max_level The maximum level of mean shift.
#' @returns A `nativeRaster` object.
#' @export
mean_shift <- function(nr, sp = 10, sr = 30, max_level = 1) {
  out <- azny_meanshift(as.integer(nr), nrow(nr), ncol(nr), sp, sr, as.integer(max_level))
  enclass(out)
}

#' Preserve-edge filter
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS,sgmR The parameters of edge preserving filter.
#' @param recursive Whether to use recursive mode.
#' @returns A `nativeRaster` object.
#' @export
preserve_edge <- function(
  nr,
  sgmS = 600, # nolint
  sgmR = 40, # nolint
  recursive = TRUE
) {
  out <- azny_preserve_edges(as.integer(nr), nrow(nr), ncol(nr), sgmS, sgmR, recursive)
  enclass(out)
}
