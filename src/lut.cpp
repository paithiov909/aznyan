#include "smol_cube.h"
#include "aznyan_types.h"

namespace aznyan {

const float GANNMA = 2.4f;

int index(float x, float y, float z, int cube_size, bool is_r_fastest) {
  float r = std::clamp(x, 0.0f, 1.0f);
  float g = std::clamp(y, 0.0f, 1.0f);
  float b = std::clamp(z, 0.0f, 1.0f);

  float r_norm = r * (cube_size - 1);
  float g_norm = g * (cube_size - 1);
  float b_norm = b * (cube_size - 1);

  int ir = std::clamp(static_cast<int>(std::round(r_norm)), 0, cube_size - 1);
  int ig = std::clamp(static_cast<int>(std::round(g_norm)), 0, cube_size - 1);
  int ib = std::clamp(static_cast<int>(std::round(b_norm)), 0, cube_size - 1);

  // Rprintf("%f %f %f -> %d %d %d\n", x, y, z, r, g, b);
  return is_r_fastest
             ? (ir * cube_size * cube_size + ig * cube_size + ib)   // R-fastest
             : (ir + ig * cube_size + ib * cube_size * cube_size);  // B-fastest
}

cv::Mat sRGB_to_linear(const cv::Mat& img) {
  cv::Mat out(img.size(), CV_32FC3);
  for (int i = 0; i < img.rows; i++) {
    for (int j = 0; j < img.cols; j++) {
      cv::Vec3f v = img.at<cv::Vec3f>(i, j);
      for (int c = 0; c < 3; ++c) {
        float s = v[c];
        out.at<cv::Vec3f>(i, j)[c] =
            (s <= 0.04045f) ? s / 12.92f
                            : std::pow((s + 0.055f) / 1.055f, GANNMA);
      }
    }
  }
  return out;
}

cv::Mat linear_to_sRGB(const cv::Mat& img) {
  cv::Mat out(img.size(), CV_32FC3);
  for (int i = 0; i < img.rows; i++) {
    for (int j = 0; j < img.cols; j++) {
      cv::Vec3f v = img.at<cv::Vec3f>(i, j);
      for (int c = 0; c < 3; ++c) {
        float s = v[c];
        out.at<cv::Vec3f>(i, j)[c] =
            (s <= 0.0031308f) ? s * 12.92f
                              : 1.055f * std::pow(s, 1.0f / GANNMA) - 0.055f;
      }
    }
  }
  return out;
}

}  // namespace aznyan

[[cpp11::register]]
bool azny_write_smcube(const std::string& input_path,
                       const std::string& output_path) {
  auto luts = smcube_load_from_file(input_path.c_str());
  if (luts == nullptr) {
    cpp11::stop("Incompatible file format.");
  }
  auto ok = smcube_save_to_file_smcube(output_path.c_str(), luts,
                                       smcube_save_flag_FilterData);
  smcube_free(luts);
  return ok;
}

[[cpp11::register]]
cpp11::doubles azny_read_cube(const std::string& file_path, bool verbose) {
  auto luts = smcube_load_from_file(file_path.c_str());
  if (luts == nullptr) {
    cpp11::stop("Incompatible file format.");
  }
  const int li = smcube_get_count(luts);
  if (li != 1) {
    cpp11::message("Warning: Cube LUT has ", li,
                   " entries. Using first entry.");
  }
  const int dim = smcube_lut_get_dimension(luts, 0);
  const int channels = smcube_lut_get_channels(luts, 0);
  smcube_data_type data_type = smcube_lut_get_data_type(luts, 0);
  const int sizex = smcube_lut_get_size_x(luts, 0);
  const int sizey = smcube_lut_get_size_y(luts, 0);
  const int sizez = smcube_lut_get_size_z(luts, 0);
  const void* in_data = smcube_lut_get_data(luts, 0);

  if (verbose) {
    Rprintf("dim: %d, channels: %d, data_type: %d, size: %dx%dx%d\n", dim,
            channels, (int)data_type, sizex, sizey, sizez);
  }
  if (dim != 3) {
    smcube_free(luts);
    cpp11::stop("Cube LUT must be a 3D LUT.");
  }
  if (channels != 3) {
    smcube_free(luts);
    cpp11::stop("Cube LUT must have 3 channels.");
  }
  if (data_type != smcube_data_type::Float32 &&
      data_type != smcube_data_type::Float16) {
    smcube_free(luts);
    cpp11::stop("Unknown cube LUT data type.");
  }

  cpp11::writable::doubles lut;

  if (data_type == smcube_data_type::Float32) {
    const int lut_size = smcube_lut_get_data_size(luts, 0) / sizeof(float);
    lut.resize(lut_size);
    const float* lut_data = reinterpret_cast<const float*>(in_data);
    for (int i = 0; i < lut_size; i++) {
      lut[i] = lut_data[i];
    }
  } else if (data_type == smcube_data_type::Float16) {
    const int lut_size = smcube_lut_get_data_size(luts, 0) / sizeof(uint16_t);
    lut.resize(lut_size);
    const uint16_t* lut_data = reinterpret_cast<const uint16_t*>(in_data);
    for (int i = 0; i < lut_size; i++) {
      lut[i] = lut_data[i];
    }
  }
  smcube_free(luts);

  return lut;
}

[[cpp11::register]]
cpp11::integers azny_apply_cube(const cpp11::integers& nr, int height,
                                int width, cpp11::doubles_matrix<> lut_data,
                                int cube_size, double intensity,
                                bool is_r_fastest) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  // sRGB -> linear
  cv::Mat tmpA;
  bgra[0].convertTo(tmpA, CV_32FC3, 1.0 / 255, 0.0);
  cv::Mat img_lin = aznyan::sRGB_to_linear(tmpA);

  cv::Mat tmpB = cv::Mat::zeros(bgra[0].size(), CV_32FC3);

  for (int i = 0; i < bgra[0].rows; i++) {
    for (int j = 0; j < bgra[1].cols; j++) {
      cv::Vec3f v = img_lin.at<cv::Vec3f>(i, j);

      int idx = aznyan::index(v[0], v[1], v[2], cube_size, is_r_fastest);
      if ((idx > lut_data.nrow()) | (idx < 0)) {
        cpp11::stop("Index out of bounds.");
      }
      tmpB.at<cv::Vec3f>(i, j) =
          cv::Vec3f(v[2] * (1 - intensity) +
                        static_cast<float>(lut_data(idx, 0)) * intensity,
                    v[1] * (1 - intensity) +
                        static_cast<float>(lut_data(idx, 1)) * intensity,
                    v[0] * (1 - intensity) +
                        static_cast<float>(lut_data(idx, 2)) * intensity);
    }
  }
  // linear -> sRGB
  cv::Mat img_srgb = aznyan::linear_to_sRGB(tmpB);

  cv::Mat img_u8;
  img_srgb.convertTo(img_u8, CV_8UC3, 255.0);
  return aznyan::encode_nr(img_u8, bgra[1]);
}

[[cpp11::register]]
cpp11::doubles azny_decode_rec709(const std::vector<double>& in_vec) {
  std::vector<double> ret;
  for (const auto& c : in_vec) {
    ret.push_back((c < 0.081) ? (c / 4.5f)
                              : std::pow((c + 0.099f) / 1.099f, 1.0f / 0.45f));
  }
  return cpp11::as_sexp(ret);
}

[[cpp11::register]]
cpp11::doubles azny_encode_rec709(const std::vector<double>& in_vec) {
  std::vector<double> ret;
  for (const auto& c : in_vec) {
    ret.push_back((c < 0.018) ? (c * 4.5f)
                              : 1.099f * std::pow(c, 0.45f) - 0.099f);
  }
  return cpp11::as_sexp(ret);
}
