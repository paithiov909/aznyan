skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/sample-361x241.png", package = "aznyan"),
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
