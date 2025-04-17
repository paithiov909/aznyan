#include "aznyan_types.h"
#include <cpp11.hpp>

[[cpp11::register]]
cpp11::raws azny_cannyfilter(cpp11::raws png, int asize, bool balp,
                             bool gradient, double thres1, double thres2) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
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
  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgr, tmpB, cv::COLOR_BGRA2GRAY);
  cv::Canny(tmpB, tmpC, thres1, thres2, 2 * asize - 1, gradient);

  if (balp) cv::threshold(tmpC, bgra[1], 0.1, 255, cv::THRESH_BINARY);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpC, tmpC, tmpC, bgra[1]};
  cv::merge(ch_out, out);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

[[cpp11::register]]
cpp11::raws azny_cannyrgb(cpp11::raws png, int asize, bool balp, bool gradient,
                          double thres1, double thres2) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  if (!balp && img.channels() != 4) {
    cpp11::stop("Image must have 4 channels when balp is false.");
  }
  std::vector<cv::Mat> ch_col;
  cv::split(img, ch_col);

  cv::Mat tmpB = cv::Mat::zeros(img.size(), CV_8U);
  for (auto i = 0; i < 3; ++i) {
    cv::Mat tmpC;
    cv::Canny(ch_col[i], tmpC, thres1, thres2, 2 * asize - 1, gradient);
    cv::add(tmpB, tmpC, tmpB);
  }

  if (balp) cv::threshold(tmpB, ch_col[3], 0.1, 255, cv::THRESH_BINARY);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpB, tmpB, tmpB, ch_col[3]};
  cv::merge(ch_out, out);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}
