#include "spectraluser.h"
#include "hsluv.h"

QColor SpectralUser::color() {
  double pr, pg, pb;
  hsluv::hsluv2rgb(hueF() * 360, 99., 30., &pr, &pg, &pb);

  return QColor::fromRgbF(pr, pg, pb);
}
