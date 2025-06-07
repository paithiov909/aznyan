#include "aznyan_types.h"

[[cpp11::register]]
cpp11::raws azny_thres(cpp11::raws png, double thres, double maxv, int mode) {
  cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  cv::threshold(tmpB, tmpC, thres, maxv, aznyan::thresmode[mode]);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpC, tmpC, tmpC, bgra[1]};
  cv::merge(ch_out, out);
  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_adpthres(cpp11::raws png, bool adpthres, double maxv,
                          int bsize, bool mode, double valC) {
  cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);

  const auto adp_mode =
      adpthres ? cv::ADAPTIVE_THRESH_GAUSSIAN_C : cv::ADAPTIVE_THRESH_MEAN_C;
  const auto thres_type = mode ? cv::THRESH_BINARY : cv::THRESH_BINARY_INV;

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  cv::adaptiveThreshold(tmpB, tmpC, maxv, adp_mode, thres_type, 2 * bsize + 1,
                        valC);
  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpC, tmpC, tmpC, bgra[1]};
  cv::merge(ch_out, out);
  return aznyan::encode_raws(out);
}
