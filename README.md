# aznyan


<!-- README.md is generated from README.qmd. Please edit that file -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/paithiov909/aznyan/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/paithiov909/aznyan/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

aznyan is a collection of image filters for R that wraps
[OpenCV](https://opencv.org/), ported from
[5PB-3-4/AviUtl_OpenCV_Scripts](https://github.com/5PB-3-4/AviUtl_OpenCV_Scripts).

Still in development. It will probably work, but documentation is scant.
Also, note that this package requires some SIMD extensions to work on
your system.

## Usage

aznyan provides functions that take a `nativeRaster` of image data as
their first argument and return a `nativeRaster` after applying the
effect.

You can simply read a PNG image into a `nativeRaster` using
`fastpng::read_png()`.

``` r
pkgload::load_all(export_all = FALSE)
#> ℹ Loading aznyan

png <-
  fastpng::read_png(
    system.file("images/sample-256x256-4ch.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE
  )
```

The original image `png` above looks like this:

![original image](inst/images/sample-256x256-4ch.png)

### Blur

``` r
median_blur(png, ksize = 8) |>
  grid::grid.raster(interpolate = FALSE)
```

<img src="man/figures/README-median-blur-1.png" style="width:30.0%" />

### Diffusion Filter (拡散フィルタ)

``` r
diffusion_filter(png, factor = 8) |>
  grid::grid.raster(interpolate = FALSE)
```

<img src="man/figures/README-diffusion-1.png" style="width:30.0%" />

### Morphological Transformation （モルフォロジー変換）

``` r
morphology(png, ksize = c(4, 4, 4)) |>
  grid::grid.raster(interpolate = FALSE)
```

<img src="man/figures/README-morph-erosion-1.png" style="width:30.0%" />
