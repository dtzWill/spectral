#include "spectraluser.h"
#include "hsluv.h"

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv::hsluv2rgb(hueF() * 360, 100, 30., &pr, &pg, &pb);

  // Workaround bug where generated rgb are just outside valid range
  // when using saturation=100.  Solve by clamping to [0.0,1.0].
  auto rangeCheck = [](auto & x) {
    x = std::min(1.0, std::max(0.0, x));
  };

  rangeCheck(pr);
  rangeCheck(pg);
  rangeCheck(pb);

  return QColor::fromRgbF(pr, pg, pb);
}
