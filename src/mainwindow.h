#pragma once

#include <QMainWindow>

class QLabel;

class MainWindow final : public QMainWindow {
  Q_OBJECT
public:
  MainWindow();
  void openFile(const QString &path);

protected:
  void dragEnterEvent(QDragEnterEvent *event) override;
  void dropEvent(QDropEvent *event) override;

private:
  void chooseFile();
  QLabel *preview_;
  QLabel *details_;
};

