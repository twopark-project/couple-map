#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

/**
     * @brief Constructs a FlutterWindow and saves the Dart project configuration.
     *
     * Stores a copy of the provided Dart project for use when creating the Flutter
     * engine and view during window initialization.
     *
     * @param project Dart project configuration used to initialize the Flutter engine.
     */
    FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

/**
 * @brief Destroys the FlutterWindow and releases any resources owned by it.
 */
FlutterWindow::~FlutterWindow() {}

/**
 * @brief Initializes a Flutter view controller, attaches its native view to this window, and prepares the first frame so the window will be shown.
 *
 * This sets up a FlutterViewController sized to the current client area, registers plugins on the controller's engine, and installs the controller's native view as the window content. It schedules the window to be shown once the first Flutter frame is produced and forces a redraw to ensure a pending first frame when possible.
 *
 * @return true if the Flutter controller and view were successfully created and attached; false on failure.
 */
bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

/**
 * @brief Cleans up FlutterWindow resources before the window is destroyed.
 *
 * Releases the held Flutter view controller (if any) and then delegates remaining
 * destruction work to the base Win32Window::OnDestroy implementation.
 */
void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

/**
 * @brief Dispatches a Windows message to Flutter (and its plugins) before falling back to the base handler.
 *
 * If Flutter handles the message, its result is returned. For WM_FONTCHANGE, the Flutter engine's system
 * fonts are reloaded. If neither Flutter nor the special-case handling consumes the message, the result
 * from the base Win32Window::MessageHandler is returned.
 *
 * @param hwnd Handle to the window receiving the message.
 * @param message The Windows message identifier.
 * @param wparam Additional message information (message-specific).
 * @param lparam Additional message information (message-specific).
 * @return LRESULT The result code produced by Flutter or the base window procedure.
 */
LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}