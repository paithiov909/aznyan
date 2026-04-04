#include "aznyan_types.h"

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
cpp11::integers azny_warp_perspective(const cpp11::integers& nr, int height,
                                      int width,
                                      const cpp11::doubles_matrix<>& mat,
                                      int border) {
  if (mat.nrow() != 3 || mat.ncol() != 3) {
    cpp11::stop("mat must have 3 rows and 3 columns");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat m(3, 3, CV_32F);
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      m.at<float>(i, j) = static_cast<float>(mat(i, j));
    }
  }
  cv::Mat out;
  cv::warpPerspective(bgra[0], out, m, cv::Size(width, height),
                      cv::INTER_LINEAR, aznyan::mode_b[border]);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_swap_channels(const cpp11::integers& nr, int height,
                                   int width, const std::vector<int>& mapping) {
  const size_t npairs = mapping.size() / 2;
  if (npairs != 4) {
    cpp11::stop("Invalid channel mapping. Must have 4 pairs.");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  cv::mixChannels(&img, 1, bgra.data(), 2, mapping.data(), npairs);
  return aznyan::encode_nr(bgra[0], bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_resize(const cpp11::integers& nr, int height, int width,
                            const cpp11::doubles& wh, int resize_mode,
                            bool set_size) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  cv::Mat out;
  if (set_size) {
    const auto new_w = std::clamp(wh[0], 0.0, static_cast<double>(width));
    const auto new_h = std::clamp(wh[1], 0.0, static_cast<double>(height));
    cv::resize(img, out, cv::Size(new_w, new_h), 0.0, 0.0,
               aznyan::rsmode[resize_mode]);
  } else {
    const auto coef_w = wh[0];
    const auto coef_h = wh[1];
    cv::resize(img, out, cv::Size(), coef_w, coef_h,
               aznyan::rsmode[resize_mode]);
  }
  auto [bgra_out, ch_out] = aznyan::split_bgra(out);
  return aznyan::encode_nr(bgra_out[0], bgra_out[1]);
}

[[cpp11::register]]
cpp11::integers azny_resample(const cpp11::integers& nr, int height, int width,
                              cpp11::doubles wh, int resize_red,
                              int resize_exp) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  const auto coef_w = wh[0];
  const auto coef_h = wh[1];

  cv::Mat eximg, rdimg;
  cv::resize(img, rdimg, cv::Size(), coef_w, coef_h,
             aznyan::rsmode[resize_red]);

  const auto cx = static_cast<double>(width) / rdimg.size().width;
  const auto cy = static_cast<double>(height) / rdimg.size().height;
  cv::resize(rdimg, eximg, cv::Size(), cx, cy, aznyan::rsmode[resize_exp]);

  const auto [bgra_out, ch_out] = aznyan::split_bgra(eximg);
  return aznyan::encode_nr(bgra_out[0], bgra_out[1]);
}
