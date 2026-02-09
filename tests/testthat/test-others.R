skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("detail-enhance works", {
  vdiffr::expect_doppelganger(
    "detail-enhance",
    detail_enhance(png) |>
      as_recordedplot()
  )
})

test_that("histogram equalization works", {
  vdiffr::expect_doppelganger(
    "histogram-eq",
    hist_eq(png, color = TRUE) |>
      as_recordedplot()
  )
})

test_that("mean-shift works", {
  vdiffr::expect_doppelganger(
    "mean-shift",
    mean_shift(png) |>
      as_recordedplot()
  )
})

test_that("oilpaint works", {
  vdiffr::expect_doppelganger(
    "oilpaint",
    oilpaint(png) |>
      as_recordedplot()
  )
})

test_that("pencil sketch works", {
  vdiffr::expect_doppelganger(
    "pencil-sketch",
    pencil_sketch(png, color = TRUE) |>
      as_recordedplot()
  )
})

test_that("preserve-edge works", {
  vdiffr::expect_doppelganger(
    "preserve-edge",
    preserve_edge(png, 200, 1) |>
      as_recordedplot()
  )
})

test_that("stylization works", {
  vdiffr::expect_doppelganger(
    "stylization",
    stylize(png) |>
      as_recordedplot()
  )
})
