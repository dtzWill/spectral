#include "spectraluser.h"
#include "hsluv.h"

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv2rgb(hueF() * 360.0, 100.0, 30.0, &pr, &pg, &pb);
  return QColor::fromRgbF(pr, pg, pb);
}
