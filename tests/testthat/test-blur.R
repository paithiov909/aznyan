skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/painting.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("median_blur works", {
  vdiffr::expect_doppelganger(
    "median_blur",
    median_blur(png, ksize = 8) |>
      as_recordedplot()
  )
})

test_that("box_blur works", {
  vdiffr::expect_doppelganger(
    "box_blur",
    box_blur(png, 16, 16, TRUE, 4) |>
      as_recordedplot()
  )
})

test_that("gaussian_blur works", {
  vdiffr::expect_doppelganger(
    "gaussian_blur",
    gaussian_blur(png, 16, 16, 4, 4, 4) |>
      as_recordedplot()
  )
})

test_that("convolve works", {
  vdiffr::expect_doppelganger(
    "convolve",
    convolve(png, kernel_motion(13, 5 * pi / 6)) |>
      as_recordedplot()
  )
})

test_that("kuwahara_filter works", {
  filter <-
    matrix(c(0, -.111, 0, -.111, 1.777, -.111, 0, -.111, 0), 3, 3) |>
    kronecker(matrix(1, 3, 3))
  vdiffr::expect_doppelganger(
    "kuwahara",
    kuwahara_filter(png, kernel_disc(9), kernel2 = filter) |>
      as_recordedplot()
  )
})
