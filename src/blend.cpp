#include "aznyan_types.h"

namespace {

inline float clamp01(float v) {
  return std::min(std::max(v, 0.0f), 1.0f);
}

inline float alpha_blend(float x1, float x2) {
  return clamp01(x1 + x2 * (1.0f - x1));
}

inline cv::Vec3f gray_value(const cv::Vec3b& v) {
  return cv::Vec3f((v[2] * 0.299f) / 255.0f, (v[1] * 0.587f) / 255.0f,
                   (v[0] * 0.114f) / 255.0f);
}

inline uchar to_uchar(float v) {
  return static_cast<uchar>(std::min(std::max(v, 0.0f), 255.0f));
}

}  // namespace

[[cpp11::register]]
cpp11::integers azny_blend_over(const cpp11::integers& src,
                                const cpp11::integers& dst, int height,
                                int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float out_r = alpha_blend(sr, dr) * 255.0f;
      const float out_g = alpha_blend(sg, dg) * 255.0f;
      const float out_b = alpha_blend(sb, db) * 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(out_b), to_uchar(out_g), to_uchar(out_r));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_darken(const cpp11::integers& src,
                                  const cpp11::integers& dst, int height,
                                  int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      out.at<cv::Vec3b>(i, j) = cv::Vec3b(std::min(s[0], d[0]),
                                          std::min(s[1], d[1]),
                                          std::min(s[2], d[2]));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_multiply(const cpp11::integers& src,
                                    const cpp11::integers& dst, int height,
                                    int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(sb * db * 255.0f),
                    to_uchar(sg * dg * 255.0f),
                    to_uchar(sr * dr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_colorburn(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(1.0f - (1.0f - dr) / std::max(sr, 1e-6f));
      const float rg = clamp01(1.0f - (1.0f - dg) / std::max(sg, 1e-6f));
      const float rb = clamp01(1.0f - (1.0f - db) / std::max(sb, 1e-6f));
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_lighten(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      out.at<cv::Vec3b>(i, j) = cv::Vec3b(std::max(s[0], d[0]),
                                          std::max(s[1], d[1]),
                                          std::max(s[2], d[2]));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_screen(const cpp11::integers& src,
                                  const cpp11::integers& dst, int height,
                                  int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(1.0f - (1.0f - dr) * (1.0f - sr));
      const float rg = clamp01(1.0f - (1.0f - dg) * (1.0f - sg));
      const float rb = clamp01(1.0f - (1.0f - db) * (1.0f - sb));
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_add(const cpp11::integers& src,
                               const cpp11::integers& dst, int height,
                               int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(sb + db) * 255.0f),
                    to_uchar(clamp01(sg + dg) * 255.0f),
                    to_uchar(clamp01(sr + dr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_colordodge(const cpp11::integers& src,
                                      const cpp11::integers& dst, int height,
                                      int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(dr / std::max(1.0f - sr, 1e-6f));
      const float rg = clamp01(dg / std::max(1.0f - sg, 1e-6f));
      const float rb = clamp01(db / std::max(1.0f - sb, 1e-6f));
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_hardlight(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = sr < 0.5f ? 2.0f * sr * dr
                                 : 1.0f - 2.0f * (1.0f - sr) * (1.0f - dr);
      const float rg = sg < 0.5f ? 2.0f * sg * dg
                                 : 1.0f - 2.0f * (1.0f - sg) * (1.0f - dg);
      const float rb = sb < 0.5f ? 2.0f * sb * db
                                 : 1.0f - 2.0f * (1.0f - sb) * (1.0f - db);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(rb) * 255.0f),
                    to_uchar(clamp01(rg) * 255.0f),
                    to_uchar(clamp01(rr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_softlight(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = sr < 0.5f
                           ? (1.0f - 2.0f * sr) * (dr * dr) + 2.0f * dr * sr
                           : 2.0f * dr * (1.0f - sr) +
                                 std::sqrt(dr) * (2.0f * sr - 1.0f);
      const float rg = sg < 0.5f
                           ? (1.0f - 2.0f * sg) * (dg * dg) + 2.0f * dg * sg
                           : 2.0f * dg * (1.0f - sg) +
                                 std::sqrt(dg) * (2.0f * sg - 1.0f);
      const float rb = sb < 0.5f
                           ? (1.0f - 2.0f * sb) * (db * db) + 2.0f * db * sb
                           : 2.0f * db * (1.0f - sb) +
                                 std::sqrt(db) * (2.0f * sb - 1.0f);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(rb) * 255.0f),
                    to_uchar(clamp01(rg) * 255.0f),
                    to_uchar(clamp01(rr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_overlay(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = dr < 0.5f ? 2.0f * sr * dr
                                 : 1.0f - 2.0f * (1.0f - sr) * (1.0f - dr);
      const float rg = dg < 0.5f ? 2.0f * sg * dg
                                 : 1.0f - 2.0f * (1.0f - sg) * (1.0f - dg);
      const float rb = db < 0.5f ? 2.0f * sb * db
                                 : 1.0f - 2.0f * (1.0f - sb) * (1.0f - db);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(rb) * 255.0f),
                    to_uchar(clamp01(rg) * 255.0f),
                    to_uchar(clamp01(rr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_hardmix(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(sb <= (1.0f - db) ? 0 : 255,
                    sg <= (1.0f - dg) ? 0 : 255,
                    sr <= (1.0f - dr) ? 0 : 255);

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_linearlight(const cpp11::integers& src,
                                       const cpp11::integers& dst, int height,
                                       int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(db + 2.0f * sb - 1.0f) * 255.0f),
                    to_uchar(clamp01(dg + 2.0f * sg - 1.0f) * 255.0f),
                    to_uchar(clamp01(dr + 2.0f * sr - 1.0f) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_vividlight(const cpp11::integers& src,
                                      const cpp11::integers& dst, int height,
                                      int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr =
          sr < 0.5f ? 1.0f - (1.0f - dr) / std::max(2.0f * sr, 1e-6f)
                    : dr / std::max(2.0f * (1.0f - sr), 1e-6f);
      const float rg =
          sg < 0.5f ? 1.0f - (1.0f - dg) / std::max(2.0f * sg, 1e-6f)
                    : dg / std::max(2.0f * (1.0f - sg), 1e-6f);
      const float rb =
          sb < 0.5f ? 1.0f - (1.0f - db) / std::max(2.0f * sb, 1e-6f)
                    : db / std::max(2.0f * (1.0f - sb), 1e-6f);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(rb) * 255.0f),
                    to_uchar(clamp01(rg) * 255.0f),
                    to_uchar(clamp01(rr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_pinlight(const cpp11::integers& src,
                                    const cpp11::integers& dst, int height,
                                    int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;

      const float rr =
          dr < 0.5f ? std::min(sr, 2.0f * dr) : std::max(sr, 2.0f * (dr - 0.5f));
      const float rg =
          dg < 0.5f ? std::min(sg, 2.0f * dg) : std::max(sg, 2.0f * (dg - 0.5f));
      const float rb =
          db < 0.5f ? std::min(sb, 2.0f * db) : std::max(sb, 2.0f * (db - 0.5f));

      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(clamp01(rb) * 255.0f),
                    to_uchar(clamp01(rg) * 255.0f),
                    to_uchar(clamp01(rr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_average(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(((sb + db) / 2.0f) * 255.0f),
                    to_uchar(((sg + dg) / 2.0f) * 255.0f),
                    to_uchar(((sr + dr) / 2.0f) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_exclusion(const cpp11::integers& src,
                                     const cpp11::integers& dst, int height,
                                     int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = sr + dr - 2.0f * sr * dr;
      const float rg = sg + dg - 2.0f * sg * dg;
      const float rb = sb + db - 2.0f * sb * db;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_difference(const cpp11::integers& src,
                                      const cpp11::integers& dst, int height,
                                      int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(std::abs(db - sb) * 255.0f),
                    to_uchar(std::abs(dg - sg) * 255.0f),
                    to_uchar(std::abs(dr - sr) * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_divide(const cpp11::integers& src,
                                  const cpp11::integers& dst, int height,
                                  int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(dr / std::max(sr, 1e-6f));
      const float rg = clamp01(dg / std::max(sg, 1e-6f));
      const float rb = clamp01(db / std::max(sb, 1e-6f));
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_subtract(const cpp11::integers& src,
                                    const cpp11::integers& dst, int height,
                                    int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(dr - sr);
      const float rg = clamp01(dg - sg);
      const float rb = clamp01(db - sb);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_luminosity(const cpp11::integers& src,
                                      const cpp11::integers& dst, int height,
                                      int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const cv::Vec3f gs = gray_value(s);
      const cv::Vec3f gd = gray_value(d);
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float rr = clamp01(gs[0] + dr - gd[0]);
      const float rg = clamp01(gs[1] + dg - gd[1]);
      const float rb = clamp01(gs[2] + db - gd[2]);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}

[[cpp11::register]]
cpp11::integers azny_blend_ghosting(const cpp11::integers& src,
                                    const cpp11::integers& dst, int height,
                                    int width) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  cv::Mat out(height, width, CV_8UC3);
  cv::Mat out_a(height, width, CV_8UC1);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto s = src_bgra[0].at<cv::Vec3b>(i, j);
      const auto d = dst_bgra[0].at<cv::Vec3b>(i, j);
      const cv::Vec3f gs = gray_value(s);
      const cv::Vec3f gd = gray_value(d);
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float rr = clamp01(gd[0] - gs[0] + dr + sr / 5.0f);
      const float rg = clamp01(gd[1] - gs[1] + dg + sg / 5.0f);
      const float rb = clamp01(gd[2] - gs[2] + db + sb / 5.0f);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(rb * 255.0f), to_uchar(rg * 255.0f),
                    to_uchar(rr * 255.0f));

      const float sa = src_bgra[1].at<uchar>(i, j) / 255.0f;
      const float da = dst_bgra[1].at<uchar>(i, j) / 255.0f;
      out_a.at<uchar>(i, j) = to_uchar(alpha_blend(sa, da) * 255.0f);
    }
  });

  return aznyan::encode_nr(out, out_a);
}
