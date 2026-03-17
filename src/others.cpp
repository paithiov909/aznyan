#include "aznyan_types.h"
#include <opencv2/xphoto.hpp>

namespace {

struct MedianCutColor {
  uchar b;
  uchar g;
  uchar r;
  int count;
};

struct MedianCutBox {
  std::vector<int> color_ids;
};

struct MedianCutStats {
  int channel;
  int range;
  int population;
  bool splittable;
};

inline uint32_t pack_rgb(uchar b, uchar g, uchar r) {
  return static_cast<uint32_t>(b) | (static_cast<uint32_t>(g) << 8) |
         (static_cast<uint32_t>(r) << 16);
}

inline int channel_value(const MedianCutColor& color, int channel) {
  if (channel == 0) return color.b;
  if (channel == 1) return color.g;
  return color.r;
}

MedianCutStats compute_box_stats(const MedianCutBox& box,
                                 const std::vector<MedianCutColor>& colors) {
  std::array<int, 3> mins{255, 255, 255};
  std::array<int, 3> maxs{0, 0, 0};
  int population = 0;

  for (const int color_id : box.color_ids) {
    const auto& color = colors[color_id];
    mins[0] = std::min(mins[0], static_cast<int>(color.b));
    mins[1] = std::min(mins[1], static_cast<int>(color.g));
    mins[2] = std::min(mins[2], static_cast<int>(color.r));
    maxs[0] = std::max(maxs[0], static_cast<int>(color.b));
    maxs[1] = std::max(maxs[1], static_cast<int>(color.g));
    maxs[2] = std::max(maxs[2], static_cast<int>(color.r));
    population += color.count;
  }

  const std::array<int, 3> ranges{maxs[0] - mins[0], maxs[1] - mins[1],
                                  maxs[2] - mins[2]};

  int channel = 0;
  if (ranges[1] > ranges[channel]) channel = 1;
  if (ranges[2] > ranges[channel]) channel = 2;

  return MedianCutStats{
      channel,
      ranges[channel],
      population,
      box.color_ids.size() > 1 && ranges[channel] > 0,
  };
}

bool split_box(const MedianCutBox& box,
               const std::vector<MedianCutColor>& colors, int channel,
               MedianCutBox* left, MedianCutBox* right) {
  std::vector<int> sorted_ids = box.color_ids;
  std::sort(sorted_ids.begin(), sorted_ids.end(), [&](int lhs, int rhs) {
    const auto& a = colors[lhs];
    const auto& b = colors[rhs];
    const int av = channel_value(a, channel);
    const int bv = channel_value(b, channel);
    if (av != bv) return av < bv;
    if (a.r != b.r) return a.r < b.r;
    if (a.g != b.g) return a.g < b.g;
    if (a.b != b.b) return a.b < b.b;
    return lhs < rhs;
  });

  int total = 0;
  for (const int color_id : sorted_ids) {
    total += colors[color_id].count;
  }

  const int target = (total + 1) / 2;
  int cumulative = 0;
  int split_at = static_cast<int>(sorted_ids.size()) / 2;
  for (int i = 0; i < static_cast<int>(sorted_ids.size()) - 1; ++i) {
    cumulative += colors[sorted_ids[i]].count;
    if (cumulative >= target) {
      split_at = i + 1;
      break;
    }
  }

  split_at = std::clamp(split_at, 1, static_cast<int>(sorted_ids.size()) - 1);
  left->color_ids.assign(sorted_ids.begin(), sorted_ids.begin() + split_at);
  right->color_ids.assign(sorted_ids.begin() + split_at, sorted_ids.end());
  return !left->color_ids.empty() && !right->color_ids.empty();
}

}  // namespace

[[cpp11::register]]
cpp11::integers azny_det_enhance(const cpp11::integers& nr, int height,
                                 int width, double sgmS, double sgmR) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  sgmS = std::clamp(sgmR, 0.0, 200.0);
  sgmR = std::clamp(sgmR, 0.0, 1.0);

  cv::Mat tmpB;
  cv::detailEnhance(bgra[0], tmpB, sgmS, sgmR);

  return aznyan::encode_nr(tmpB, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_hist_eq(const cpp11::integers& nr, int height, int width,
                             int gridW, int gridH, double limit, bool adp,
                             bool color) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB, tmpC;
  cv::cvtColor(bgra[0], tmpB, cv::COLOR_BGR2GRAY);
  if (adp) {
    auto clahe = cv::createCLAHE(limit, cv::Size(gridW, gridH));
    clahe->apply(tmpB, tmpC);
  } else {
    cv::equalizeHist(tmpB, tmpC);
  }

  cv::Mat tmpD = bgra[0];
  cv::Mat out(tmpD.size(), CV_8UC3);
  if (color) {
    aznyan::parallel_for(0, height, [&](int y) {
      uchar* pIN1 = tmpC.ptr<uchar>(y);
      uchar* pIN2 = tmpB.ptr<uchar>(y);
      cv::Vec3b* pIN3 = tmpD.ptr<cv::Vec3b>(y);
      cv::Vec3b* pOUT = out.ptr<cv::Vec3b>(y);

      for (int x = 0; x < width; ++x) {
        double coef = 0;
        if (pIN2[x] != 0) {
          coef = ((double)pIN1[x]) / pIN2[x];
        }
        pOUT[x][0] = cv::saturate_cast<uchar>(coef * pIN3[x][0]);
        pOUT[x][1] = cv::saturate_cast<uchar>(coef * pIN3[x][1]);
        pOUT[x][2] = cv::saturate_cast<uchar>(coef * pIN3[x][2]);
      }
    });
  } else {
    cv::cvtColor(tmpC, out, cv::COLOR_GRAY2BGR);
  }

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_meanshift(const cpp11::integers& nr, int height, int width,
                               double sp, double sr, int maxl) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB;
  cv::pyrMeanShiftFiltering(bgra[0], tmpB, sp, sr, maxl);

  return aznyan::encode_nr(tmpB, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_median_cut(const cpp11::integers& nr, int height,
                                int width, int n_colors) {
  if (n_colors < 1) {
    cpp11::stop("`n_colors` must be at least 1.");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  const cv::Mat& bgr = bgra[0];

  std::unordered_map<uint32_t, int> counts;
  counts.reserve(static_cast<size_t>(height) * static_cast<size_t>(width));
  for (int y = 0; y < height; ++y) {
    const cv::Vec3b* row = bgr.ptr<cv::Vec3b>(y);
    for (int x = 0; x < width; ++x) {
      const cv::Vec3b& px = row[x];
      ++counts[pack_rgb(px[0], px[1], px[2])];
    }
  }

  if (static_cast<int>(counts.size()) <= n_colors) {
    return nr;
  }

  std::vector<MedianCutColor> colors;
  colors.reserve(counts.size());
  for (const auto& [packed, count] : counts) {
    colors.push_back(MedianCutColor{
        static_cast<uchar>(packed & 0xFF),
        static_cast<uchar>((packed >> 8) & 0xFF),
        static_cast<uchar>((packed >> 16) & 0xFF),
        count,
    });
  }
  counts.clear();

  MedianCutBox root;
  root.color_ids.reserve(colors.size());
  for (int i = 0; i < static_cast<int>(colors.size()); ++i) {
    root.color_ids.push_back(i);
  }

  std::vector<MedianCutBox> boxes;
  boxes.push_back(std::move(root));

  while (static_cast<int>(boxes.size()) < n_colors) {
    int best_idx = -1;
    MedianCutStats best_stats{0, 0, 0, false};

    for (int i = 0; i < static_cast<int>(boxes.size()); ++i) {
      const auto stats = compute_box_stats(boxes[i], colors);
      if (!stats.splittable) continue;
      if (best_idx < 0 || stats.range > best_stats.range ||
          (stats.range == best_stats.range &&
           stats.population > best_stats.population)) {
        best_idx = i;
        best_stats = stats;
      }
    }

    if (best_idx < 0) {
      break;
    }

    MedianCutBox left, right;
    if (!split_box(boxes[best_idx], colors, best_stats.channel, &left,
                   &right)) {
      break;
    }

    boxes[best_idx] = std::move(left);
    boxes.push_back(std::move(right));
  }

  std::unordered_map<uint32_t, cv::Vec3b> palette;
  palette.reserve(colors.size());

  for (const auto& box : boxes) {
    long long sum_b = 0;
    long long sum_g = 0;
    long long sum_r = 0;
    long long total = 0;

    for (const int color_id : box.color_ids) {
      const auto& color = colors[color_id];
      sum_b += static_cast<long long>(color.b) * color.count;
      sum_g += static_cast<long long>(color.g) * color.count;
      sum_r += static_cast<long long>(color.r) * color.count;
      total += color.count;
    }

    const cv::Vec3b representative(
        static_cast<uchar>(std::llround(static_cast<double>(sum_b) / total)),
        static_cast<uchar>(std::llround(static_cast<double>(sum_g) / total)),
        static_cast<uchar>(std::llround(static_cast<double>(sum_r) / total)));

    for (const int color_id : box.color_ids) {
      const auto& color = colors[color_id];
      palette.emplace(pack_rgb(color.b, color.g, color.r), representative);
    }
  }

  cv::Mat out = bgr.clone();
  aznyan::parallel_for(0, height, [&](int y) {
    const cv::Vec3b* src_row = bgr.ptr<cv::Vec3b>(y);
    cv::Vec3b* dst_row = out.ptr<cv::Vec3b>(y);
    for (int x = 0; x < width; ++x) {
      const cv::Vec3b& px = src_row[x];
      dst_row[x] = palette.at(pack_rgb(px[0], px[1], px[2]));
    }
  });

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_oilpaint(const cpp11::integers& nr, int height, int width,
                              int size, int ratio) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  size = std::max(size, 2);
  cv::Mat out;
  cv::xphoto::oilPainting(bgra[0], out, size, ratio);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_pencilskc(const cpp11::integers& nr, int height, int width,
                               double sgmS, double sgmR, double shade,
                               bool color) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  sgmS = std::clamp(sgmS, 0.0, 200.0);
  sgmR = std::clamp(sgmR, 0.0, 1.0);
  shade = std::clamp(shade, 0.0, 1.0);

  cv::Mat tmpB, tmpC, out;
  cv::pencilSketch(bgra[0], tmpB, tmpC, sgmS, sgmR, shade);

  if (color) {
    out = tmpC;
  } else {
    cv::cvtColor(tmpB, out, cv::COLOR_GRAY2BGR);
  }
  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_preserving(const cpp11::integers& nr, int height,
                                int width, double sgmS, double sgmR,
                                bool mode) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  const auto flag = mode ? cv::RECURS_FILTER : cv::NORMCONV_FILTER;

  sgmS = std::clamp(sgmS, 0.0, 200.0);
  sgmR = std::clamp(sgmR, 0.0, 1.0);

  cv::Mat out;
  cv::edgePreservingFilter(bgra[0], out, flag, sgmS, sgmR);

  return aznyan::encode_nr(out, bgra[1]);
}

[[cpp11::register]]
cpp11::integers azny_stylize(const cpp11::integers& nr, int height, int width,
                             double sgmS, double sgmR) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  sgmS = std::clamp(sgmR, 0.0, 200.0);
  sgmR = std::clamp(sgmR, 0.0, 1.0);

  cv::Mat out;
  cv::stylization(bgra[0], out, sgmS, sgmR);

  return aznyan::encode_nr(out, bgra[1]);
}
