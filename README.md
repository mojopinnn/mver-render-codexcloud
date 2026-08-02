# mver

`mver` is a Qt 6 media inspection workspace. The first application milestone
provides image preview, drag-and-drop opening, basic format/dimension/size
metadata, and a JSON command-line report suitable for automation.

## Build and test

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

Launch the desktop application with `build/src/mver [image]`. For automation,
run `build/src/mver-cli image.png`; a readable image returns zero and prints a
JSON report. An unreadable or unsupported file returns one, while invalid
command-line usage returns two.

## Verify the GUI

On a desktop, run `build/src/mver`, click **Open media…**, and confirm that the
preview and the path, dimensions, format, and byte count update. The same flow
also accepts a file dragged from the file manager.

For a repeatable headless visual check, generate a PNG after building:

```sh
QT_QPA_PLATFORM=offscreen build/src/mver --screenshot mver-window.png
```

The command initializes and paints the real main window, captures it, and exits
non-zero if the screenshot cannot be written. The packaging smoke test runs this
same rendered-GUI check and publishes the PNG as a CI artifact. It uses Qt's
offscreen display backend because hosted CI machines have no physical monitor;
it does not skip construction or painting of the GUI.

### Interactive browser preview in a sandbox

`mver` is a native desktop application, so it does not normally have an HTTP
address. In a remote Linux sandbox it can be made interactive through a virtual
X display and noVNC:

```sh
sudo apt-get install xvfb x11vnc novnc websockify
scripts/run-gui-preview.sh
```

Forward port `6080` in the sandbox/IDE and open the URL printed by the script.
This shows the actual Qt process—not a rewritten web frontend—and supports mouse,
keyboard, file dialogs, and drag-and-drop within the virtual desktop. Set
`MVER_PREVIEW_PORT` to use a different port.

## Packaging

Install to a clean tree with `cmake --install build --prefix staging`. When
`linuxdeploy` is available, the configure step also exposes `appdir` and
`appimage` build targets. See `scripts/package-smoke.cmake` for the packaged
runtime validation used by CI.
