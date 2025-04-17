#include "aznyan_types.h"
#include <cpp11.hpp>

// ディフュージョン（拡散フィルタ）
[[cpp11::register]]
cpp11::raws azny_diffusion(cpp11::raws png, int iter, float decay_factor,
                           float decay_offset, float gamma, int sigma) {
  const std::vector<unsigned char> png_data{png.begin(), png.end()};
  cv::Mat img = cv::imdecode(std::move(png_data), cv::IMREAD_UNCHANGED);
  if (img.empty()) {
    cpp11::stop("Cannot decode image.");
  }
  if (img.channels() != 4) {
    cpp11::stop("Image must have 4 channels.");
  }
  cv::Mat tmpB;
  img.convertTo(tmpB, CV_32FC4, 1.0 / 255.0);
  const auto width = img.cols;
  const auto height = img.rows;

  cv::Mat tmpC = cv::Mat::zeros(tmpB.size(), CV_32FC3);
  aznyan::parallel_for(0, height, [&](int32_t y) {
    auto pIN = tmpB.ptr<cv::Vec4f>(y);
    auto pPOW = tmpC.ptr<cv::Vec3f>(y);

    for (auto x = 0; x < width; ++x) {
      pPOW[x][0] = std::pow(pIN[x][0], gamma);
      pPOW[x][1] = std::pow(pIN[x][1], gamma);
      pPOW[x][2] = std::pow(pIN[x][2], gamma);
    }
  });

  cv::Mat tmpE = tmpC.clone();
  for (int32_t i = 0; i < iter; ++i) {
    float gain = std::pow(decay_factor, -((float)i + decay_offset));
    sigma *= sigma;
    cv::Mat tmpD;
    cv::GaussianBlur(tmpC, tmpD, cv::Size(), (double)sigma);

    aznyan::parallel_for(0, height, [&tmpD, &tmpE, gain, width](int32_t y) {
      auto pIN1 = tmpD.ptr<cv::Vec3f>(y);
      auto pIN2 = tmpE.ptr<cv::Vec3f>(y);

      for (auto x = 0; x < width; ++x) {
        pIN2[x][0] += (pIN1[x][0] * gain);
        pIN2[x][1] += (pIN1[x][1] * gain);
        pIN2[x][2] += (pIN1[x][2] * gain);
      }
    });
    tmpD.release();

    cpp11::check_user_interrupt();
  }

  float gm_inv = 1.0 / gamma;
  cv::Mat tmpF = cv::Mat::zeros(tmpB.size(), tmpB.type());
  aznyan::parallel_for(
      0, height, [&tmpE, &tmpF, &tmpB, gm_inv, width](int32_t y) {
        auto pIN3 = tmpE.ptr<cv::Vec3f>(y);
        auto pIN4 = tmpB.ptr<cv::Vec4f>(y);
        auto pOUT = tmpF.ptr<cv::Vec4f>(y);

        for (auto x = 0; x < width; ++x) {
          pOUT[x][0] = std::clamp(std::pow(pIN3[x][0], gm_inv), 0.f, 1.f);
          pOUT[x][1] = std::clamp(std::pow(pIN3[x][1], gm_inv), 0.f, 1.f);
          pOUT[x][2] = std::clamp(std::pow(pIN3[x][2], gm_inv), 0.f, 1.f);
          pOUT[x][3] = pIN4[x][3];
        }
      });

  cv::Mat out;
  convertScaleAbs(tmpF, out, 255.0, 0.0);

  std::vector<unsigned char> ret;
  cv::imencode(".png", out, ret, aznyan::params);
  return cpp11::writable::raws{std::move(ret)};
}
