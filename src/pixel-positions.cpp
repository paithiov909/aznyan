#include "aznyan_types.h"

namespace {

inline float pixel_value(int mode, const cv::Vec3b& v) {
  switch (mode) {
    case 0:  // luma
      return gray_value(v);
    case 1:  // B
      return static_cast<float>(v[0]) / 255.f;
    case 2:  // G
      return static_cast<float>(v[1]) / 255.f;
    case 3:  // R
      return static_cast<float>(v[2]) / 255.f;
    case 4:  // H
      return static_cast<float>(v[0]) / 180.f;
    case 5:  // L
      return static_cast<float>(v[1]) / 255.f;
    case 6:  // S
      return static_cast<float>(v[2]) / 255.f;
    default:
      return gray_value(v);
  }
}

}  // namespace

[[cpp11::register]]
cpp11::list azny_pixel_positions(const cpp11::integers& nr, int height,
                                 int width, int mode, float lower,
                                 float upper) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  if (mode >= 4) {
    cv::cvtColor(bgra[0], bgra[0], cv::COLOR_BGR2HLS);
  }

  std::vector<std::vector<int>> row(height);  // outer
  std::vector<std::vector<int>> col(height);  // inner
  std::vector<std::vector<int>> idx(height);

  aznyan::parallel_for(0, height, [&](int y) {
    const cv::Vec3b* pIN = bgra[0].ptr<cv::Vec3b>(y);
    std::vector<int> row_inner, col_inner, idx_inner;
    float v;
    for (int x = 0; x < width; ++x) {
      v = pixel_value(mode, pIN[x]);
      if (v >= lower && v <= upper) {
        row_inner.push_back(y + 1);
        col_inner.push_back(x + 1);
        idx_inner.push_back(x + y * width + 1);
      }
    }
    row[y] = row_inner;
    col[y] = col_inner;
    idx[y] = idx_inner;
  });

  std::vector<int> row_out;
  std::vector<int> col_out;
  std::vector<int> idx_out;
  for (std::size_t i = 0; i < row.size(); ++i) {
    row_out.insert(row_out.end(), row[i].begin(), row[i].end());
    col_out.insert(col_out.end(), col[i].begin(), col[i].end());
    idx_out.insert(idx_out.end(), idx[i].begin(), idx[i].end());
  }
  cpp11::writable::list out;
  out.push_back(cpp11::as_sexp(row_out));
  out.push_back(cpp11::as_sexp(col_out));
  out.push_back(cpp11::as_sexp(idx_out));

  return out;
}
