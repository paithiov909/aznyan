#pragma once
#include <opencv2/opencv.hpp>

namespace aznyan {

static const std::vector<int> params = {cv::IMWRITE_PNG_COMPRESSION, 1};

};

#if CV_VERSION_EPOCH >= 3 || (!defined(CV_VERSION_EPOCH) && CV_VERSION_MAJOR >= 3)
#define HAVE_OPENCV_3
#endif

#if !defined(CV_VERSION_EPOCH) && CV_VERSION_MAJOR >= 4
#define HAVE_OPENCV_4
#endif

#if (CV_VERSION_MAJOR * 100 + CV_VERSION_MINOR * 10 + CV_VERSION_REVISION >= 452)
#define HAVE_WECHATQR
#endif

#if (CV_VERSION_MAJOR * 100 + CV_VERSION_MINOR * 10 + CV_VERSION_REVISION >= 344)
#define HAVE_QUIRC
#endif
