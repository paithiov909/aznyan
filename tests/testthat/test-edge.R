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

png <-
  fastpng::read_png(
    system.file("images/sample-361x241.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("canny_filter works", {
  vdiffr::expect_doppelganger(
    "canny_filter",
    canny_filter(png, use_rgb = FALSE) |>
      as_recordedplot2()
  )
  vdiffr::expect_doppelganger(
    "canny_rgb",
    canny_filter(png, use_rgb = TRUE) |>
      as_recordedplot2()
  )
})
