#' Write a 3D LUT file
#'
#' Saves 3 numeric columns of a data frame to a LUT file.
#' This function supports 3D, 3-channel LUTs only.
#'
#' @param x A data frame with 3 numeric columns.
#' @param filename The path to save the LUT file.
#' It must end with `.cube` or `.smcube` respectively.
#' @param title `TITLE` for the LUT.
#' @param domain_min `DOMAIN_MIN` for the LUT.
#' @param domain_max `DOMAIN_MAX` for the LUT.
#' @returns
#' The path to the saved LUT file is invisibly returned.
#' @rdname write_cube
#' @name write_cube
NULL

#' @rdname write_cube
#' @name write_cube
#' @export
write_cube <- function(
  x,
  filename = tempfile(fileext = ".cube"),
  title = "",
  domain_min = c(0.0, 0.0, 0.0),
  domain_max = c(1.0, 1.0, 1.0)
) {
  if (ncol(x) != 3) {
    cli::cli_abort("`x` must have 3 columns")
  }
  header <-
    c(
      paste("TITLE", paste0("\"", title, "\"")),
      paste("DOMAIN_MIN", paste(domain_min, collapse = " ")),
      paste("DOMAIN_MAX", paste(domain_max, collapse = " ")),
      paste("LUT_3D_SIZE", nrow(x)^(1 / 3))
    )
  writeLines(header, filename)
  write.table(
    x,
    filename,
    append = TRUE,
    row.names = FALSE,
    col.names = FALSE,
    na = "0"
  )
  invisible(filename)
}
