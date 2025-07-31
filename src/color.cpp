#include "aznyan_types.h"

namespace aznyan {

const float GANNMA = 2.4f;

cv::Mat sRGB_to_linear(const cv::Mat& img) {
  cv::Mat out(img.size(), CV_32FC3);
  for (int i = 0; i < img.rows; i++) {
    for (int j = 0; j < img.cols; j++) {
      cv::Vec3f v = img.at<cv::Vec3f>(i, j);
      for (int c = 0; c < 3; ++c) {
        float s = v[c];
        out.at<cv::Vec3f>(i, j)[c] =
            (s <= 0.04045f) ? s / 12.92f
                            : std::pow((s + 0.055f) / 1.055f, GANNMA);
      }
    }
  }
  return out;
}

cv::Mat linear_to_sRGB(const cv::Mat& img) {
  cv::Mat out(img.size(), CV_32FC3);
  for (int i = 0; i < img.rows; i++) {
    for (int j = 0; j < img.cols; j++) {
      cv::Vec3f v = img.at<cv::Vec3f>(i, j);
      for (int c = 0; c < 3; ++c) {
        float s = v[c];
        out.at<cv::Vec3f>(i, j)[c] =
            (s <= 0.0031308f) ? s * 12.92f
                              : 1.055f * std::pow(s, 1.0f / GANNMA) - 0.055f;
      }
    }
  }
  return out;
}

}  // namespace aznyan

[[cpp11::register]]
cpp11::doubles azny_decode_rec709(const std::vector<double>& in_vec) {
  std::vector<double> ret;
  for (const auto& c : in_vec) {
    ret.push_back((c < 0.081) ? (c / 4.5f)
                              : std::pow((c + 0.099f) / 1.099f, 1.0f / 0.45f));
  }
  return cpp11::as_sexp(ret);
}

[[cpp11::register]]
cpp11::doubles azny_encode_rec709(const std::vector<double>& in_vec) {
  std::vector<double> ret;
  for (const auto& c : in_vec) {
    ret.push_back((c < 0.018) ? (c * 4.5f)
                              : 1.099f * std::pow(c, 0.45f) - 0.099f);
  }
  return cpp11::as_sexp(ret);
}

// Takes a matrix of RGBA values and packs them into 'native packed' integers
[[cpp11::register]]
cpp11::integers azny_pack_integers(const cpp11::doubles_matrix<>& rgb,
                                   const cpp11::doubles& a, int height,
                                   int width) {
  if (rgb.nrow() != 3) {
    cpp11::stop("RGB must have 3 rows.");
  }
  if (rgb.ncol() != a.size()) {
    cpp11::stop("RGB and alpha must have the same length.");
  }
  std::vector<uint32_t> ret(rgb.ncol());
  for (R_xlen_t i = 0; i < rgb.ncol(); i++) {
    ret[i] = aznyan::pack_into_int(
        static_cast<uchar>(rgb(0, i)), static_cast<uchar>(rgb(1, i)),
        static_cast<uchar>(rgb(2, i)), static_cast<uchar>(a[i]));
  }
  cpp11::writable::integers out = cpp11::as_sexp(ret);
  out.attr("dim") = cpp11::as_sexp({height, width});
  return out;
}
