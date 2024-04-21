/**
 * Modified from 'srtparser.h' of
 * https://github.com/saurabhshri/simple-yet-powerful-srt-subtitle-parser-cpp
 *
 * written by Saurabh Shrivastava.
 */
#include <iostream>
#include <fstream>
#include <Rcpp.h>

using namespace Rcpp;

std::vector<std::string> &split(
    const std::string &s,
    char delim,
    std::vector<std::string> &elems
) {
  std::stringstream ss(s);
  std::string item;

  while (getline(ss, item, delim)) {
    elems.push_back(item);
  }
  return elems;
}

//' @noRd
//' @keywords internal
// [[Rcpp::export]]
Rcpp::DataFrame read_srt_impl(
    std::string fileName,
    std::string collapse = "\n"
) {
  std::ifstream infile(fileName);
  std::string line, cue, start, end, completeLine = "", timeLine = "";
  std::vector<std::string> subNos, starts, ends, comLines;
  int turn = 0;

  /**
   * turn = 0 -> Add subtitle number
   * turn = 1 -> Add string to timeLine
   * turn > 1 -> Add string to completeLine
   */
  while (std::getline(infile, line)) {
    line.erase(remove(line.begin(), line.end(), '\r'), line.end());
    if (line.compare("")) {
      if (!turn) {
        cue = line;
        turn++;
        continue;
      }
      if (line.find("-->") != std::string::npos) {
        timeLine += line;

        std::vector<std::string> srtTime;
        srtTime = split(timeLine, ' ', srtTime);
        start = srtTime[0];
        end = srtTime[2];

      } else {
        if (completeLine != "") {
          completeLine += collapse;
        }
        completeLine += line;
      }
      turn++;
    } else {
      turn = 0;
      subNos.push_back(cue);
      starts.push_back(start);
      ends.push_back(end);
      comLines.push_back(completeLine);
      completeLine = timeLine = "";
    }
  }
  // insert last remaining subtitle
  subNos.push_back(cue);
  starts.push_back(start);
  ends.push_back(end);
  comLines.push_back(completeLine);

  return Rcpp::DataFrame::create(
    _["sub_id"] = Rcpp::wrap(subNos),
    _["start"]  = Rcpp::wrap(starts),
    _["end"]    = Rcpp::wrap(ends),
    _["text"]   = Rcpp::wrap(comLines)
  );
}
