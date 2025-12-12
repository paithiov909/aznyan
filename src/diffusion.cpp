#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_diffusion(const cpp11::integers& nr, int height, int width,
                               int iter, double decay_factor, double decay_offset,
                               double gamma, int sigma) {
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  cv::Mat tmpB;
  bgra[0].convertTo(tmpB, CV_32FC3, 1.0 / 255.0);

  cv::Mat tmpC = cv::Mat::zeros(tmpB.size(), CV_32FC3);
  aznyan::parallel_for(0, height, [&](int32_t y) {
    auto pIN = tmpB.ptr<cv::Vec3f>(y);
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
  cv::Mat tmpF = cv::Mat::zeros(tmpB.size(), CV_32FC3);
  aznyan::parallel_for(0, height, [&tmpE, &tmpF, gm_inv, width](int32_t y) {
    auto pIN3 = tmpE.ptr<cv::Vec3f>(y);
    auto pOUT = tmpF.ptr<cv::Vec3f>(y);

    for (auto x = 0; x < width; ++x) {
      pOUT[x][0] = std::clamp(std::pow(pIN3[x][0], gm_inv), 0.f, 1.f);
      pOUT[x][1] = std::clamp(std::pow(pIN3[x][1], gm_inv), 0.f, 1.f);
      pOUT[x][2] = std::clamp(std::pow(pIN3[x][2], gm_inv), 0.f, 1.f);
    }
  });

  cv::Mat out;
  convertScaleAbs(tmpF, out, 255.0, 0.0);
  return aznyan::encode_nr(out, bgra[1]);
}
