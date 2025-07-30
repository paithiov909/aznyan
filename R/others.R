#' Mean shift filter
#'
#' @param nr A `nativeRaster` object.
#' @param sp,sr The parameters of mean shift.
#' @param max_level The maximum level of mean shift.
#' @returns A `nativeRaster` object.
#' @export
mean_shift <- function(nr, sp = 10, sr = 30, max_level = 1) {
  out <- azny_meanshift(cast_nr(nr), nrow(nr), ncol(nr), sp, sr, as.integer(max_level))
  as_nr(out)
}

#' Preserve-edge filter
#'
#' @param nr A `nativeRaster` object.
#' @param sgmS,sgmR The parameters of edge preserving filter.
#' `[0, 200]` for `sgmS` and `[0, 1]` for `sgmR`.
#' @param recursive Whether to use recursive mode.
#' @returns A `nativeRaster` object.
#' @export
preserve_edge <- function(
  nr,
  sgmS = 60, # nolint
  sgmR = 0.4, # nolint
  recursive = TRUE
) {
  out <- azny_preserve_edges(cast_nr(nr), nrow(nr), ncol(nr), sgmS, sgmR, recursive)
  as_nr(out)
}
