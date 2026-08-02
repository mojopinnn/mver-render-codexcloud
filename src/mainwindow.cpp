#include "mainwindow.h"

#include "mediareport.h"

#include <QDragEnterEvent>
#include <QDropEvent>
#include <QFileDialog>
#include <QLabel>
#include <QMimeData>
#include <QPixmap>
#include <QPushButton>
#include <QVBoxLayout>

MainWindow::MainWindow() {
  setWindowTitle(tr("mver — Media Verifier"));
  resize(960, 640);
  setAcceptDrops(true);

  auto *panel = new QWidget(this);
  auto *layout = new QVBoxLayout(panel);
  layout->setContentsMargins(32, 24, 32, 24);
  layout->setSpacing(16);

  auto *title = new QLabel(tr("Media verification workspace"), panel);
  QFont titleFont = title->font();
  titleFont.setPointSize(20);
  titleFont.setBold(true);
  title->setFont(titleFont);

  preview_ = new QLabel(tr("Drop an image here, or choose a file to inspect."), panel);
  preview_->setAlignment(Qt::AlignCenter);
  preview_->setMinimumSize(480, 360);
  preview_->setStyleSheet("QLabel { background: #171a21; color: #aeb7c5; border: 1px dashed #596273; border-radius: 8px; }");

  details_ = new QLabel(tr("No media loaded"), panel);
  details_->setTextInteractionFlags(Qt::TextSelectableByMouse);
  auto *open = new QPushButton(tr("Open media…"), panel);
  connect(open, &QPushButton::clicked, this, &MainWindow::chooseFile);

  layout->addWidget(title);
  layout->addWidget(preview_, 1);
  layout->addWidget(details_);
  layout->addWidget(open, 0, Qt::AlignRight);
  setCentralWidget(panel);
}

void MainWindow::chooseFile() {
  const QString path = QFileDialog::getOpenFileName(this, tr("Open media"), {},
                                                    tr("Images (*.png *.jpg *.jpeg *.tif *.tiff *.webp);;All files (*)"));
  if (!path.isEmpty()) openFile(path);
}

void MainWindow::openFile(const QString &path) {
  const MediaReport report = MediaReport::inspect(path);
  QPixmap image(path);
  if (!report.readable || image.isNull()) {
    preview_->setText(tr("This file could not be decoded."));
    preview_->setPixmap({});
  } else {
    preview_->setPixmap(image.scaled(preview_->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation));
  }
  details_->setText(tr("%1  •  %2 × %3  •  %4  •  %5 bytes")
                        .arg(report.path, QString::number(report.dimensions.width()),
                             QString::number(report.dimensions.height()), report.format,
                             QString::number(report.bytes)));
}

void MainWindow::dragEnterEvent(QDragEnterEvent *event) {
  if (event->mimeData()->hasUrls()) event->acceptProposedAction();
}

void MainWindow::dropEvent(QDropEvent *event) {
  const auto urls = event->mimeData()->urls();
  if (!urls.isEmpty() && urls.first().isLocalFile()) openFile(urls.first().toLocalFile());
}

