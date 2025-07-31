nr <- fastpng::read_png(
  system.file("images/vespa.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)
nr2 <- fastpng::read_png(
  system.file("images/street.png", package = "aznyan"),
  type = "nativeraster",
  rgba = TRUE
)

devtools::document()

grid::grid.newpage()
fill_with(361, 241, rgb(255, 0, 0, 255, maxColorValue = 255)) |>
  grid::grid.raster(interpolate = FALSE)
