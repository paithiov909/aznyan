#include "aznyan_types.h"
#include <cpp11.hpp>

[[cpp11::register]]
cpp11::raws azny_medianblur(cpp11::raws png, int ksize) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  cv::Mat out;
  cv::medianBlur(img, out, 2 * ksize + 1);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

[[cpp11::register]]
cpp11::raws azny_boxblur(cpp11::raws png, int boxW, int boxH, bool normalize,
                         int border) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  cv::Mat out;
  cv::boxFilter(img, out, -1, cv::Size(boxW, boxH), cv::Point(-1, -1),
                normalize, aznyan::mode_a[border]);
  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

[[cpp11::register]]
cpp11::raws azny_gaussianblur(cpp11::raws png, int boxW, int boxH,
                              double sigmaX, double sigmaY, int border) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  int32_t kx = std::max(2 * boxW - 1, 0);
  int32_t ky = std::max(2 * boxH - 1, 0);

  cv::Mat out;
  cv::GaussianBlur(img, out, cv::Size(kx, ky), sigmaX, sigmaY,
                   aznyan::mode_a[border]);
  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

[[cpp11::register]]
cpp11::raws azny_bilateralblur(cpp11::raws png, int d, double sigmacolor,
                               double sigmaspace, int border, bool alphasync) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  cv::Mat bgr(img.size(), CV_8UC3), alpha(img.size(), CV_8U);
  std::vector<cv::Mat> bgra{bgr, alpha};
  std::vector<int32_t> ch{0, 0, 1, 1, 2, 2, 3, 3};
  cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 4);

  cv::Mat tmpB, tmpC;
  cv::bilateralFilter(bgra[0], tmpB, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
  bgra[0] = tmpB.clone();
  if (alphasync) {
    cv::bilateralFilter(bgra[1], tmpC, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
    bgra[1] = tmpC.clone();
  }

  cv::Mat out(img.size(), img.type());
  cv::mixChannels(bgra.data(), 2, &out, 1, ch.data(), 4);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}
