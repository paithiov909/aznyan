#include "aznyan_types.h"

[[cpp11::register]]
cpp11::raws azny_medianblur(cpp11::raws png, int ksize) {
  cv::Mat img = aznyan::decode_raws(png);
  cv::Mat out;
  cv::medianBlur(img, out, 2 * ksize + 1);

  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_boxblur(cpp11::raws png, int boxW, int boxH, bool normalize,
                         int border) {
  cv::Mat img = aznyan::decode_raws(png);
  cv::Mat out;
  cv::boxFilter(img, out, -1, cv::Size(boxW, boxH), cv::Point(-1, -1),
                normalize, aznyan::mode_a[border]);

  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_gaussianblur(cpp11::raws png, int boxW, int boxH,
                              double sigmaX, double sigmaY, int border) {
  cv::Mat img = aznyan::decode_raws(png);
  int kx = std::max(2 * boxW - 1, 0);
  int ky = std::max(2 * boxH - 1, 0);
  cv::Mat out;
  cv::GaussianBlur(img, out, cv::Size(kx, ky), sigmaX, sigmaY,
                   aznyan::mode_a[border]);

  return aznyan::encode_raws(out);
}

[[cpp11::register]]
cpp11::raws azny_bilateralblur(cpp11::raws png, int d, double sigmacolor,
                               double sigmaspace, int border, bool alphasync) {
  const cv::Mat img = aznyan::decode_raws(png);
  auto [bgra, ch] = aznyan::split_bgra(img);

  cv::Mat tmpB, tmpC;
  cv::bilateralFilter(bgra[0], tmpB, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
  bgra[0] = tmpB.clone();
  if (alphasync) {
    cv::bilateralFilter(bgra[1], tmpC, d, sigmacolor, sigmaspace, aznyan::mode_b[border]);
    bgra[1] = tmpC.clone();
  }
  cv::Mat out(img.size(), img.type());
  cv::mixChannels(bgra.data(), 2, &out, 1, ch.data(), 4);

  return aznyan::encode_raws(out);
}
