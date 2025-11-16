#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

/**
 * @brief Windows application entry point that initializes the runtime and runs the Flutter message loop.
 *
 * Initializes console attachment (or creates one when debugging), initializes COM for apartment-threaded use,
 * constructs a DartProject with the application's data directory and forwards command-line arguments to Dart,
 * creates and shows the main Flutter window, runs the Win32 message loop, and performs COM cleanup on exit.
 *
 * @param instance Handle to the current instance of the application.
 * @param prev Reserved; previously used instance handle (always null/unused on modern Windows).
 * @param command_line Command-line string for the current process.
 * @param show_command Flag that specifies how the window should be shown.
 * @return int EXIT_SUCCESS on normal termination, EXIT_FAILURE if window creation fails.
 */
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"couple_map", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}