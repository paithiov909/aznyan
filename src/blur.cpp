#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_medianblur(const cpp11::integers& nr, int height,
                                int width, int ksize) {
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
cpp11::integers azny_gaussianblur(const cpp11::integers& nr, int height,
                                  int width, int boxW, int boxH, double sigmaX,
                                  double sigmaY, int border) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  int kx = std::max(2 * boxW - 1, 0);
  int ky = std::max(2 * boxH - 1, 0);
  cv::Mat out;
  cv::GaussianBlur(bgra[0], out, cv::Size(kx, ky), sigmaX, sigmaY,
                   aznyan::mode_a[border]);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_bilateralblur(const cpp11::integers& nr, int height,
                                   int width, int d, double sigmacolor,
                                   double sigmaspace, int border,
                                   bool alphasync) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat out1, out2;
  cv::bilateralFilter(bgra[0], out1, d, sigmacolor, sigmaspace,
                      aznyan::mode_b[border]);
  if (alphasync) {
    cv::bilateralFilter(bgra[1], out2, d, sigmacolor, sigmaspace,
                        aznyan::mode_b[border]);
  } else {
    out2 = bgra[1];
  }
  return aznyan::encode_nr(out1, out2);
}

[[cpp11::register]]
cpp11::integers azny_convolve(const cpp11::integers& nr, int height, int width,
                              const cpp11::doubles_matrix<>& kernel, int border,
                              bool alphasync) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat filter(kernel.nrow(), kernel.ncol(), CV_64FC1, kernel.data());
  filter.convertTo(filter, CV_32FC1);

  cv::Mat in1, in2, out1, out2;

  bgra[0].convertTo(in1, CV_32FC3, 1.0 / 255, 0.0);
  cv::filter2D(in1, out1, -1, filter, cv::Point(-1, -1), 0.0,
               aznyan::mode_a[border]);
  cv::convertScaleAbs(out1, out1, 255.0);

  if (alphasync) {
    bgra[1].convertTo(in2, CV_32FC1, 1.0 / 255, 0.0);
    cv::filter2D(in2, out2, -1, filter, cv::Point(-1, -1), 0.0,
                 aznyan::mode_a[border]);
    cv::convertScaleAbs(out2, out2, 255.0);
  } else {
    out2 = bgra[1];
  }
  return aznyan::encode_nr(out1, out2);
}
