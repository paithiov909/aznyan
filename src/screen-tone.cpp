#include "aznyan_types.h"

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
