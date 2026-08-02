#include "mediareport.h"

#include <QFileInfo>
#include <QImageReader>

MediaReport MediaReport::inspect(const QString &path) {
  const QFileInfo info(path);
  QImageReader reader(path);

  MediaReport report;
  report.path = info.absoluteFilePath();
  report.bytes = info.exists() ? info.size() : 0;
  report.format = QString::fromLatin1(reader.format()).toUpper();
  report.dimensions = reader.size();
  report.readable = info.isFile() && info.isReadable() && reader.canRead();
  return report;
}

QJsonObject MediaReport::toJson() const {
  return {{"path", path},
          {"readable", readable},
          {"format", format},
          {"width", dimensions.width()},
          {"height", dimensions.height()},
          {"bytes", bytes}};
}

