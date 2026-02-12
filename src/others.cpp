#include "aznyan_types.h"
#include <opencv2/xphoto.hpp>

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
