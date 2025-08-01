skip_on_cran()
skip_on_ci()

png <-
  fastpng::read_png(
    system.file("images/painting.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE,
    flags = 1L
  )

test_that("diffusion works", {
  vdiffr::expect_doppelganger(
    "diffusion",
    diffusion_filter(png, factor = 5) |>
      as_recordedplot()
  )
})
