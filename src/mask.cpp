#include "aznyan_types.h"

namespace {

inline uint8_t bit_interleave(const uint64_t& x, const uint64_t& y) {
  uint64_t v = 0;
  for (int i = 0; i < 32; ++i) {
    v |= (x & (1 << i)) << i;
    v |= (y & (1 << i)) << (i + 1);
  }
  return v;
}

inline uint8_t bit_reverse(const uint8_t& b) {
  return (b * 0x0202020202ULL & 0x010884422010ULL) % 1023;
}

}  // namespace

[[cpp11::register]]
cpp11::integers_matrix<> bayer_mat(const uint8_t& n) {
  cpp11::writable::integers_matrix<> ret(n, n);
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < n; ++j) {
      ret(i, j) = bit_reverse(bit_interleave((i ^ j), i));
    }
  }
  return ret;
}

[[cpp11::register]]
cpp11::integers azny_screen_tone(const cpp11::integers& nr, int height,
                                 int width, int cutoff, int lift, int bias,
                                 const cpp11::integers& pattern) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  auto [bgra_pat, ch_pat] = aznyan::decode_nr(pattern, height, width);

  cv::Mat gray, gray_pat;
  cv::cvtColor(bgra[0], gray, cv::COLOR_BGR2GRAY);
  cv::cvtColor(bgra_pat[0], gray_pat, cv::COLOR_BGR2GRAY);
  cv::Mat out(gray.size(), CV_8UC1);

  aznyan::parallel_for(0, height, [&](int y) {
    uchar* pIN = gray.ptr<uchar>(y);
    uchar* pMAP = gray_pat.ptr<uchar>(y);
    for (int x = 0; x < width; ++x) {
      out.at<uchar>(y, x) = pIN[x] > (pMAP[x] + cutoff)
                                ? cv::saturate_cast<uchar>(pIN[x] + lift)
                                : cv::saturate_cast<uchar>(pIN[x] + bias);
    }
  });

  cv::Mat ret;
  cv::merge(std::vector<cv::Mat>{out, out, out}, ret);

  return aznyan::encode_nr(ret, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_luma_gate_add(const cpp11::integers& src,
                                   const cpp11::integers& dst, int height,
                                   int width, const cpp11::integers& mask,
                                   float gamma) {
  auto [src_bgra, src_ch] = aznyan::decode_nr(src, height, width);
  auto [dst_bgra, dst_ch] = aznyan::decode_nr(dst, height, width);
  auto [mask_bgra, mask_ch] = aznyan::decode_nr(mask, height, width);

  const cv::Mat& src_bgr = src_bgra[0];
  const cv::Mat& dst_bgr = dst_bgra[0];
  const cv::Mat& mask_bgr = mask_bgra[0];
  const cv::Mat& mask_a = mask_bgra[1];

  cv::Mat out(height, width, CV_8UC3);

  aznyan::parallel_for(0, height, [&](int i) {
    for (int j = 0; j < width; j++) {
      const cv::Vec3b& s = src_bgr.at<cv::Vec3b>(i, j);
      const cv::Vec3b& d = dst_bgr.at<cv::Vec3b>(i, j);
      const cv::Vec3b& m = mask_bgr.at<cv::Vec3b>(i, j);
      const float sr = s[2] / 255.0f;
      const float sg = s[1] / 255.0f;
      const float sb = s[0] / 255.0f;
      const float dr = d[2] / 255.0f;
      const float dg = d[1] / 255.0f;
      const float db = d[0] / 255.0f;
      const float mr = m[2] / 255.0f;
      const float mg = m[1] / 255.0f;
      const float mb = m[0] / 255.0f;
      const float gd = gray_value(d);
      const float strength = std::pow(gd, gamma);
      const float rr = dr + sr * mr * strength;
      const float rg = dg + sg * mg * strength;
      const float rb = db + sb * mb * strength;
      out.at<cv::Vec3b>(i, j) =
          cv::Vec3b(cv::saturate_cast<uchar>(rb * 255.0f),
                    cv::saturate_cast<uchar>(rg * 255.0f),
                    cv::saturate_cast<uchar>(rr * 255.0f));
    }
  });

  return aznyan::encode_nr(out, mask_a);
}
