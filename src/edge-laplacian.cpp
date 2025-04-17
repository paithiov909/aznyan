#include "aznyan_types.h"
#include <cpp11.hpp>

[[cpp11::register]]
cpp11::raws azny_laplacianfilter(cpp11::raws png, int ksize, bool balp,
                                 int border, double scale, double delta) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  cv::Mat bgr(img.size(), CV_8UC3), alpha(img.size(), CV_8U);
  std::vector<cv::Mat> bgra{bgr, alpha};

  if (img.channels() == 4) {
    std::vector<int32_t> ch{0, 0, 1, 1, 2, 2, 3, 3};
    cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 4);
  } else {
    cpp11::stop("Image must have 4 channels.");
  }
  cv::Mat tmpB, tmpC, tmpD, tmpE;
  cv::cvtColor(img, tmpB, cv::COLOR_BGRA2GRAY);
  tmpB.convertTo(tmpC, CV_32F, 1.0 / 255.0, 0.0);

  ksize = std::max(2 * ksize - 1, 0);
  cv::Laplacian(tmpC, tmpD, -1, ksize, scale, delta, aznyan::mode_a[border]);
  cv::convertScaleAbs(tmpD, tmpE, 255.0, 0.0);

  if (balp) cv::threshold(tmpE, bgra[1], 0.1, 255, cv::THRESH_BINARY);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpE, tmpE, tmpE, bgra[1]};
  cv::merge(ch_out, out);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

[[cpp11::register]]
cpp11::raws azny_laplacianrgb(cpp11::raws png, int ksize, bool balp, int border,
                              double scale, double delta) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  if (!balp && img.channels() != 4) {
    cpp11::stop("Image must have 4 channels when balp is false.");
  }
  cv::Mat tmpB;
  img.convertTo(tmpB, CV_32FC4, 1.0 / 255, 0.0);

  std::vector<cv::Mat> ch_col;
  cv::split(tmpB, ch_col);

  ksize = std::max(2 * ksize - 1, 0);

  cv::Mat tmpC = cv::Mat::zeros(img.size(), CV_32F);
  cv::Mat tmpD, tmpF;
  for (auto i = 0; i < 3; ++i) {
    cv::Mat tmpE;
    cv::Laplacian(ch_col[i], tmpE, -1, ksize, scale, delta,
                  aznyan::mode_a[border]);
    cv::add(tmpC, tmpE, tmpC);
  }
  cv::convertScaleAbs(tmpC, tmpD, 255.0, 0.0);

  if (balp)
    cv::threshold(tmpD, tmpF, 0.1, 255, cv::THRESH_BINARY);
  else
    cv::convertScaleAbs(ch_col[3], tmpF, 255.0, 0.0);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpD, tmpD, tmpD, tmpF};
  cv::merge(ch_out, out);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}
