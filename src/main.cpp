#include "mainwindow.h"

#include <QApplication>
#include <QCommandLineParser>
#include <QFileInfo>
#include <QTimer>

int main(int argc, char **argv) {
  QApplication app(argc, argv);
  QCoreApplication::setApplicationName("mver");
  QCoreApplication::setApplicationVersion("0.1.0");

  QCommandLineParser parser;
  parser.setApplicationDescription("Media inspection and verification workspace");
  parser.addHelpOption();
  parser.addVersionOption();
  parser.addOption({"headless", "Start without displaying the main window."});
  parser.addOption({"quit-after-startup", "Exit after the event loop starts (for package validation)."});
  parser.addOption({"screenshot", "Save a screenshot of the initialized window and exit.", "path"});
  parser.addPositionalArgument("media", "Optional media file to open.");
  parser.process(app);

  MainWindow window;
  if (!parser.positionalArguments().isEmpty()) window.openFile(parser.positionalArguments().first());
  if (!parser.isSet("headless") || parser.isSet("screenshot")) window.show();
  if (parser.isSet("screenshot")) {
    const QString path = QFileInfo(parser.value("screenshot")).absoluteFilePath();
    QTimer::singleShot(100, &window, [&app, &window, path] {
      if (!window.grab().save(path)) app.exit(3);
      else app.quit();
    });
  } else if (parser.isSet("quit-after-startup")) {
    QTimer::singleShot(0, &app, &QCoreApplication::quit);
  }
  return app.exec();
}
