#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_meanshift(const cpp11::integers& nr, int height, int width,
                               double sp, double sr, int maxl) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB;
  cv::pyrMeanShiftFiltering(bgra[0], tmpB, sp, sr, maxl);

  return aznyan::encode_nr(tmpB, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_preserve_edges(const cpp11::integers& nr, int height,
                                    int width, float sgmS, float sgmR,
                                    bool mode) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  const auto flag = mode ? cv::RECURS_FILTER : cv::NORMCONV_FILTER;

  cv::Mat tmpB;
  edgePreservingFilter(bgra[0], tmpB, flag, std::clamp(sgmS, 0.f, 200.f),
                       std::clamp(sgmR, 0.f, 1.f));

  return aznyan::encode_nr(tmpB, bgra[1]);
}
