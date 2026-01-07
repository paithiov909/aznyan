skip_on_cran()
skip_on_ci()

png <- read_still(system.file("images/painting.png", package = "aznyan"))

test_that("diffusion works", {
  vdiffr::expect_doppelganger(
    "diffusion",
    diffusion_filter(png, factor = 5) |>
      as_recordedplot()
  )
})
