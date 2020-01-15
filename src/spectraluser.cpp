#include "spectraluser.h"
#include "hsluv.h"

#include <stdio.h>

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv::hsluv2rgb(hueF() * 360.0, 100.0, 30.0, &pr, &pg, &pb);

  printf("r: %g g: %g b: %g, hueF: %g, hueF * 360.0: %g\n", pr, pg, pb, hueF(), hueF() * 360.0);
  return QColor::fromRgbF(qreal(pr), qreal(pg), qreal(pb));
}
