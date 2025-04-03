#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib aznyan, .registration = TRUE
## usethis namespace: end
NULL

int_match <- function(x, arg, values) {
  x <- match(x[1], values) - 1L
  if (is.na(x)) {
    msg <- glue::glue(
      "`{arg}` must be one of {paste0(values, collapse = ', ')}. Got {x}."
    )
    rlang::abort(msg)
  }
  x
}
