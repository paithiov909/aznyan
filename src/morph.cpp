#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_morphologyfilter(const cpp11::integers& nr, int height,
                                      int width, int ksize, int ktype, int mode,
                                      int iterations, int border,
                                      bool alphasync, cpp11::integers pt) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB = cv::Mat::zeros(bgra[0].size(), CV_8UC3);
  cv::Mat tmpC, tmpD;

  bgra[0].copyTo(tmpB, bgra[1]);
  cv::cvtColor(tmpB, tmpB, cv::COLOR_BGR2GRAY);
  ksize = std::max(2 * ksize - 1, 1);

  if (pt.size() < 2 || cpp11::is_na(pt[0]) || cpp11::is_na(pt[1])) {
    cpp11::stop("Invalid anchor point.");
  }
  cv::Point anchor(pt[0], pt[1]);
  cv::Mat kernel = getStructuringElement(aznyan::kshape[ktype],
                                         cv::Size(ksize, ksize), anchor);
  cv::morphologyEx(tmpB, tmpC, aznyan::opmode[mode], kernel, anchor, iterations,
                   aznyan::mode_a[border]);

  if (alphasync)
    cv::morphologyEx(bgra[1], tmpD, aznyan::opmode[mode], kernel, anchor,
                     iterations, aznyan::mode_a[border]);
  else
    tmpD = bgra[1].clone();

  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpC, tmpC, tmpC}, out);
  return aznyan::encode_nr(out, tmpD);
}

[[cpp11::register]]
cpp11::integers azny_morphologyrgb(const cpp11::integers& nr, int height,
                                   int width, cpp11::integers ksize, int ktype,
                                   int mode, int iterations, int border,
                                   bool alphasync, cpp11::integers pt) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB = cv::Mat::zeros(bgra[0].size(), CV_8UC3);
  bgra[0].copyTo(tmpB, bgra[1]);

  std::vector<cv::Mat> col_ch;
  cv::split(tmpB, col_ch);

  if (pt.size() < 2 || cpp11::is_na(pt[0]) || cpp11::is_na(pt[1])) {
    cpp11::stop("Invalid anchor point.");
  }
  cv::Point anchor(pt[0], pt[1]);

  if (ksize.size() != 3) {
    cpp11::stop("Invalid kernel size.");
  }
  std::vector<cv::Mat> kernel;
  for (auto i = 0; i < 3; ++i) {
    cv::Mat tmpB = getStructuringElement(
        aznyan::kshape[ktype], cv::Size(2 * ksize[i] - 1, 2 * ksize[i] - 1),
        anchor);
    kernel.emplace_back(tmpB);
    col_ch.emplace_back(bgra[1]);
  }

  cv::Mat tmpC = cv::Mat::zeros(bgra[0].size(), CV_8UC1);
  std::vector<cv::Mat> tmpD(6, tmpC);
  iterations = std::max(iterations, 1);
  aznyan::parallel_for(0, 6, [&](int32_t j) {
    cv::Mat tmpE;
    cv::morphologyEx(col_ch[j], tmpE, aznyan::opmode[mode], kernel[j % 3],
                     anchor, iterations, aznyan::mode_a[border]);
    tmpD[j] = tmpE.clone();
  });
  if (alphasync) {
    for (auto i = 0; i < 3; ++i) {
      cv::add(tmpC, tmpD[3 + i], tmpC);
    }
  } else {
    col_ch[3].copyTo(tmpC);
  }

  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpD[0], tmpD[1], tmpD[2]}, out);
  return aznyan::encode_nr(out, tmpC);
}
