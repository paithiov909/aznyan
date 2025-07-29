#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_sobelfilter(const cpp11::integers& nr, int height,
                                 int width, int ksize, bool balp, int dx,
                                 int dy, int border, double scale,
                                 double delta) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB, tmpC, tmpD, tmpE;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  tmpB.convertTo(tmpC, CV_32F, 1.0 / 255, 0.0);

  ksize = std::max(2 * ksize - 1, 0);
  cv::Sobel(tmpC, tmpD, -1, dx, dy, ksize, scale, delta,
            aznyan::mode_a[border]);
  cv::convertScaleAbs(tmpD, tmpE, 255.0, 0.0);

  if (balp) cv::threshold(tmpE, bgra[1], 0.1, 255, cv::THRESH_BINARY);

  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpE, tmpE, tmpE};
  cv::merge(ch_out, out);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_sobelrgb(const cpp11::integers& nr, int height, int width,
                              int ksize, bool balp, int dx, int dy, int border,
                              double scale, double delta) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  bgra[0].convertTo(bgra[0], CV_32FC4, 1.0 / 255, 0.0);
  bgra[1].convertTo(bgra[1], CV_32FC4, 1.0 / 255, 0.0);

  std::vector<cv::Mat> ch_col;
  cv::split(bgra[0], ch_col);
  ch_col.push_back(bgra[1]);

  ksize = std::max(2 * ksize - 1, 0);
  cv::Mat tmpC = cv::Mat::zeros(bgra[0].size(), CV_32F);
  cv::Mat tmpD, tmpF;
  for (auto i = 0; i < 3; ++i) {
    cv::Mat tmpE;
    cv::Sobel(ch_col[i], tmpE, -1, dx, dy, ksize, scale, delta,
              aznyan::mode_a[border]);
    cv::add(tmpC, tmpE, tmpC);
  }
  cv::convertScaleAbs(tmpC, tmpD, 255.0, 0.0);

  if (balp) {
    cv::threshold(tmpD, tmpF, 0.1, 255, cv::THRESH_BINARY);
  } else {
    cv::convertScaleAbs(ch_col[3], tmpF, 255.0, 0.0);
  }
  cv::Mat out;
  std::vector<cv::Mat> ch_out{tmpD, tmpD, tmpD};
  cv::merge(ch_out, out);
  return aznyan::encode_nr(out, tmpF);
}
