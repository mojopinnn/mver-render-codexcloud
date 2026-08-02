#pragma once

#include <QJsonObject>
#include <QSize>
#include <QString>

struct MediaReport {
  QString path;
  QString format;
  QSize dimensions;
  qint64 bytes = 0;
  bool readable = false;

  static MediaReport inspect(const QString &path);
  QJsonObject toJson() const;
};
