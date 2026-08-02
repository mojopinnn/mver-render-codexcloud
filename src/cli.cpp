#include "mediareport.h"

#include <QCommandLineParser>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QTextStream>

int main(int argc, char **argv) {
  QCoreApplication app(argc, argv);
  QCoreApplication::setApplicationName("mver-cli");
  QCoreApplication::setApplicationVersion("0.1.0");
  QCommandLineParser parser;
  parser.setApplicationDescription("Inspect media and emit a machine-readable verification report.");
  parser.addHelpOption();
  parser.addVersionOption();
  parser.addPositionalArgument("media", "Image file to inspect.");
  parser.process(app);

  if (parser.positionalArguments().size() != 1) {
    QTextStream(stderr) << "mver-cli: provide exactly one media file (see --help)\n";
    return 2;
  }
  const MediaReport report = MediaReport::inspect(parser.positionalArguments().first());
  QTextStream(stdout) << QJsonDocument(report.toJson()).toJson(QJsonDocument::Indented);
  return report.readable ? 0 : 1;
}

