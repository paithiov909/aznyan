#include "aznyan_types.h"
#include <cpp11.hpp>

// チャンネル入替 (ch_chg)
[[cpp11::register]]
cpp11::raws azny_swap_channels(cpp11::raws png, cpp11::integers mapping) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  cv::Mat out(img.size(), img.type());

  const std::vector<int> ch = cpp11::as_cpp<std::vector<int>>(mapping);
  const int npairs = ch.size() / 2;

  if (img.channels() != npairs) {
    cpp11::stop("Invalid channel mapping. Image has ", img.channels(),
                " channels, but mapping has ", npairs, " pairs.");
  }
  cv::mixChannels(&img, 1, &out, 2, ch.data(), npairs);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

// リサイズ (resizefilter)
[[cpp11::register]]
cpp11::raws azny_resize(cpp11::raws png, cpp11::doubles wh, int resize_mode,
                        bool set_size) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  int wt = img.size().width;
  int ht = img.size().height;

  cv::Mat out;
  if (set_size) {
    auto new_w = std::clamp(wh[0], 0.0, static_cast<double>(wt));
    auto new_h = std::clamp(wh[1], 0.0, static_cast<double>(ht));
    cv::resize(img, out, cv::Size(new_w, new_h), 0.0, 0.0,
               aznyan::rsmode[resize_mode]);
  } else {
    auto coef_w = wh[0];
    auto coef_h = wh[1];
    cv::resize(img, out, cv::Size(), coef_w, coef_h,
               aznyan::rsmode[resize_mode]);
  }

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

// リサンプル (resample)
[[cpp11::register]]
cpp11::raws azny_resample(cpp11::raws png, cpp11::doubles wh, int resize_red,
                          int resize_exp) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  int wt = img.size().width;
  int ht = img.size().height;
  auto coef_w = wh[0]; // std::clamp(wh[0], 0.0, 1.0);
  auto coef_h = wh[1]; // std::clamp(wh[1], 0.0, 1.0);

  cv::Mat eximg, rdimg;
  cv::resize(img, rdimg, cv::Size(), coef_w, coef_h,
             aznyan::rsmode[resize_red]);

  auto cx = static_cast<double>(wt) / rdimg.size().width;
  auto cy = static_cast<double>(ht) / rdimg.size().height;
  cv::resize(rdimg, eximg, cv::Size(), cx, cy, aznyan::rsmode[resize_exp]);

  std::vector<unsigned char> ret;
  cv::imencode(".png", eximg, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}
