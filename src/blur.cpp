#include "aznyan_types.h"
#include <cpp11.hpp>

[[cpp11::register]]
cpp11::raws azny_medianblur(cpp11::raws png, int ksize) {
  std::vector<unsigned char> png_data(png.begin(), png.end());
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("cv::Mat array is empty!");
  }
  cv::Mat tmp;
  cv::medianBlur(img, tmp, 2 * ksize + 1);

  std::vector<unsigned char> out;
  cv::imencode(".png", tmp, out, aznyan::params);
  return cpp11::writable::raws{std::move(out)};
}

[[cpp11::register]]
cpp11::raws azny_boxblur(cpp11::raws png, int box_w, int box_h, bool normalize,
                         int border) {
  std::vector<unsigned char> png_data(png.begin(), png.end());
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("cv::Mat array is empty!");
  }
  std::vector<int> mode{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                        cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                        cv::BORDER_ISOLATED};
  cv::Mat tmp;
  cv::boxFilter(img, tmp, -1, cv::Size(box_w, box_h), cv::Point(-1, -1),
                normalize, mode[border]);

  std::vector<unsigned char> out;
  cv::imencode(".png", tmp, out, aznyan::params);
  return cpp11::writable::raws{std::move(out)};
}

[[cpp11::register]]
cpp11::raws azny_gaussianblur(cpp11::raws png, int box_w, int box_h,
                              double sigma_x, double sigma_y, int border) {
  std::vector<unsigned char> png_data(png.begin(), png.end());
  cv::Mat img = cv::imdecode(png_data, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("cv::Mat array is empty!");
  }
  std::vector<int> mode{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                        cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                        cv::BORDER_ISOLATED};
  int kx = std::max(2 * box_w - 1, 0);
  int ky = std::max(2 * box_h - 1, 0);
  cv::Mat tmp;
  cv::GaussianBlur(img, tmp, cv::Size(kx, ky), sigma_x, sigma_y, mode[border]);

  std::vector<unsigned char> out;
  cv::imencode(".png", tmp, out, aznyan::params);
  return cpp11::writable::raws{std::move(out)};
}

// TODO: bilateralblur?
