#include "aznyan_types.h"

[[cpp11::register]]
cpp11::integers azny_lineweave(const cpp11::integers& nr, int height, int width,
                               double omega, double phase, int dist1, int dist2,
                               int dist3, bool invert, int direction,
                               const cpp11::integers& fg,
                               const cpp11::integers& bg) {
  if (nr.size() != fg.size() || nr.size() != bg.size()) {
    cpp11::stop("nr, fg, and bg must have the same length.");
  }
  auto [bgra, ch] = aznyan::decode_nr(nr, height, width);
  auto [bgra_fg, ch_fg] = aznyan::decode_nr(fg, height, width);
  auto [bgra_bg, ch_bg] = aznyan::decode_nr(bg, height, width);

  cv::Mat gray;
  cv::cvtColor(bgra[0], gray, cv::COLOR_BGR2GRAY);

  cv::Mat tmp_fg = bgra_fg[0];  // CV_8UC3
  cv::Mat tmp_bg = bgra_bg[0];  // CV_8UC3
  cv::Mat out(gray.size(), CV_8UC3);

  auto step_state = [&](double& lumisum, int& drawpx, int& drawing,
                        int& interval, uchar g) {
    // g: 0..255
    double lumi = srgb_to_linear(static_cast<double>(g) / 255.0);
    lumisum += (invert) ? lumi * omega : (1.0 - lumi) * omega;

    if (lumisum >= phase) {
      lumisum = 0;
      if (interval == 0 && drawing == 0) {
        drawing = dist1;
        interval = dist2;
      } else if (interval == 0 && drawing > 0) {
        drawpx = dist3;
        drawing--;
      } else {
        interval--;
      }
    }
  };

  const bool outerIsRow = (direction == 0 || direction == 3);
  const bool innerReverse = (direction == 0 || direction == 2);

  if (outerIsRow) {
    aznyan::parallel_for(0, height, [&](int y) {
      double lumisum = 0;
      int drawpx = 0;
      int drawing = dist1;
      int interval = 0;

      const uchar* gRow = gray.ptr<uchar>(y);
      const cv::Vec3b* fgRow = tmp_fg.ptr<cv::Vec3b>(y);
      const cv::Vec3b* bgRow = tmp_bg.ptr<cv::Vec3b>(y);
      cv::Vec3b* outRow = out.ptr<cv::Vec3b>(y);

      if (!innerReverse) {
        for (int x = 0; x < width; ++x) {
          step_state(lumisum, drawpx, drawing, interval, gRow[x]);
          if (drawpx > 0) {
            outRow[x] = fgRow[x];
            drawpx--;
          } else {
            outRow[x] = bgRow[x];
          }
        }
      } else {
        for (int x = width - 1; x >= 0; --x) {
          step_state(lumisum, drawpx, drawing, interval, gRow[x]);
          if (drawpx > 0) {
            outRow[x] = fgRow[x];
            drawpx--;
          } else {
            outRow[x] = bgRow[x];
          }
        }
      }
    });

  } else {
    aznyan::parallel_for(0, width, [&](int x) {
      double lumisum = 0;
      int drawpx = 0;
      int drawing = dist1;
      int interval = 0;

      if (!innerReverse) {
        for (int y = 0; y < height; ++y) {
          const uchar* gRow = gray.ptr<uchar>(y);
          const cv::Vec3b* fgRow = tmp_fg.ptr<cv::Vec3b>(y);
          const cv::Vec3b* bgRow = tmp_bg.ptr<cv::Vec3b>(y);
          cv::Vec3b* outRow = out.ptr<cv::Vec3b>(y);

          step_state(lumisum, drawpx, drawing, interval, gRow[x]);
          if (drawpx > 0) {
            outRow[x] = fgRow[x];
            drawpx--;
          } else {
            outRow[x] = bgRow[x];
          }
        }
      } else {
        for (int y = height - 1; y >= 0; --y) {
          const uchar* gRow = gray.ptr<uchar>(y);
          const cv::Vec3b* fgRow = tmp_fg.ptr<cv::Vec3b>(y);
          const cv::Vec3b* bgRow = tmp_bg.ptr<cv::Vec3b>(y);
          cv::Vec3b* outRow = out.ptr<cv::Vec3b>(y);

          step_state(lumisum, drawpx, drawing, interval, gRow[x]);
          if (drawpx > 0) {
            outRow[x] = fgRow[x];
            drawpx--;
          } else {
            outRow[x] = bgRow[x];
          }
        }
      }
    });
  }

  return aznyan::encode_nr(out, bgra[1]);
}
