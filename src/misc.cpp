#include "aznyan_types.h"

// チャンネル入替 (ch_chg)
[[cpp11::register]]
cpp11::integers azny_swap_channels(const cpp11::integers& nr, int height,
                                   int width, const std::vector<int>& mapping) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  const size_t npairs = mapping.size() / 2;

  if (npairs != 4) {
    cpp11::stop("Invalid channel mapping. Must have 4 pairs.");
  }
  cv::mixChannels(&img, 1, bgra.data(), 2, mapping.data(), npairs);
  return aznyan::encode_nr(bgra[0], bgra[1]);
}

// リサイズ (resizefilter)
[[cpp11::register]]
cpp11::integers azny_resize(const cpp11::integers& nr, int height, int width,
                            cpp11::doubles wh, int resize_mode, bool set_size) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  cv::Mat out;
  if (set_size) {
    auto new_w = std::clamp(wh[0], 0.0, static_cast<double>(width));
    auto new_h = std::clamp(wh[1], 0.0, static_cast<double>(height));
    cv::resize(img, out, cv::Size(new_w, new_h), 0.0, 0.0,
               aznyan::rsmode[resize_mode]);
  } else {
    auto coef_w = wh[0];
    auto coef_h = wh[1];
    cv::resize(img, out, cv::Size(), coef_w, coef_h,
               aznyan::rsmode[resize_mode]);
  }
  auto [bgra_out, ch_out] = aznyan::split_bgra(out);
  return aznyan::encode_nr(bgra_out[0], bgra_out[1]);
}

// リサンプル (resample)
[[cpp11::register]]
cpp11::integers azny_resample(const cpp11::integers& nr, int height, int width,
                              cpp11::doubles wh, int resize_red,
                              int resize_exp) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat img;
  cv::merge(bgra, img);

  auto coef_w = wh[0];  // std::clamp(wh[0], 0.0, 1.0);
  auto coef_h = wh[1];  // std::clamp(wh[1], 0.0, 1.0);

  cv::Mat eximg, rdimg;
  cv::resize(img, rdimg, cv::Size(), coef_w, coef_h,
             aznyan::rsmode[resize_red]);

  auto cx = static_cast<double>(width) / rdimg.size().width;
  auto cy = static_cast<double>(height) / rdimg.size().height;
  cv::resize(rdimg, eximg, cv::Size(), cx, cy, aznyan::rsmode[resize_exp]);

  auto [bgra_out, ch_out] = aznyan::split_bgra(eximg);
  return aznyan::encode_nr(bgra_out[0], bgra_out[1]);
}
