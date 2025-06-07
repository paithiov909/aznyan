#include "aznyan_types.h"

[[cpp11::register]]
cpp11::raws azny_meanshift(cpp11::raws png, double sp, double sr, int maxl) {
  cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);

  cv::Mat tmpB, out(img.size(), img.type());
  cv::pyrMeanShiftFiltering(bgra[0], tmpB, sp, sr, maxl);
  bgra[0] = tmpB.clone();
  cv::mixChannels(bgra.data(), 2, &out, 1, ch.data(), 4);

  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_preserve_edges(cpp11::raws png, float sgmS, float sgmR,
                                bool mode) {
  cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);
  const auto flag = mode ? cv::RECURS_FILTER : cv::NORMCONV_FILTER;

  cv::Mat tmpB;
  edgePreservingFilter(bgra[0], tmpB, flag, std::clamp(sgmS, 0.f, 200.f),
                       std::clamp(sgmR, 0.f, 1.f));

  cv::Mat out(img.size(), img.type());
  bgra[0] = tmpB.clone();
  cv::mixChannels(bgra.data(), 2, &out, 1, ch.data(), 4);

  return aznyan::encode_raws(out);
}
