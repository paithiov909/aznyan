#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_thres(const cpp11::integers& nr, int height, int width,
                           double thres, double maxv, int mode) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  cv::threshold(tmpB, tmpC, thres, maxv, aznyan::thresmode[mode]);

  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpC, tmpC, tmpC}, out);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_adpthres(const cpp11::integers& nr, int height, int width,
                              bool adpthres, double maxv, int bsize, bool mode,
                              double valC) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  const auto adp_mode =
      adpthres ? cv::ADAPTIVE_THRESH_GAUSSIAN_C : cv::ADAPTIVE_THRESH_MEAN_C;
  const auto thres_type = mode ? cv::THRESH_BINARY : cv::THRESH_BINARY_INV;

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  cv::adaptiveThreshold(tmpB, tmpC, maxv, adp_mode, thres_type, 2 * bsize + 1,
                        valC);
  cv::Mat out;
  cv::merge(std::vector<cv::Mat>{tmpC, tmpC, tmpC}, out);
  return aznyan::encode_nr(out, bgra[1]);
}
