#pragma once
#include "aznyan_types.h"
#include <tuple>

namespace aznyan {
uchar compute_final_alpha(const uchar fg, const uchar bg) {
  return static_cast<uchar>(fg + bg - (fg * bg) / 255);
}

uchar blend_screen(const uchar x1, const uchar x2) {
  return static_cast<uchar>(255 - ((255 - x1) * (255 - x2) / 255));
}

uchar blend_darken(const uchar x1, const uchar x2) { return std::min(x1, x2); }

uchar blend_lighten(const uchar x1, const uchar x2) { return std::max(x1, x2); }

uchar blend_multiply(const uchar x1, const uchar x2) { return (x1 * x2) / 255; }

inline uchar blend_color_burn(const uchar x1, const uchar x2) {
  if (x2 == 0) return x2;
  const auto rhs = 255 - std::min(255, ((255 - x1) * 255) / x2);
  return static_cast<uchar>(rhs);
}

uint32_t blend_pixels(const std::tuple<uchar, uchar, uchar, uchar>& background,
                      const std::tuple<uchar, uchar, uchar, uchar>& foreground,
                      const std::function<uint32_t(uchar, uchar)>& blend_func) {
  const uchar bg_alpha = std::get<3>(background);
  const uchar fg_alpha = std::get<3>(foreground);
  const uchar final_alpha = aznyan::compute_final_alpha(bg_alpha, fg_alpha);

  uchar bg_r, bg_g, bg_b;
  std::tie(bg_r, bg_g, bg_b, std::ignore) = background;
  uchar fg_r, fg_g, fg_b;
  std::tie(fg_r, fg_g, fg_b, std::ignore) = foreground;

  uchar final_rgb[3];
  final_rgb[0] = blend_func(bg_b, fg_b);
  final_rgb[1] = blend_func(bg_g, fg_g);
  final_rgb[2] = blend_func(bg_r, fg_r);

  return aznyan::pack_into_int(final_rgb[2], final_rgb[1], final_rgb[0],
                               final_alpha);
}
}  // namespace aznyan

[[cpp11::register]]
cpp11::integers azny_contrast(const cpp11::integers& nr, int height, int width,
                              double alpha, double beta) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out;
  cv::convertScaleAbs(bgra[0], out, alpha, beta);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_brighten_by_percent(const cpp11::integers& nr, int height,
                                         int width, double percent) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out;
  cv::addWeighted(bgra[0], percent, bgra[0], 1 - percent, 0, out);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_sepia(const cpp11::integers& nr, int height, int width) {
  return nr;
}

[[cpp11::register]]
cpp11::integers azny_fill_with_channels(const cpp11::integers& nr, int height,
                                        int width, int r, int g, int b, int a) {
  return nr;
}

[[cpp11::register]]
cpp11::integers azny_blend_over(const cpp11::integers& fg,
                                const cpp11::integers& bg) {
  if (fg.size() != bg.size()) {
    cpp11::stop("fg and bg must have the same length.");
  }
  std::vector<int> ret(fg.size());
  for (R_xlen_t i = 0; i < fg.size(); i++) {
    const auto fg_data = aznyan::int_to_rgba(fg[i]);
    const auto bg_data = aznyan::int_to_rgba(bg[i]);
    const uchar final_alpha =
        aznyan::compute_final_alpha(std::get<3>(bg_data), std::get<3>(fg_data));
    uchar final_rgb[3];
    for (int j = 0; j < 3; j++) {
      const float fg_c = std::get<3>(fg_data) / 255.0;
      const float bg_c = std::get<3>(bg_data) / 255.0;
      const float final_c = fg_c + bg_c * (1.0 - fg_c);
      final_rgb[j] = static_cast<uchar>(final_c * 255.0);
    }
    ret[i] = aznyan::pack_into_int(final_rgb[2], final_rgb[1], final_rgb[0],
                                   final_alpha);
  }
  return cpp11::as_sexp(ret);
}

[[cpp11::register]]
cpp11::integers azny_blend_screen(const cpp11::integers& fg,
                                  const cpp11::integers& bg) {
  if (fg.size() != bg.size()) {
    cpp11::stop("fg and bg must have the same length.");
  }
  std::vector<int> ret(fg.size());
  for (R_xlen_t i = 0; i < fg.size(); i++) {
    const auto fg_data = aznyan::int_to_rgba(fg[i]);
    const auto bg_data = aznyan::int_to_rgba(bg[i]);
    ret[i] = aznyan::blend_pixels(fg_data, bg_data, aznyan::blend_screen);
  }
}

[[cpp11::register]]
cpp11::integers azny_blend_soft_light(const cpp11::integers& fg,
                                      const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_overlay(const cpp11::integers& fg,
                                   const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_color_dodge(const cpp11::integers& fg,
                                       const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_darken(const cpp11::integers& fg,
                                  const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_lighten(const cpp11::integers& fg,
                                   const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_multiply(const cpp11::integers& fg,
                                    const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_color_burn(const cpp11::integers& fg,
                                      const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_linear_burn(const cpp11::integers& fg,
                                       const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_linear_dodge(const cpp11::integers& fg,
                                        const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_hard_light(const cpp11::integers& fg,
                                      const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_vivid_light(const cpp11::integers& fg,
                                       const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_linear_light(const cpp11::integers& fg,
                                        const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_pin_light(const cpp11::integers& fg,
                                     const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_difference(const cpp11::integers& fg,
                                      const cpp11::integers& bg) {
  return fg;
}

[[cpp11::register]]
cpp11::integers azny_blend_exclusion(const cpp11::integers& fg,
                                     const cpp11::integers& bg) {
  return fg;
}
