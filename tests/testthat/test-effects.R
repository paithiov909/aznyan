skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("blurhash works", {
  vdiffr::expect_doppelganger(
    "blurhash",
    blurhash(png, 1, 1) |>
      as_recordedplot()
  )
})

test_that("diffusion works", {
  vdiffr::expect_doppelganger(
    "diffusion",
    diffusion_filter(png, factor = 5) |>
      as_recordedplot()
  )
})

test_that("lineweave works", {
  vdiffr::expect_doppelganger(
    "lineweave",
    lineweave(png, bg = fill_with("gray30", ncol(png), nrow(png))) |>
      as_recordedplot()
  )
})
