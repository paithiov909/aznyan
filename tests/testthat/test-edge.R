skip_on_cran()
skip_on_ci()

png <- readBin(
  system.file("images/sample-361x241.png", package = "aznyan"),
  what = "raw",
  n = file.info(system.file("images/sample-361x241.png", package = "aznyan"))$size
)

test_that("sobel_filter works", {
  vdiffr::expect_doppelganger(
    "sobel_filter",
    sobel_filter(png, ksize = 3) |>
      as_recordedplot()
  )
})

test_that("sobel_rgb works", {
  vdiffr::expect_doppelganger(
    "sobel_rgb",
    sobel_rgb(png, ksize = 3) |>
      as_recordedplot()
  )
})
