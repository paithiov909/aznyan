#include "aznyan_types.h"

namespace {

inline float clampf(float v, float lo, float hi) {
  return std::min(std::max(v, lo), hi);
}

// FIXME: Use luma as a scalar value.
inline float gray_channel(float v, float weight) {
  return (v * weight) / 255.0f;
}

inline float saturate_value(float c, float val) {
  return val >= 0.0f ? c + val * (1.0f - c) * c : c + val * c;
}

inline uchar to_uchar(float v) {
  return static_cast<uchar>(clampf(v, 0.0f, 255.0f));
}

}  // namespace

[[cpp11::register]]
cpp11::integers azny_brighten(const cpp11::integers& nr, int height, int width,
                              double intensity) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat tmp;
  cv::convertScaleAbs(bgra[0], tmp, 1.0 + intensity);
  return aznyan::encode_nr(tmp, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_contrast(const cpp11::integers& nr, int height, int width,
                              double intensity) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat tmp;
  bgra[0].convertTo(tmp, CV_32F, 1.0 / 255.0);
  cv::subtract(tmp, 0.5, tmp);
  cv::multiply(tmp, 1 + intensity, tmp);
  cv::add(tmp, 0.5, tmp);
  tmp.convertTo(tmp, CV_8U, 255.0);
  return aznyan::encode_nr(tmp, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_duotone(const cpp11::integers& nr, int height, int width,
                             const cpp11::integers& color_a,
                             const cpp11::integers& color_b, double gamma) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float inv_gamma = gamma == 0.0 ? 1.0f : static_cast<float>(1.0 / gamma);
  const float ar = color_a[0];
  const float ag = color_a[1];
  const float ab = color_a[2];
  const float br = color_b[0];
  const float bg = color_b[1];
  const float bb = color_b[2];

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = v[2];
      const float g = v[1];
      const float b = v[0];
      const float lr =
          clampf(std::pow(gray_channel(r, 0.299f), inv_gamma), 0.0f, 1.0f);
      const float lg =
          clampf(std::pow(gray_channel(g, 0.587f), inv_gamma), 0.0f, 1.0f);
      const float lb =
          clampf(std::pow(gray_channel(b, 0.114f), inv_gamma), 0.0f, 1.0f);
      const float out_r = ar * lr + br * (1.0f - lr);
      const float out_g = ag * lg + bg * (1.0f - lg);
      const float out_b = ab * lb + bb * (1.0f - lb);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(out_b), to_uchar(out_g), to_uchar(out_r));
    }
  });

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_grayscale(const cpp11::integers& nr, int height,
                               int width) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float avg = (v[0] + v[1] + v[2]) / 3.0f;
      const uchar u = to_uchar(avg);
      out.at<cv::Vec3b>(i, j) = cv::Vec3b(u, u, u);
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_hue_rotate(const cpp11::integers& nr, int height,
                                int width, double rad) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float cosv = std::cos(rad);
  const float sinv = std::sin(rad);
  const float m[9] = {
      0.213f + cosv * 0.787f - sinv * 0.213f,
      0.715f - cosv * 0.715f - sinv * 0.715f,
      0.072f - cosv * 0.072f + sinv * 0.928f,
      0.213f - cosv * 0.213f + sinv * 0.143f,
      0.715f + cosv * 0.285f + sinv * 0.140f,
      0.072f - cosv * 0.072f - sinv * 0.283f,
      0.213f - cosv * 0.213f - sinv * 0.787f,
      0.715f - cosv * 0.715f + sinv * 0.715f,
      0.072f + cosv * 0.928f + sinv * 0.072f,
  };

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = v[2];
      const float g = v[1];
      const float b = v[0];
      const float nr = m[0] * r + m[1] * g + m[2] * b;
      const float ng = m[3] * r + m[4] * g + m[5] * b;
      const float nb = m[6] * r + m[7] * g + m[8] * b;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(nb), to_uchar(ng), to_uchar(nr));
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_invert(const cpp11::integers& nr, int height, int width) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      out.at<cv::Vec3b>(i, j) = cv::Vec3b(255 - v[0], 255 - v[1], 255 - v[2]);
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_linocut(const cpp11::integers& nr, int height, int width,
                             const cpp11::integers& ink,
                             const cpp11::integers& paper, double threshold) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float ir = ink[0];
  const float ig = ink[1];
  const float ib = ink[2];
  const float pr = paper[0];
  const float pg = paper[1];
  const float pb = paper[2];

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = v[2];
      const float g = v[1];
      const float b = v[0];
      const float lr = gray_channel(r, 0.299f) > threshold ? 1.0f : 0.0f;
      const float lg = gray_channel(g, 0.587f) > threshold ? 1.0f : 0.0f;
      const float lb = gray_channel(b, 0.114f) > threshold ? 1.0f : 0.0f;
      const float out_r = pr * lr + ir * (1.0f - lr);
      const float out_g = pg * lg + ig * (1.0f - lg);
      const float out_b = pb * lb + ib * (1.0f - lb);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(out_b), to_uchar(out_g), to_uchar(out_r));
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_posterize(const cpp11::integers& nr, int height, int width,
                               int shades) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const int denom = std::max(shades - 1, 1);
  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = std::floor((v[2] / 255.0f) * shades) / denom * 255.0f;
      const float g = std::floor((v[1] / 255.0f) * shades) / denom * 255.0f;
      const float b = std::floor((v[0] / 255.0f) * shades) / denom * 255.0f;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(b), to_uchar(g), to_uchar(r));
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_reset_alpha(const cpp11::integers& nr, int height,
                                 int width, double alpha) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  const uchar a = to_uchar(static_cast<float>(alpha * 255.0));
  bgra[1].setTo(a);
  return aznyan::encode_nr(bgra[0], bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_saturate(const cpp11::integers& nr, int height, int width,
                              double intensity) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat rgb;
  cv::cvtColor(bgra[0], rgb, cv::COLOR_BGR2RGB);
  cv::Mat hls;
  cv::cvtColor(rgb, hls, cv::COLOR_RGB2HLS);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      auto v = hls.at<cv::Vec3b>(i, j);
      float s = v[2] / 255.0f;
      s = clampf(saturate_value(s, static_cast<float>(intensity)), 0.0f, 1.0f);
      v[2] = to_uchar(s * 255.0f);
      hls.at<cv::Vec3b>(i, j) = v;
    }
  });

  cv::cvtColor(hls, rgb, cv::COLOR_HLS2RGB);
  cv::Mat out;
  cv::cvtColor(rgb, out, cv::COLOR_RGB2BGR);
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_sepia(const cpp11::integers& nr, int height, int width,
                           double intensity, int depth) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float d = static_cast<float>(depth);
  const float intf = static_cast<float>(intensity);
  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = v[2];
      const float g = v[1];
      const float b = v[0];
      float nr = clampf(r + d * 2.0f, 0.0f, 255.0f);
      float ng = clampf(g + d, 0.0f, 255.0f);
      float nb = clampf((r + g + b) / 3.0f, 0.0f, 255.0f);
      nb = clampf(nb - nb * intf, 0.0f, 255.0f);
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(nb), to_uchar(ng), to_uchar(nr));
    }
  });
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_set_matte(const cpp11::integers& nr, int height, int width,
                               const cpp11::integers& color) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const uchar r = static_cast<uchar>(color[0]);
  const uchar g = static_cast<uchar>(color[1]);
  const uchar b = static_cast<uchar>(color[2]);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      if (bgra[1].at<uchar>(i, j) != 255) {
        out.at<cv::Vec3b>(i, j) = cv::Vec3b(b, g, r);
      }
    }
  });

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_solarize(const cpp11::integers& nr, int height, int width,
                              double threshold) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float th = static_cast<float>(threshold);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float r = v[2];
      const float g = v[1];
      const float b = v[0];
      const float intensity = ((r + g + b) / 3.0f) / 255.0f;
      if (intensity < th) {
        out.at<cv::Vec3b>(i, j) = cv::Vec3b(255 - v[0], 255 - v[1], 255 - v[2]);
      }
    }
  });

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_unpremul(const cpp11::integers& nr, int height, int width,
                              int max) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out = bgra[0].clone();
  const float maxf = static_cast<float>(max);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const auto v = bgra[0].at<cv::Vec3b>(i, j);
      const float a = bgra[1].at<uchar>(i, j) / maxf;
      if (a <= 0.0f) {
        out.at<cv::Vec3b>(i, j) = cv::Vec3b(0, 0, 0);
        continue;
      }
      const float r = v[2] / a;
      const float g = v[1] / a;
      const float b = v[0] / a;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(to_uchar(b), to_uchar(g), to_uchar(r));
    }
  });

  return aznyan::encode_nr(out, bgra[1]);
}
