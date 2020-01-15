#include "spectraluser.h"
#include "hsluv.h"

#include <stdio.h>

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv2rgb(hueF() * 360.0, 100.0, 30.0, &pr, &pg, &pb);

  printf("%g %g %g\n", pr, pg, pb);
  return QColor::fromRgbF(pr, pg, pb);
}
