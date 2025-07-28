#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_medianblur(const cpp11::integers& nr, int height, int width, int ksize) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out;
  cv::medianBlur(bgra[0], out, 2 * ksize + 1);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_boxblur(const cpp11::integers& nr, int height, int width,
                             int boxW, int boxH, bool normalize, int border) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out;
  cv::boxFilter(bgra[0], out, -1, cv::Size(boxW, boxH), cv::Point(-1, -1),
                normalize, aznyan::mode_a[border]);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_gaussianblur(const cpp11::integers& nr, int height, int width,
                                  int boxW, int boxH,
                                  double sigmaX, double sigmaY, int border) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  int kx = std::max(2 * boxW - 1, 0);
  int ky = std::max(2 * boxH - 1, 0);
  cv::Mat out;
  cv::GaussianBlur(bgra[0], out, cv::Size(kx, ky), sigmaX, sigmaY,
                   aznyan::mode_a[border]);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_bilateralblur(const cpp11::integers& nr, int height, int width,
                                   int d, double sigmacolor,
                                   double sigmaspace, int border, bool alphasync) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB, tmpC;
  cv::bilateralFilter(bgra[0], tmpB, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
  bgra[0] = tmpB.clone();
  if (alphasync) {
    cv::bilateralFilter(bgra[1], tmpC, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
    bgra[1] = tmpC.clone();
  }
  return aznyan::encode_nr(bgra[0], bgra[1]);
}
