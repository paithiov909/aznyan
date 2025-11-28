#pragma once
#include <thread>
#include <opencv2/opencv.hpp>
#include <cpp11.hpp>

namespace aznyan {

// static const std::vector<int> params = {cv::IMWRITE_PNG_COMPRESSION, 1};

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
static const std::vector<int> thresmode{
    cv::THRESH_BINARY,  cv::THRESH_BINARY_INV, cv::THRESH_TRUNC,
    cv::THRESH_TOZERO,  cv::THRESH_TOZERO_INV, cv::THRESH_OTSU,
    cv::THRESH_TRIANGLE};

/**
 * 0-21
 */
static const std::vector<int> cmmode{
    cv::COLORMAP_AUTUMN,   cv::COLORMAP_BONE,
    cv::COLORMAP_JET,      cv::COLORMAP_WINTER,
    cv::COLORMAP_RAINBOW,  cv::COLORMAP_OCEAN,
    cv::COLORMAP_SUMMER,   cv::COLORMAP_SPRING,
    cv::COLORMAP_COOL,     cv::COLORMAP_HSV,
    cv::COLORMAP_PINK,     cv::COLORMAP_HOT,
    cv::COLORMAP_PARULA,   cv::COLORMAP_MAGMA,
    cv::COLORMAP_INFERNO,  cv::COLORMAP_PLASMA,
    cv::COLORMAP_VIRIDIS,  cv::COLORMAP_CIVIDIS,
    cv::COLORMAP_TWILIGHT, cv::COLORMAP_TWILIGHT_SHIFTED,
    cv::COLORMAP_TURBO,    cv::COLORMAP_DEEPGREEN};

template <class FUNC>
inline void parallel_for(int st, int ed, FUNC func) {
  int num_cpu = cv::getNumThreads();
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

inline std::tuple<std::vector<cv::Mat>, std::vector<int>> split_bgra(
    const cv::Mat& img) {
  if (img.channels() != 4) {
    cpp11::stop("Image must have 4 channels.");
  }
  cv::Mat bgr(img.size(), CV_8UC3), alpha(img.size(), CV_8UC1);
  std::vector<cv::Mat> bgra{bgr, alpha};
  std::vector<int> ch{0, 0, 1, 1, 2, 2, 3, 3};
  cv::mixChannels(&img, 1, bgra.data(), 2, ch.data(), 4);
  return std::make_tuple(bgra, ch);
}

inline std::tuple<uchar, uchar, uchar, uchar> int_to_rgba(uint32_t icol) {
  return std::make_tuple(icol & 0xFF, (icol >> 8) & 0xFF, (icol >> 16) & 0xFF,
                         (icol >> 24) & 0xFF);
}

inline uint32_t pack_into_int(uchar r, uchar g, uchar b, uchar a) {
  return r | (g << 8) | (b << 16) | (a << 24);
}

// NOTE:
// rasterはrow-majorらしいので、integer_matrix<>で受け取るとアクセスがうまくいかないっぽい
inline std::tuple<std::vector<cv::Mat>, std::vector<int>> decode_nr(
    const cpp11::integers& nr, int height, int width) {
  cv::Mat bgr(height, width, CV_8UC3), alpha(height, width, CV_8UC1);
  parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto [r, g, b, a] = int_to_rgba(nr[i * width + j]);
      bgr.at<cv::Vec3b>(i, j) = cv::Vec3b(b, g, r);
      alpha.at<uchar>(i, j) = a;
    }
  });
  std::vector<cv::Mat> bgra{bgr, alpha};
  std::vector<int> ch{0, 0, 1, 1, 2, 2, 3, 3};
  return std::make_tuple(bgra, ch);
}

inline cpp11::integers encode_nr(const cv::Mat& bgr, const cv::Mat& alpha) {
  if (bgr.size() != alpha.size()) {
    cpp11::stop("BGR and alpha channels must have the same size.");
  }
  const int height = bgr.rows, width = bgr.cols;
  std::vector<uint32_t> dat(height * width);
  parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const cv::Vec3b& v = bgr.at<cv::Vec3b>(i, j);
      const uchar a = alpha.at<uchar>(i, j);
      dat[i * width + j] = pack_into_int(v[2], v[1], v[0], a);
    }
  });
  cpp11::writable::integers out = cpp11::as_sexp(dat);
  out.attr("dim") = cpp11::as_sexp({height, width});
  return out;
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
