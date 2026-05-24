if (!requireNamespace("readr", quietly = TRUE)) {
  stop("'readr' package is required.")
}

test_cubelut <-
  readr::read_delim(
    "tools/Magic_Lantern_Video.cube",
    delim = " ",
    skip = 3,
    col_names = c("r", "g", "b"),
    show_col_types = FALSE
  )

# test_cubelut
# nrow(test_cubelut)^(1/3)
# write_cubelut(test_cubelut, "test.cube")

usethis::use_data(test_cubelut, internal = TRUE, overwrite = TRUE)
