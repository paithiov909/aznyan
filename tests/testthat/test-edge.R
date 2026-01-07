skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("sobel_filter works", {
  vdiffr::expect_doppelganger(
    "sobel_filter",
    sobel_filter(png, ksize = 3, use_rgb = FALSE) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "sobel_rgb",
    sobel_filter(png, ksize = 3, use_rgb = TRUE) |>
      as_recordedplot()
  )
})

test_that("laplacian_filter works", {
  vdiffr::expect_doppelganger(
    "laplacian_filter",
    laplacian_filter(png, ksize = 2, use_rgb = FALSE) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "laplacian_rgb",
    laplacian_filter(png, ksize = 2, use_rgb = TRUE) |>
      as_recordedplot()
  )
})

test_that("canny_filter works", {
  vdiffr::expect_doppelganger(
    "canny_filter",
    canny_filter(png, use_rgb = FALSE) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "canny_rgb",
    canny_filter(png, use_rgb = TRUE) |>
      as_recordedplot()
  )
})
