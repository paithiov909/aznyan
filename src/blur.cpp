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
cpp11::integers azny_bilateral(const cpp11::integers& nr, int height, int width,
                               int d, double sigmacolor, double sigmaspace,
                               int border, bool alphasync) {
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

[[cpp11::register]]
cpp11::integers azny_kuwahara(const cpp11::integers& nr, int height, int width,
                              const cpp11::doubles_matrix<>& kernel1,
                              const cpp11::doubles_matrix<>& kernel2,
                              double beta, int border) {
  // Based on <https://qiita.com/Cartelet/items/7773cd56c7ce016476d9>
  const auto calc_ev = [](const cv::Mat& aout, const cv::Mat& bout,
                          const double& beta) {
    cv::Mat v, v1ch;
    cv::multiply(aout, aout, v);
    v = bout - v;

    if (v.channels() == 3) {
      std::vector<cv::Mat> chs;
      cv::split(v, chs);
      v1ch = chs[0] + chs[1] + chs[2];
    } else {
      v1ch = v;
    }
    double vmax;
    cv::minMaxLoc(v1ch, nullptr, &vmax);

    if (vmax < 1e-12) vmax = 1e-12;
    cv::Mat vn;
    v1ch.convertTo(vn, CV_32F, 1.0 / vmax);

    cv::Mat tmp = -beta * cv::abs(vn);
    cv::Mat ev;
    cv::exp(tmp, ev);

    return ev;
  };

  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat filter1(kernel1.nrow(), kernel1.ncol(), CV_64FC1, kernel1.data());
  filter1.convertTo(filter1, CV_32FC1);
  cv::Mat filter2(kernel2.nrow(), kernel2.ncol(), CV_64FC1, kernel2.data());
  filter2.convertTo(filter2, CV_32FC1);

  cv::Mat in, out, a_out, b_out, c_out, d_out;

  bgra[0].convertTo(in, CV_32FC3, 1.0 / 255, 0.0);
  cv::filter2D(in, a_out, -1, filter1, cv::Point(-1, -1), 0.0,
               aznyan::mode_a[border]);

  cv::Mat tmpA;
  cv::multiply(in, in, tmpA);
  cv::filter2D(tmpA, b_out, -1, filter1, cv::Point(-1, -1), 0.0,
               aznyan::mode_a[border]);

  cv::Mat ev = calc_ev(a_out, b_out, beta);

  cv::Mat tmpB, tmp_ev;
  cv::merge(std::vector<cv::Mat>{ev, ev, ev}, tmp_ev);
  cv::multiply(a_out, tmp_ev, tmpB);

  cv::filter2D(tmpB, c_out, -1, filter2, cv::Point(-1, -1), 0.0,
               aznyan::mode_a[border]);
  cv::filter2D(tmp_ev, d_out, -1, filter2, cv::Point(-1, -1), 0.0,
               aznyan::mode_a[border]);

  cv::divide(c_out, d_out, out);
  cv::convertScaleAbs(out, out, 255.0);

  return aznyan::encode_nr(out, bgra[1]);
}
