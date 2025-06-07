#pragma once
#include <thread>
#include <opencv2/opencv.hpp>
#include <cpp11.hpp>

namespace aznyan {

static const std::vector<int> params = {cv::IMWRITE_PNG_COMPRESSION, 1};

/**
 * 0-4
 */
static const std::vector<int> mode_a{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                                     cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                                     cv::BORDER_ISOLATED};
/**
 * 0-4
 */
static const std::vector<int> mode_b{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                                     cv::BORDER_REFLECT, cv::BORDER_WRAP,
                                     cv::BORDER_REFLECT_101};
/**
 * 0-2
 */
static const std::vector<int> kshape{cv::MORPH_RECT, cv::MORPH_CROSS,
                                     cv::MORPH_ELLIPSE};
/**
 * 0-7
 */
static const std::vector<int> opmode{cv::MORPH_ERODE,    cv::MORPH_DILATE,
                                     cv::MORPH_OPEN,     cv::MORPH_CLOSE,
                                     cv::MORPH_GRADIENT, cv::MORPH_TOPHAT,
                                     cv::MORPH_BLACKHAT, cv::MORPH_HITMISS};
/**
 * 0-6
 */
static const std::vector<int> rsmode{
    cv::INTER_NEAREST,      cv::INTER_LINEAR,   cv::INTER_CUBIC,
    cv::INTER_AREA,         cv::INTER_LANCZOS4, cv::INTER_LINEAR_EXACT,
    cv::INTER_NEAREST_EXACT};

/**
 * 0-6
 */
static const std::vector<int> tmode_a{
    cv::THRESH_BINARY,  cv::THRESH_BINARY_INV, cv::THRESH_TRUNC,
    cv::THRESH_TOZERO,  cv::THRESH_TOZERO_INV, cv::THRESH_OTSU,
    cv::THRESH_TRIANGLE};

/**
 * 0-1
 */
static const std::vector<int> tmode_b{cv::THRESH_BINARY_INV, cv::THRESH_BINARY};

/**
 * 0-1
 */
static const std::vector<int> adp_mode{cv::ADAPTIVE_THRESH_MEAN_C,
                                       cv::ADAPTIVE_THRESH_GAUSSIAN_C};

template <class FUNC>
inline void parallel_for(int st, int ed, FUNC func) {
  int num_cpu = std::thread::hardware_concurrency();
  int nstripes = (ed - st + num_cpu - 1) / num_cpu;
  cv::parallel_for_(
      cv::Range(st, ed),
      [&func](const cv::Range& range) {
        for (int idx = range.start; idx < range.end; idx++) {
          func(idx);
        }
      },
      nstripes);
}

// template <class I, class FUNC>
// inline void parallel_for_each(&I items, FUNC func) {
//   auto begin = std::begin(items);
//   auto size = std::distance(begin, std::end(items));
//   int num_cpu = std::thread::hardware_concurrency();
//   int nstripes = (size + num_cpu - 1) / num_cpu;
//   cv::parallel_for_(
//       cv::Range(0, size),
//       [&func, begin](const cv::Range& range) {
//         for (int idx = range.start; idx < range.end; idx++) {
//           func(*(begin + idx));
//         }
//       },
//       nstripes);
// }

// Decode raws to cv::Mat using 'cv::IMREAD_UNCHANGED'
inline cv::Mat decode_raws(const cpp11::raws& png) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  return img;
}

inline cpp11::raws encode_raws(const cv::Mat& img) {
  std::vector<unsigned char> ret;
  cv::imencode(".png", img, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}

inline std::tuple<std::vector<cv::Mat>, std::vector<int>> split_bgra(const cv::Mat& img) {
  if (img.channels() != 4) {
    cpp11::stop("Image must have 4 channels.");
  }
  cv::Mat bgr(img.size(), CV_8UC3), alpha(img.size(), CV_8U);
  std::vector<cv::Mat> bgra{bgr, alpha};
  std::vector<int> ch{0, 0, 1, 1, 2, 2, 3, 3};
  cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 4);
  return std::make_tuple(bgra, ch);
}

};  // namespace aznyan

#if CV_VERSION_EPOCH >= 3 || \
    (!defined(CV_VERSION_EPOCH) && CV_VERSION_MAJOR >= 3)
#define HAVE_OPENCV_3
#endif

#if !defined(CV_VERSION_EPOCH) && CV_VERSION_MAJOR >= 4
#define HAVE_OPENCV_4
#endif

#if (CV_VERSION_MAJOR * 100 + CV_VERSION_MINOR * 10 + CV_VERSION_REVISION >= \
     452)
#define HAVE_WECHATQR
#endif

#if (CV_VERSION_MAJOR * 100 + CV_VERSION_MINOR * 10 + CV_VERSION_REVISION >= \
     344)
#define HAVE_QUIRC
#endif
