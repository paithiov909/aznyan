#include "aznyan_types.h"

[[cpp11::register]]
cpp11::doubles azny_saturate_value(const cpp11::doubles& in_vec, double val) {
  std::vector<double> ret;
  for (const auto& c : in_vec) {
    ret.push_back(val >= 0.0 ? c + val * (1.0 - c) * c : c + val * c);
  }
  return cpp11::as_sexp(ret);
}

// Takes doubles of RGBA values and packs them into 'native packed' integers
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
  aznyan::parallel_for(0, rgb.ncol(), [&](int i) {
    ret[i] = aznyan::pack_into_int(
        static_cast<uchar>(rgb(0, i)), static_cast<uchar>(rgb(1, i)),
        static_cast<uchar>(rgb(2, i)), static_cast<uchar>(a[i]));
  });
  cpp11::writable::integers out = cpp11::as_sexp(ret);
  out.attr("dim") = cpp11::as_sexp({height, width});
  return out;
}

// Takes packed RGBA color values and unpacks them
[[cpp11::register]]
cpp11::integers azny_unpack_integers(const cpp11::integers& nr) {
  std::vector<uchar> ret(nr.size() * 4);
  aznyan::parallel_for(0, nr.size(), [&](int i) {
    const auto [r, g, b, a] = aznyan::int_to_rgba(nr[i]);
    ret[i * 4 + 0] = r;
    ret[i * 4 + 1] = g;
    ret[i * 4 + 2] = b;
    ret[i * 4 + 3] = a;
  });
  cpp11::writable::integers out = cpp11::as_sexp(ret);
  out.attr("dim") = cpp11::as_sexp({4, (int)nr.size()});
  return out;
}

[[cpp11::register]]
cpp11::integers azny_rgb_to_hls(const cpp11::doubles_matrix<>& rgb) {
  if (rgb.nrow() != 3) {
    cpp11::stop("RGB must have 3 rows.");
  }
  cv::Mat tmp(1, rgb.ncol(), CV_8UC3);
  aznyan::parallel_for(0, rgb.ncol(), [&](int i) {
    tmp.at<cv::Vec3b>(0, i) =
        cv::Vec3b(static_cast<uchar>(rgb(0, i)), static_cast<uchar>(rgb(1, i)),
                  static_cast<uchar>(rgb(2, i)));
  });
  cv::cvtColor(tmp, tmp, cv::COLOR_RGB2HLS);

  std::vector<uchar> ret(3 * rgb.ncol());
  aznyan::parallel_for(0, rgb.ncol(), [&](int i) {
    const cv::Vec3b& hls = tmp.at<cv::Vec3b>(0, i);
    ret[i * 3 + 0] = hls[0];
    ret[i * 3 + 1] = hls[1];
    ret[i * 3 + 2] = hls[2];
  });
  cpp11::writable::integers out = cpp11::as_sexp(ret);
  out.attr("dim") = cpp11::as_sexp({3, rgb.ncol()});
  return out;
}

[[cpp11::register]]
cpp11::integers azny_hls_to_rgb(const cpp11::doubles_matrix<>& hls) {
  if (hls.nrow() != 3) {
    cpp11::stop("HLS must have 3 rows.");
  }
  cv::Mat tmp(1, hls.ncol(), CV_8UC3);
  aznyan::parallel_for(0, hls.ncol(), [&](int i) {
    tmp.at<cv::Vec3b>(0, i) =
        cv::Vec3b(static_cast<uchar>(hls(0, i)), static_cast<uchar>(hls(1, i)),
                  static_cast<uchar>(hls(2, i)));
  });
  cv::cvtColor(tmp, tmp, cv::COLOR_HLS2RGB);

  std::vector<uchar> ret(3 * hls.ncol());
  aznyan::parallel_for(0, hls.ncol(), [&](int i) {
    const cv::Vec3b& rgb = tmp.at<cv::Vec3b>(0, i);
    ret[i * 3 + 0] = rgb[0];
    ret[i * 3 + 1] = rgb[1];
    ret[i * 3 + 2] = rgb[2];
  });
  cpp11::writable::integers out = cpp11::as_sexp(ret);
  out.attr("dim") = cpp11::as_sexp({3, hls.ncol()});
  return out;
}

[[cpp11::register]]
cpp11::integers azny_color_map(const cpp11::integers& nr, int height, int width,
                               int mode, bool hsvmode, bool invmode) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat tmpB;
  if (hsvmode) {
    cv::Mat tmp;
    std::vector<cv::Mat> hsv_ch;
    cv::cvtColor(bgra[0], tmp, cv::COLOR_BGR2HSV_FULL);
    cv::split(tmp, hsv_ch);
    hsv_ch[0].convertTo(tmpB, CV_8UC1);
  } else {
    cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY, 1);
  }
  if (invmode) {
    cv::Mat tmp1 = cv::Mat::ones(tmpB.size(), CV_8UC1) * 255.0f;
    cv::Mat tmp2 = cv::Mat::zeros(tmpB.size(), CV_8UC1);
    cv::subtract(tmp1, tmpB, tmp2);
    tmpB = tmp2.clone();
  }
  cv::applyColorMap(tmpB, tmpB, aznyan::cmmode[mode]);

  return aznyan::encode_nr(tmpB, bgra[1]);
}
