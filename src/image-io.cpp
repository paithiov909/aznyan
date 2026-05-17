#include "aznyan_types.h"

namespace aznyan {

cpp11::integers azny_read(const cv::Mat& img) {
  cv::Mat tmp;
  if (img.channels() == 3) {
    cv::cvtColor(img, tmp, cv::COLOR_BGR2BGRA);
  } else if (img.channels() == 1) {
    cv::cvtColor(img, tmp, cv::COLOR_GRAY2BGRA);
  } else {
    tmp = std::move(img);
  }
  auto [bgra, ch] = aznyan::split_bgra(tmp);
  cpp11::writable::integers out = aznyan::encode_nr(bgra[0], bgra[1]);
  out.attr("dim") = cpp11::as_sexp({img.rows, img.cols});
  return out;
}

};  // namespace aznyan

[[cpp11::register]]
cpp11::integers azny_read_still(const std::string& filename) {
  if (!cv::haveImageReader(filename)) {
    cpp11::stop("Unsupported image format.");
  }
  const cv::Mat img = cv::imread(filename, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Failed to read image file: %s", filename.c_str());
  }
  return aznyan::azny_read(img);
}

[[cpp11::register]]
cpp11::integers azny_read_data(const cpp11::raws& data) {
  std::vector<uchar> buf(data.begin(), data.end());
  const cv::Mat img = cv::imdecode(buf, cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Failed to decode image data.");
  }
  return aznyan::azny_read(img);
}

[[cpp11::register]]
std::string azny_write_still(const std::string& filename,
                             const cpp11::integers& nr, int height, int width) {
  if (!cv::haveImageWriter(filename)) {
    cpp11::stop("Unsupported image format.");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat out;
  cv::merge(bgra, out);
  cv::imwrite(filename, out);
  return filename;
}

[[cpp11::register]]
cpp11::raws azny_write_data(const std::string& ext, const cpp11::integers& nr,
                            int height, int width, int quality) {
  if (!cv::haveImageWriter(ext)) {
    cpp11::stop("Unsupported image format.");
  }
  std::vector<int> params;
  if (ext == ".jpg" || ext == ".jpeg") {
    params = {cv::IMWRITE_JPEG_QUALITY, std::clamp(quality, 0, 100)};  // 0-100
#ifdef HAVE_AVIF
  } else if (ext == ".avif") {
    params = {cv::IMWRITE_AVIF_QUALITY, std::clamp(quality, 0, 100)};  // 0-100
#endif
  } else if (ext == ".webp") {
    params = {cv::IMWRITE_WEBP_QUALITY, std::clamp(quality, 1, 100)};  // 1-100
  } else if (ext == ".png") {
    params = {cv::IMWRITE_PNG_COMPRESSION,
              std::clamp(quality / 11, 0, 9)};  // 0-9
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  std::vector<uchar> out;
  cv::Mat tmp;
  cv::merge(bgra, tmp);
  cv::imencode(ext, tmp, out, params);
  return cpp11::writable::raws{out.begin(), out.end()};
}

[[cpp11::register]]
std::string azny_write_animation(const std::vector<std::string>& frames,
                                 const std::string& filename, int duration,
                                 int quality, int loop_count) {
#ifndef HAVE_ANIMATION
  cpp11::stop(
      "Animation writing requires OpenCV >= 4.11, "
      "but this package was built against an older version.");
#else
  if (!cv::haveImageWriter(filename)) {
    cpp11::stop("Unsupported image format.");
  }
  const std::vector<int> params = {cv::IMWRITE_WEBP_QUALITY, quality};
  cv::Animation anim = cv::Animation{loop_count, cv::Scalar()};

  for (const auto& frame : frames) {
    cv::Mat img = cv::imread(frame, cv::IMREAD_COLOR);
    if (img.empty()) {
      cpp11::stop("Failed to read image file: %s", frame.c_str());
    }
    anim.frames.push_back(img);
    anim.durations.push_back(duration);
  }
  cv::imwriteanimation(filename, anim, params);

  return filename;
#endif
}
