#include "aznyan_types.h"
#include <cpp11.hpp>

[[cpp11::register]]
cpp11::raws azny_sobelfilter(cpp11::raws png, int ksize, bool balp, int dx,
                             int dy, int border, double scale, double delta) {
  std::vector<unsigned char> png_data(png.begin(), png.end());
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  // FIXME: alpha is actually not used here.
  cv::Mat bgr(img.size(), CV_8UC3), alpha(img.size(), CV_8U);
  std::vector<cv::Mat> bgra{bgr, alpha};

  if (img.channels() == 4) {
    std::vector<int32_t> ch{0, 0, 1, 1, 2, 2, 3, 3};
    cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 4);
  } else if (img.channels() == 3) {
    std::vector<int32_t> ch{0, 0, 1, 1, 2, 2};
    cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 3);
  } else {
    cpp11::stop("Image must have 3 or 4 channels.");
  }

  cv::Mat tmpB, tmpC, tmpD, tmpE;
  cv::cvtColor(bgr, tmpB, cv::COLOR_BGR2GRAY);
  tmpB.convertTo(tmpC, CV_32F, 1.0 / 255, 0.0);

  std::vector<int32_t> mode{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                            cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                            cv::BORDER_ISOLATED};

  ksize = std::max(2 * ksize - 1, 0);
  cv::Sobel(tmpC, tmpD, -1, dx, dy, ksize, scale, delta, mode[border]);
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
cpp11::raws azny_sobelrgb(cpp11::raws png, int ksize, bool balp, int dx, int dy,
                          int border, double scale, double delta) {
  std::vector<unsigned char> png_data(png.begin(), png.end());
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
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

  std::vector<int32_t> mode{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                            cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                            cv::BORDER_ISOLATED};

  ksize = std::max(2 * ksize - 1, 0);
  cv::Mat tmpC = cv::Mat::zeros(img.size(), CV_32F);
  cv::Mat tmpD, tmpF;
  for (auto i = 0; i < 3; ++i) {
    cv::Mat tmpE;
    cv::Sobel(ch_col[i], tmpE, -1, dx, dy, ksize, scale, delta, mode[border]);
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
