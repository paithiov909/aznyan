#' Generate common convolution kernels
#'
#' A collection of helper functions that generate numeric matrices usable as
#' convolution kernels. These kernels are intended for use with `convolve()`
#' and other filtering operations in this package.
#'
#' @details
#' The following kernel constructors are available:
#'
#' * `kernel_cone`: A cone-shaped, radially weighted kernel.
#' * `kernel_disc`: A uniformly weighted disc kernel.
#' * `kernel_emboss`: A direction-aware emboss kernel.
#' * `kernel_motion`: A linear motion kernel oriented by `theta`.
#' * `kernel_ring`: A ring-shaped (donut-like) kernel.
#'
#' @param size An odd integer specifying the kernel size.
#' @param theta A numeric value (in radians) specifying the orientation.
#' @param thickness A numeric value controlling ring thickness.
#' Defaults to `1`.
#' @param strength A numeric value controlling emboss intensity.
#' Defaults to `1`.
#' @returns A numeric matrix.
#' @rdname kernels
#' @name make-kernels
NULL

#' @rdname kernels
#' @name make-kernels
#' @export
kernel_cone <- function(size) {
  if (size %% 2 != 1) {
    rlang::abort("`size` must be an odd integer.")
  }
  r <- (size - 1) / 2
  xy <- expand.grid(-r:r, -r:r)
  d <- sqrt(rowSums(xy^2))
  k <- pmax(1 - (d - r), 0)
  matrix(k / sum(k), size, size)
}

#' @rdname kernels
#' @name make-kernels
#' @export
kernel_disc <- function(size) {
  if (size %% 2 != 1) {
    rlang::abort("`size` must be an odd integer.")
  }
  r <- (size - 1) / 2

  yy <- rep(-r:r, each = size)
  xx <- rep(-r:r, times = size)
  mask <- (xx^2 + yy^2) <= r^2

  k <- matrix(as.numeric(mask), size, size)
  k / sum(k)
}

#' @rdname kernels
#' @name make-kernels
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
#' @name make-kernels
#' @export
kernel_motion <- function(size, theta) {
  if (size %% 2 != 1) {
    rlang::abort("`size` must be an odd integer.")
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
#' @name make-kernels
#' @export
kernel_ring <- function(size, thickness = 1) {
  if (size %% 2 != 1) {
    rlang::abort("`size` must be an odd integer.")
  }
  if (thickness < 1) {
    rlang::abort("`thickness` must be at least 1.")
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
