#include "mediareport.h"

#include <QImage>
#include <QTemporaryDir>

int main() {
  QTemporaryDir temporary;
  if (!temporary.isValid()) return 1;
  const QString path = temporary.filePath("frame.png");
  if (!QImage(16, 9, QImage::Format_RGB32).save(path)) return 2;
  const MediaReport report = MediaReport::inspect(path);
  if (!report.readable || report.format != "PNG" || report.dimensions != QSize(16, 9) || report.bytes <= 0) return 3;
  if (MediaReport::inspect(temporary.filePath("missing.png")).readable) return 4;
  return 0;
}

