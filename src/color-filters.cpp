#include "aznyan_types.h"

namespace {

inline uchar to_uchar(float v) {
  return static_cast<uchar>(std::min(std::max(v, 0.0f), 255.0f));
}

inline cpp11::integers solid_premul(int width, int height, int r, int g, int b,
                                    int a) {
  const float alpha = a / 255.0f;
  const uchar pr = to_uchar(r * alpha);
  const uchar pg = to_uchar(g * alpha);
  const uchar pb = to_uchar(b * alpha);
  cv::Mat bgr(height, width, CV_8UC3, cv::Scalar(pb, pg, pr));
  cv::Mat alpha_mat(height, width, CV_8UC1, cv::Scalar(a));
  return aznyan::encode_nr(bgr, alpha_mat);
}

}  // namespace

cpp11::integers azny_brighten(const cpp11::integers& nr, int height, int width,
                              double intensity);
cpp11::integers azny_contrast(const cpp11::integers& nr, int height, int width,
                              double intensity);
cpp11::integers azny_saturate(const cpp11::integers& nr, int height, int width,
                              double intensity);
cpp11::integers azny_sepia(const cpp11::integers& nr, int height, int width,
                           double intensity, int depth);
cpp11::integers azny_hue_rotate(const cpp11::integers& nr, int height, int width,
                                double rad);
cpp11::integers azny_grayscale(const cpp11::integers& nr, int height, int width);
cpp11::integers azny_reset_alpha(const cpp11::integers& nr, int height, int width,
                                 double alpha);

cpp11::integers azny_blend_screen(const cpp11::integers& src,
                                  const cpp11::integers& dst, int height,
                                  int width);
cpp11::integers azny_blend_lighten(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width);
cpp11::integers azny_blend_overlay(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width);
cpp11::integers azny_blend_softlight(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width);
cpp11::integers azny_blend_multiply(const cpp11::integers& src,
                                    const cpp11::integers& dst, int height,
                                    int width);
cpp11::integers azny_blend_colordodge(const cpp11::integers& src,
                                      const cpp11::integers& dst, int height,
                                      int width);
cpp11::integers azny_blend_darken(const cpp11::integers& src,
                                  const cpp11::integers& dst, int height,
                                  int width);
cpp11::integers azny_blend_exclusion(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width);
cpp11::integers azny_blend_over(const cpp11::integers& src,
                                const cpp11::integers& dst, int height,
                                int width);

[[cpp11::register]]
cpp11::integers azny_color_filter(const cpp11::integers& nr, int height,
                                  int width, int filter_id) {
  switch (filter_id) {
    case 0: {  // 1977
      auto bg = azny_contrast(nr, height, width, 0.1f);
      bg = azny_brighten(bg, height, width, 0.1f);
      bg = azny_saturate(bg, height, width, 0.3);
      auto fg = solid_premul(width, height, 243, 106, 188, 76);
      return azny_blend_screen(bg, fg, height, width);
    }
    case 1: {  // aden
      auto out = azny_hue_rotate(nr, height, width, -0.3490659);
      out = azny_contrast(out, height, width, -0.1f);
      out = azny_saturate(out, height, width, -0.2);
      out = azny_brighten(out, height, width, 0.2f);
      return azny_reset_alpha(out, height, width, 1.0);
    }
    case 2: {  // brannan
      auto bg = azny_sepia(nr, height, width, 0.2, 20);
      bg = azny_contrast(bg, height, width, 0.2f);
      auto fg = solid_premul(width, height, 161, 44, 199, 59);
      return azny_blend_lighten(fg, bg, height, width);
    }
    case 3: {  // brooklyn
      auto bg = azny_contrast(nr, height, width, -0.1f);
      bg = azny_brighten(bg, height, width, 0.1f);
      bg = azny_reset_alpha(bg, height, width, 1.0);
      auto fg = solid_premul(width, height, 168, 223, 193, 150);
      return azny_blend_overlay(fg, bg, height, width);
    }
    case 4: {  // clarendon
      auto bg = azny_contrast(nr, height, width, 0.2f);
      bg = azny_saturate(bg, height, width, 0.35);
      auto fg = solid_premul(width, height, 127, 187, 227, 101);
      return azny_blend_overlay(fg, bg, height, width);
    }
    case 5: {  // earlybird
      auto bg = azny_contrast(nr, height, width, -0.1f);
      bg = azny_sepia(bg, height, width, 0.05, 20);
      auto fg = solid_premul(width, height, 208, 186, 142, 150);
      auto out = azny_blend_overlay(bg, fg, height, width);
      return azny_reset_alpha(out, height, width, 1.0);
    }
    case 6: {  // gingham
      auto bg = azny_brighten(nr, height, width, 0.05f);
      bg = azny_hue_rotate(bg, height, width, -0.1745329);
      auto fg = solid_premul(width, height, 230, 230, 230, 255);
      return azny_blend_softlight(fg, bg, height, width);
    }
    case 7: {  // hudson
      auto bg = azny_brighten(nr, height, width, 0.5f);
      bg = azny_contrast(bg, height, width, -0.1f);
      bg = azny_saturate(bg, height, width, 0.1);
      auto fg = solid_premul(width, height, 166, 177, 255, 208);
      auto out = azny_blend_multiply(fg, bg, height, width);
      return azny_reset_alpha(out, height, width, 1.0);
    }
    case 8: {  // inkwell
      auto out = azny_sepia(nr, height, width, 0.3, 20);
      out = azny_contrast(out, height, width, 0.1f);
      out = azny_brighten(out, height, width, 0.1f);
      return azny_grayscale(out, height, width);
    }
    case 9: {  // kelvin
      auto bg = azny_blend_colordodge(
          nr, solid_premul(width, height, 56, 44, 52, 255), height, width);
      auto fg = solid_premul(width, height, 183, 125, 33, 255);
      return azny_blend_overlay(fg, bg, height, width);
    }
    case 10: {  // lark
      auto bg = azny_contrast(nr, height, width, -0.1f);
      bg = azny_blend_colordodge(
          solid_premul(width, height, 34, 37, 63, 255), bg, height, width);
      auto fg = solid_premul(width, height, 242, 242, 242, 204);
      return azny_blend_darken(fg, bg, height, width);
    }
    case 11: {  // lofi
      auto out = azny_saturate(nr, height, width, 0.1);
      return azny_contrast(out, height, width, 0.5f);
    }
    case 12: {  // maven
      auto out = azny_sepia(nr, height, width, 0.25, 20);
      out = azny_brighten(out, height, width, -0.005f);
      out = azny_contrast(out, height, width, -0.005f);
      return azny_saturate(out, height, width, 0.5);
    }
    case 13: {  // mayfair
      auto bg = azny_contrast(nr, height, width, 0.1f);
      bg = azny_saturate(bg, height, width, 0.1);
      auto fg = solid_premul(width, height, 255, 200, 200, 153);
      return azny_blend_overlay(fg, bg, height, width);
    }
    case 14: {  // moon
      auto bg = azny_contrast(nr, height, width, 0.1f);
      bg = azny_brighten(bg, height, width, 0.1f);
      bg = azny_blend_softlight(
          solid_premul(width, height, 160, 160, 160, 255), bg, height, width);
      auto fg = solid_premul(width, height, 56, 56, 56, 255);
      auto out = azny_blend_lighten(fg, bg, height, width);
      return azny_grayscale(out, height, width);
    }
    case 15: {  // nashville
      auto bg = azny_sepia(nr, height, width, 0.02, 20);
      bg = azny_contrast(bg, height, width, 0.2f);
      bg = azny_brighten(bg, height, width, 0.05f);
      bg = azny_saturate(bg, height, width, 0.2);
      bg = azny_blend_darken(
          solid_premul(width, height, 247, 176, 153, 243), bg, height, width);
      auto fg = solid_premul(width, height, 0, 70, 150, 230);
      return azny_blend_lighten(fg, bg, height, width);
    }
    case 16: {  // reyes
      auto bg = azny_sepia(nr, height, width, 0.22, 20);
      bg = azny_brighten(bg, height, width, 0.1f);
      bg = azny_contrast(bg, height, width, -0.15f);
      bg = azny_saturate(bg, height, width, -0.25);
      auto fg = solid_premul(width, height, 239, 205, 173, 10);
      return azny_blend_over(fg, bg, height, width);
    }
    case 17: {  // rise
      auto bg = azny_brighten(nr, height, width, 0.05f);
      bg = azny_sepia(bg, height, width, 0.05, 20);
      bg = azny_contrast(bg, height, width, -0.1f);
      bg = azny_saturate(bg, height, width, -0.1);
      auto fg = solid_premul(width, height, 236, 205, 169, 240);
      bg = azny_blend_multiply(fg, bg, height, width);
      fg = solid_premul(width, height, 232, 197, 152, 10);
      fg = azny_blend_overlay(fg, bg, height, width);
      return azny_blend_over(fg, nr, height, width);
    }
    case 18: {  // slumber
      auto bg = azny_saturate(nr, height, width, -0.34);
      bg = azny_brighten(bg, height, width, -0.05f);
      auto fg = solid_premul(width, height, 69, 41, 12, 102);
      bg = azny_blend_lighten(fg, bg, height, width);
      fg = solid_premul(width, height, 125, 105, 24, 128);
      return azny_blend_softlight(fg, bg, height, width);
    }
    case 19: {  // stinson
      auto bg = azny_contrast(nr, height, width, -0.25f);
      bg = azny_saturate(bg, height, width, -0.15);
      bg = azny_brighten(bg, height, width, 0.15f);
      auto fg = solid_premul(width, height, 240, 149, 128, 51);
      return azny_blend_softlight(fg, bg, height, width);
    }
    case 20: {  // toaster
      auto bg = azny_contrast(nr, height, width, 0.2f);
      bg = azny_brighten(bg, height, width, -0.1f);
      auto fg = solid_premul(width, height, 128, 78, 15, 140);
      return azny_blend_screen(fg, bg, height, width);
    }
    case 21: {  // valencia
      auto bg = azny_contrast(nr, height, width, 0.08f);
      bg = azny_brighten(bg, height, width, 0.08f);
      bg = azny_sepia(bg, height, width, 0.08, 20);
      auto fg = solid_premul(width, height, 58, 3, 57, 128);
      return azny_blend_exclusion(fg, bg, height, width);
    }
    case 22: {  // walden
      auto bg = azny_brighten(nr, height, width, 0.1f);
      bg = azny_hue_rotate(bg, height, width, -0.1745329);
      bg = azny_saturate(bg, height, width, 0.6);
      bg = azny_sepia(bg, height, width, 0.05, 20);
      auto fg = solid_premul(width, height, 0, 88, 244, 77);
      return azny_blend_screen(fg, bg, height, width);
    }
    default:
      return nr;
  }
}
