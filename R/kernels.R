#' Generate common convolution kernels
#'
#' A collection of helper functions that generate numeric matrices usable as
#' convolution kernels. These kernels are intended for use with `convolve()`
#' and other filtering operations in this package.
#'
#' @details
#' The following kernel constructors are available:
#'
#' * `kernel_bayer`: A Bayer pattern kernel.
#' * `kernel_cone`: A cone-shaped, radially weighted kernel.
#' * `kernel_disc`: A uniformly weighted disc kernel.
#' * `kernel_emboss`: A direction-aware emboss kernel.
#' * `kernel_motion`: A linear motion kernel oriented by `theta`.
#' * `kernel_ring`: A ring-shaped (donut-like) kernel.
#' * `kernel_stripe`: A stripe pattern kernel.
#'
#' @param n An integer specifying the number of rows and columns.
#' @param normalize A logical scalar specifying whether the kernel should be
#'  divided by its sum. Set to `FALSE` in case you use the kernel as a mask.
#' @param size An odd integer specifying the kernel size.
#' @param theta A numeric value (in radians) specifying the orientation.
#' @param thickness A numeric value controlling ring thickness.
#'  Defaults to `1`.
#' @param strength A numeric value controlling emboss intensity.
#'  Defaults to `1`.
#' @param mod An integer specifying the pattern modulus.
#' @param step An integer specifying the pattern step size.
#' @returns A numeric matrix.
#' @rdname kernels
#' @name make-kernels
NULL

#' @rdname kernels
#' @export
kernel_bayer <- function(n, normalize = TRUE) {
  if (length(n) != 1 || !is.finite(n) || n < 2) {
    cli::cli_abort("`n` must be a positive integer greater than 1.")
  }
  pow <- as.integer(n * n)
  den <- 256 %/% pow
  if (!is.finite(den) || den == 0) {
    cli::cli_abort("`n` must be [2, 16] for this function.")
  }
  k <- bayer_mat(n) / den * (1 / pow)
  if (!normalize) {
    return(k)
  }
  k / sum(k)
}

#' @rdname kernels
#' @export
kernel_cone <- function(size) {
  if (size %% 2 != 1) {
    cli::cli_abort("`size` must be an odd integer.")
  }
  r <- (size - 1) / 2
  xy <- expand.grid(-r:r, -r:r)
  d <- sqrt(rowSums(xy^2))
  k <- pmax(1 - (d - r), 0)
  matrix(k / sum(k), size, size)
}

#' @rdname kernels
#' @export
kernel_disc <- function(size) {
  if (size %% 2 != 1) {
    cli::cli_abort("`size` must be an odd integer.")
  }
  r <- (size - 1) / 2

  yy <- rep(-r:r, each = size)
  xx <- rep(-r:r, times = size)
  mask <- (xx^2 + yy^2) <= r^2

  k <- matrix(as.numeric(mask), size, size)
  k / sum(k)
}

#' @rdname kernels
#' @export
kernel_emboss <- function(theta, strength = 1) {
  k <- matrix(c(-1, -1, 0, -1, 0, 1, 0, 1, 1), 3, 3)
  rot <- function(x, y) {
    xr <- x * cos(theta) - y * sin(theta)
    yr <- x * sin(theta) + y * cos(theta)
    c(xr, yr)
  }
  out <- matrix(0, 3, 3)
  coords <- expand.grid(i = -1:1, j = -1:1)

  for (n in seq_len(nrow(coords))) {
    i <- coords$i[n]
    j <- coords$j[n]

    xy <- rot(i, j)

    ii <- round(xy[1])
    jj <- round(xy[2])

    if (ii >= -1 && ii <= 1 && jj >= -1 && jj <= 1) {
      out[j + 2, i + 2] <- k[jj + 2, ii + 2]
    }
  }
  out <- out * strength
  out
}

#' @rdname kernels
#' @export
kernel_motion <- function(size, theta) {
  if (size %% 2 != 1) {
    cli::cli_abort("`size` must be an odd integer.")
  }
  r <- (size - 1) / 2
  k <- matrix(0, size, size)

  for (i in -r:r) {
    x <- round(r + 1 + i * cos(theta))
    y <- round(r + 1 + i * sin(theta))
    if (x >= 1 && x <= size && y >= 1 && y <= size) {
      k[y, x] <- 1
    }
  }
  k / sum(k)
}

#' @rdname kernels
#' @export
kernel_ring <- function(size, thickness = 1) {
  if (size %% 2 != 1) {
    cli::cli_abort("`size` must be an odd integer.")
  }
  if (thickness < 1) {
    cli::cli_abort("`thickness` must be at least 1.")
  }
  r <- (size - 1) / 2
  yy <- rep(-r:r, each = size)
  xx <- rep(-r:r, times = size)

  dist <- sqrt(xx^2 + yy^2)

  mask <- dist >= (r - thickness) & dist <= r
  k <- matrix(as.numeric(mask), size, size)

  if (sum(k) == 0) {
    k[size, ] <- 1
  }
  k / sum(k)
}

#' @rdname kernels
#' @export
kernel_stripe <- function(n, mod, step = 1) {
  k <- matrix(0, n, n)
  sq <- seq_len(n)
  for (i in sq) {
    for (j in sq) {
      k[i, j] <- (step * i + j) %% mod
    }
  }
  if (!all(is.finite(k))) {
    cli::cli_warn(
      "`mod` and `step` may not be suitable for this kernel."
    )
  }
  k / sum(k)
}

#' Tile a numeric matrix to a nativeRaster pattern
#'
#' @description
#' Repeats a numeric matrix `x` to fill an image of size
#' `width` by `height`, then returns it as a grayscale `nativeRaster`
#' (RGB channels are identical; alpha is set to 255).
#'
#' This is mainly intended to build threshold/texture maps for effects such as
#' [screen_tone()], where small matrices (e.g. Bayer matrices or custom kernels)
#' are tiled across an image.
#'
#' Values are clamped to `[0, 255]` before being packed.
#'
#' @param x A numeric matrix. Interpreted as a single-channel pattern.
#' @param width,height Integers. Output image width and height in pixels.
#' @returns A `nativeRaster` of dimensions `height * width`.
#' @examples
#' # 4x4 Bayer matrix, scaled to 0..255
#' b4 <- kernel_bayer(4, normalize = FALSE) * 255
#' \dontrun{
#' pat <- tile_matrix(b4, width = 320, height = 180)
#' grid::grid.newpage()
#' grid::grid.raster(pat, interpolate = FALSE)
#' }
#' @export
tile_matrix <- function(x, width, height) {
  if (!is.matrix(x) || !is.numeric(x)) {
    cli::cli_abort("`x` must be a numeric matrix.")
  }

  width <- as.integer(width[1])
  height <- as.integer(height[1])
  if (!is.finite(width) || !is.finite(height) || width < 1L || height < 1L) {
    cli::cli_abort("`width` and `height` must be positive integers.")
  }

  x <- floor(clamp(x, 0, 255))

  nr <- nrow(x)
  nc <- ncol(x)

  # Tile by repeating indices
  ii <- rep_len(seq_len(nr), height)
  jj <- rep_len(seq_len(nc), width)
  pattern <- x[ii, jj, drop = FALSE]

  # Pack to grayscale RGB (nativeRaster is column-major: matrix [h, w])
  v <- as.double(pattern)
  rgb <- rbind(v, v, v)
  alpha <- rep(255, length(v))

  as_nr(azny_pack_integers(rgb, alpha, height, width))
}
