skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("swap_channels works", {
  vdiffr::expect_doppelganger(
    "swap_channels",
    swap_channels(png) |>
      as_recordedplot()
  )
})

test_that("resize works", {
  vdiffr::expect_doppelganger(
    "resize_by_coef",
    resize(png, wh = c(0.5, 1.2)) |>
      as_recordedplot()
  )
  vdiffr::expect_doppelganger(
    "resize_by_size",
    resize(png, wh = c(361 * .5, 241 * 1.2), set_size = TRUE) |>
      as_recordedplot()
  )
})

test_that("resample works", {
  vdiffr::expect_doppelganger(
    "resample",
    resample(png, wh = c(0.3, 0.3)) |>
      as_recordedplot()
  )
})

test_that("warp_perspective works", {
  vdiffr::expect_doppelganger(
    "warp_perspective",
    warp_perspective(
      png,
      matrix(c(.7071068, -.7071068, 0, .7071068, .7071068, 0, 0, 0, 1), 3, 3),
      3 # border: wrap
    ) |>
      as_recordedplot()
  )
})
