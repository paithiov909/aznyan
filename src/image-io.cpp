#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_read_still(const std::string& filename) {
  if (!cv::haveImageReader(filename)) {
    cpp11::stop("Unsupported image format.");
  }
  const cv::Mat img = cv::imread(filename, cv::IMREAD_UNCHANGED);
  cv::Mat tmp;
  if (img.channels() == 3) {
    cv::cvtColor(img, tmp, cv::COLOR_BGR2BGRA);
  } else if (img.channels() == 1) {
    cv::cvtColor(img, tmp, cv::COLOR_GRAY2BGRA);
  } else {
    tmp = img;
  }
  auto [bgra, ch] = aznyan::split_bgra(tmp);
  cpp11::writable::integers out = aznyan::encode_nr(bgra[0], bgra[1]);
  out.attr("dim") = cpp11::as_sexp({img.rows, img.cols});
  return out;
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
std::string azny_write_animation(const std::vector<std::string>& frames,
                                 const std::string& filename, int duration,
                                 int quality, int loop_count) {
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
}
