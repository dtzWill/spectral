#include "spectraluser.h"
#include "hsluv.h"

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv2rgb(hueF() * 360.0, 100.0, 50.0, &pr, &pg, &pb);
  return QColor::fromRgbF(pr, pg, pb);
}
