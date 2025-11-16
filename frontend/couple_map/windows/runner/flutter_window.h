#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

/**
 * A Win32 window that hosts a Flutter view.
 *
 * The window's sole purpose is to create, own, and forward Windows events to a
 * FlutterViewController for embedding Flutter content in a native Win32 window.
 */

/**
 * Creates a new FlutterWindow hosting a Flutter view running the given Dart project.
 *
 * @param project The Dart project configuration to run inside the hosted Flutter view.
 */
 
/**
 * Destroys the FlutterWindow and releases any owned Flutter resources.
 */

/**
 * Perform initialization when the native window is created.
 *
 * @returns `true` if initialization succeeded and the window is ready to show, `false` otherwise.
 */

/**
 * Perform cleanup when the native window is destroyed.
 */

/**
 * Handle Windows messages sent to this window.
 *
 * @param window The HWND that received the message.
 * @param message The message identifier (WM_...).
 * @param wparam Additional message information (word-sized).
 * @param lparam Additional message information (long-sized).
 * @returns The result of message processing as an LRESULT; value semantics depend on the processed message.
 */
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_