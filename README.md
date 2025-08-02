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
library(ggplot2)
library(patchwork) # for layouting native rasters

png <-
  fastpng::read_png(
    system.file("images/aznyan-256x256.png", package = "aznyan"),
    type = "nativeraster",
    rgba = TRUE
  )
```

The original image `png` above looks like this:

![original image](inst/images/aznyan-256x256.png)

Some filters are applied to the image and the result is shown below.

``` r
blur <-
  wrap_elements(full = aznyan::median_blur(png, ksize = 8)) +
  labs(title = "Median Blur")
diffusion <-
  wrap_elements(full = aznyan::diffusion_filter(png, factor = 8)) +
  labs(title = "Diffusion Filter")
morph <-
  wrap_elements(full = aznyan::morphology(png, ksize = c(4, 4, 4))) +
  labs(title = "Morphological\nTransformation")

(blur | diffusion | morph)
```

<img src="man/figures/README-opencv-filters-1.jpeg"
data-fig-alt="Median blur, diffusion filter, and morphological transformation filters applied to a sample image" />

Other filters ported from
[Rustagram](https://github.com/ha-shine/rustagram) are also available.

<img src="man/figures/README-color-filters-1.jpeg"
data-fig-alt="Other color filters applied to a sample image" />
