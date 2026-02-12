#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_cannyfilter(const cpp11::integers& nr, int height,
                                 int width, int asize, bool balp, bool gradient,
                                 double thres1, double thres2) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGRA2GRAY);
  cv::Canny(tmpB, tmpC, thres1, thres2, 2 * asize - 1, gradient);

  if (balp) {
    cv::threshold(tmpC, bgra[1], 0.1, 255, cv::THRESH_BINARY);
  }
  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpC, tmpC, tmpC}, out);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_cannyrgb(const cpp11::integers& nr, int height, int width, int asize, bool balp, bool gradient,
                          double thres1, double thres2) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  std::vector<cv::Mat> ch_col;
  cv::split(bgra[0], ch_col);
  ch_col.push_back(bgra[1]);

  cv::Mat tmpB = cv::Mat::zeros(bgra[0].size(), CV_8U);
  for (int i = 0; i < 3; ++i) {
    cv::Mat tmpC;
    cv::Canny(ch_col[i], tmpC, thres1, thres2, 2 * asize - 1, gradient);
    cv::add(tmpB, tmpC, tmpB);
  }
  if (balp) {
    cv::threshold(tmpB, ch_col[3], 0.1, 255, cv::THRESH_BINARY);
  }
  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpB, tmpB, tmpB}, out);
  return aznyan::encode_nr(out, ch_col[3]);
}
