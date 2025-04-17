#pragma once
#include <thread>
#include <opencv2/opencv.hpp>

namespace aznyan {

static const std::vector<int> params = {cv::IMWRITE_PNG_COMPRESSION, 1};

static const std::vector<int> mode_a{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                                     cv::BORDER_REFLECT, cv::BORDER_REFLECT_101,
                                     cv::BORDER_ISOLATED};

static const std::vector<int> mode_b{cv::BORDER_CONSTANT, cv::BORDER_REPLICATE,
                                     cv::BORDER_REFLECT, cv::BORDER_WRAP,
                                     cv::BORDER_REFLECT_101};

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
