#' Read srt file
#'
#' @param path Path to srt file.
#' @param collapse String.
#' @returns A tibble.
#' @export
read_srt <- function(path, collapse = "\n") {
  path <- path.expand(path)
  stopifnot(
    is.character(collapse),
    file.exists(path)
  )
  ret <- read_srt_impl(path, collapse = collapse)

  ret[["start"]] <- stringr::str_replace_all(ret$start, pattern = ",", replacement = "\\.")
  ret[["end"]] <- stringr::str_replace_all(ret$end, pattern = ",", replacement = "\\.")

  dplyr::as_tibble(ret)
}
