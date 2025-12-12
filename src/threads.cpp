#include "aznyan_types.h"

[[cpp11::register]]
int get_num_threads() {
  return cv::getNumThreads();
}

[[cpp11::register]]
int set_num_threads(int n) {
  if (n < 1) {
    cpp11::stop("Number of threads must be at least 1.");
  }
  cv::setNumThreads(n);
  return cv::getNumThreads();
}
