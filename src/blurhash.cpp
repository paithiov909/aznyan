#include "aznyan_types.h"

inline float srgb_to_linear(float x) {
  if (x <= 0.04045f) return x / 12.92f;
  return std::pow((x + 0.055f) / 1.055f, 2.4f);
}

inline float linear_to_srgb(float x) {
  if (x <= 0.0031308f) return x * 12.92f;
  return 1.055f * std::pow(x, 1.0f / 2.4f) - 0.055f;
}

[[cpp11::register]]
cpp11::integers azny_blurhash(const cpp11::integers& nr, int height, int width,
                              int x_comps, int y_comps) {
  if (x_comps <= 0 || y_comps <= 0) {
    cpp11::stop("Both x_comps and y_comps must be greater than 0.");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);

  cv::Mat tmpB;  // BGR (float)
  bgra[0].convertTo(tmpB, CV_32FC3, 1.0 / 255.0);

  cv::Mat imgLin(tmpB.size(), CV_32FC3);
  aznyan::parallel_for(0, height, [&](int y) {
    for (int x = 0; x < width; x++) {
      cv::Vec3f px = tmpB.at<cv::Vec3f>(y, x);
      imgLin.at<cv::Vec3f>(y, x) = cv::Vec3f(srgb_to_linear(px[2]),  // R
                                             srgb_to_linear(px[1]),  // G
                                             srgb_to_linear(px[0])   // B
      );
    }
  });

  cv::Mat currents = cv::Mat::zeros(y_comps, x_comps, CV_32FC3);
  for (int j = 0; j < y_comps; j++) {
    for (int i = 0; i < x_comps; i++) {
      int nthreads = cv::getNumThreads();
      std::vector<cv::Vec3f> partial(nthreads, cv::Vec3f(0, 0, 0));

      aznyan::parallel_for(0, height, [&](int y) {
        int tid = cv::getThreadNum();
        cv::Vec3f local(0, 0, 0);

        float fy = (y + .5f) / height;
        float cy = std::cos(M_PI * j * fy);

        for (int x = 0; x < width; x++) {
          float fx = (x + .5f) / width;
          float cx = std::cos(M_PI * i * fx);
          float basis = cx * cy;

          cv::Vec3f px = imgLin.at<cv::Vec3f>(y, x);
          local += px * basis;
        }

        partial[tid] += local;
      });

      // reduce
      cv::Vec3f sum(0, 0, 0);
      for (auto& p : partial) sum += p;

      float scale = 1.0f / (width * height);
      currents.at<cv::Vec3f>(j, i) = sum * scale;
    }
    cpp11::check_user_interrupt();
  }

  cv::Mat outBGR(tmpB.size(), CV_8UC3);
  aznyan::parallel_for(0, height, [&](int32_t y) {
    float fy = (y + .5f) / height;

    for (int x = 0; x < width; x++) {
      float fx = (x + .5f) / width;

      // --- 1. DCT reconstruction （Linear RGB） ---
      float r = 0.f, g = 0.f, b = 0.f;

      for (int j = 0; j < y_comps; j++) {
        float cy = std::cos((float)M_PI * j * fy);

        for (int i = 0; i < x_comps; i++) {
          float cx = std::cos((float)M_PI * i * fx);
          float basis = cx * cy;

          cv::Vec3f c = currents.at<cv::Vec3f>(j, i);  // Linear RGB
          r += c[0] * basis;
          g += c[1] * basis;
          b += c[2] * basis;
        }
      }

      // --- 2. Linear RGB -> sRGB ---
      float sr = linear_to_srgb(r);
      float sg = linear_to_srgb(g);
      float sb = linear_to_srgb(b);

      // --- 3. 8bit BGR ---
      outBGR.at<cv::Vec3b>(y, x) =
          cv::Vec3b((uchar)(std::clamp(sb, 0.f, 1.f) * 255.f),   // B
                    (uchar)(std::clamp(sg, 0.f, 1.f) * 255.f),   // G
                    (uchar)(std::clamp(sr, 0.f, 1.f) * 255.f));  // R
    }
  });

  return aznyan::encode_nr(outBGR, bgra[1]);
}
