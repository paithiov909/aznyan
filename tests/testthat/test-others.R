skip_on_cran()
skip_on_ci()

png <- readBin(
  system.file("images/sample-361x241.png", package = "aznyan"),
  what = "raw",
  n = file.info(system.file("images/sample-361x241.png", package = "aznyan"))$size
)

test_that("other filters work", {
  vdiffr::expect_doppelganger(
    "preserve-edge",
    preserve_edge(png) |>
      as_recordedplot()
  )
})
