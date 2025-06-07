#include "aznyan_types.h"

[[cpp11::register]]
cpp11::raws azny_cannyfilter(cpp11::raws png, int asize, bool balp,
                             bool gradient, double thres1, double thres2) {
  cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGRA2GRAY);
  cv::Canny(tmpB, tmpC, thres1, thres2, 2 * asize - 1, gradient);

  if (balp) cv::threshold(tmpC, bgra[1], 0.1, 255, cv::THRESH_BINARY);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpC, tmpC, tmpC, bgra[1]};
  cv::merge(ch_out, out);
  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_cannyrgb(cpp11::raws png, int asize, bool balp, bool gradient,
                          double thres1, double thres2) {
  cv::Mat img = aznyan::decode_raws(png);
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
  return aznyan::encode_raws(out);
}
