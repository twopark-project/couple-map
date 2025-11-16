#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

/// Window attribute that enables dark mode window decorations.
///
/// Redefined in case the developer's machine has a Windows SDK older than
/// version 10.0.22000.0.
/// See: https://docs.microsoft.com/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

/// Registry key for app theme preference.
///
/// A value of 0 indicates apps should use dark mode. A non-zero or missing
/// value indicates apps should use light mode.
constexpr const wchar_t kGetPreferredBrightnessRegKey[] =
  L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize";
constexpr const wchar_t kGetPreferredBrightnessRegValue[] = L"AppsUseLightTheme";

// The number of Win32Window objects that currently exist.
static int g_active_window_count = 0;

using EnableNonClientDpiScaling = BOOL __stdcall(HWND hwnd);

// Scale helper to convert logical scaler values to physical using passed in
/**
 * @brief Scales an integer value by a floating-point scale factor.
 *
 * @param source Integer value to scale.
 * @param scale_factor Multiplicative scale factor.
 * @return int The result of `source * scale_factor` converted to an `int`.
 */
int Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

// Dynamically loads the |EnableNonClientDpiScaling| from the User32 module.
/**
 * @brief Enables non-client (window frame) DPI scaling for the specified window if the API is present.
 *
 * Attempts to enable per-window non-client DPI scaling for the provided HWND when the running
 * Windows version exposes the EnableNonClientDpiScaling API; if the API is unavailable this
 * function does nothing.
 *
 * @param hwnd Handle to the window for which to enable non-client DPI scaling.
 */
void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) {
    return;
  }
  auto enable_non_client_dpi_scaling =
      reinterpret_cast<EnableNonClientDpiScaling*>(
          GetProcAddress(user32_module, "EnableNonClientDpiScaling"));
  if (enable_non_client_dpi_scaling != nullptr) {
    enable_non_client_dpi_scaling(hwnd);
  }
  FreeLibrary(user32_module);
}

}  // namespace

// Manages the Win32Window's window class registration.
class WindowClassRegistrar {
 public:
  /**
 * @brief Destroys the WindowClassRegistrar instance.
 *
 * The destructor is defaulted; it does not unregister the window class. Call
 * UnregisterWindowClass() to explicitly unregister the class when needed.
 */
~WindowClassRegistrar() = default;

  /**
   * @brief Accesses the singleton WindowClassRegistrar instance.
   *
   * Creates the registrar on first call and returns its pointer.
   *
   * @return WindowClassRegistrar* Pointer to the singleton WindowClassRegistrar.
   */
  static WindowClassRegistrar* GetInstance() {
    if (!instance_) {
      instance_ = new WindowClassRegistrar();
    }
    return instance_;
  }

  // Returns the name of the window class, registering the class if it hasn't
  // previously been registered.
  const wchar_t* GetWindowClass();

  // Unregisters the window class. Should only be called if there are no
  // instances of the window.
  void UnregisterWindowClass();

 private:
  WindowClassRegistrar() = default;

  static WindowClassRegistrar* instance_;

  bool class_registered_ = false;
};

WindowClassRegistrar* WindowClassRegistrar::instance_ = nullptr;

/**
 * @brief Ensures the window class is registered and provides its class name.
 *
 * Registers the window class on first call (lazily) and returns the wide-string
 * class name used to create windows of this type.
 *
 * @return const wchar_t* Pointer to the null-terminated window class name.
 */
const wchar_t* WindowClassRegistrar::GetWindowClass() {
  if (!class_registered_) {
    WNDCLASS window_class{};
    window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
    window_class.lpszClassName = kWindowClassName;
    window_class.style = CS_HREDRAW | CS_VREDRAW;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = GetModuleHandle(nullptr);
    window_class.hIcon =
        LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
    window_class.hbrBackground = 0;
    window_class.lpszMenuName = nullptr;
    window_class.lpfnWndProc = Win32Window::WndProc;
    RegisterClass(&window_class);
    class_registered_ = true;
  }
  return kWindowClassName;
}

/**
 * @brief Unregisters the window class used for Win32Window instances.
 *
 * Removes the class registration for the internal window class name and updates
 * the registrar state to indicate the class is no longer registered.
 */
void WindowClassRegistrar::UnregisterWindowClass() {
  UnregisterClass(kWindowClassName, nullptr);
  class_registered_ = false;
}

/**
 * @brief Constructs a Win32Window and increments the global active window count.
 *
 * Initializes a new Win32Window instance and increments the internal counter
 * that tracks the number of active Win32Window objects.
 */
Win32Window::Win32Window() {
  ++g_active_window_count;
}

/**
 * @brief Destructor that cleans up the Win32Window instance.
 *
 * Decrements the global active window count and destroys the native window and associated resources.
 * If this was the last active window, class-level cleanup (unregistering the window class) will occur.
 */
Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

/**
 * @brief Creates a DPI-aware Win32 window with the specified title, position, and size.
 *
 * This destroys any existing native window owned by this object, creates a new
 * window using the provided logical (unscaled) origin and size, applies the
 * current window theme, and performs post-creation initialization.
 *
 * @param title Window title text.
 * @param origin Logical origin (x,y) in unscaled pixels for the window's top-left.
 * @param size Logical width and height in unscaled pixels for the window.
 * @return true if the window was created and initialized successfully, `false` otherwise.
 */
bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  Destroy();

  const wchar_t* window_class =
      WindowClassRegistrar::GetInstance()->GetWindowClass();

  const POINT target_point = {static_cast<LONG>(origin.x),
                              static_cast<LONG>(origin.y)};
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;

  HWND window = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
      Scale(size.width, scale_factor), Scale(size.height, scale_factor),
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  UpdateTheme(window);

  return OnCreate();
}

/**
 * @brief Shows the window using the normal display state.
 *
 * @return `true` if the window was previously visible, `false` otherwise.
 */
bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

/**
 * @brief Window procedure that associates the Win32Window instance on creation and forwards messages to it.
 *
 * On WM_NCCREATE stores the Win32Window pointer passed via lpCreateParams into GWLP_USERDATA,
 * enables non-client DPI scaling if available, and sets the instance's window handle.
 * For other messages, retrieves the associated Win32Window and delegates handling to its MessageHandler;
 * if no instance is available, falls back to DefWindowProc.
 *
 * @param window Handle to the window receiving the message.
 * @param message Window message identifier.
 * @param wparam Additional message information (message-specific).
 * @param lparam Additional message information (message-specific).
 * @return LRESULT Result of message processing from the instance MessageHandler or DefWindowProc.
 */
LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));

    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableFullDpiSupportIfAvailable(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

/**
 * @brief Processes window messages for this Win32Window instance and performs the associated window-level actions.
 *
 * Handles destruction, DPI changes, resizing, activation focus, and theme color changes for the window:
 * - Cleans up and optionally posts a quit message on WM_DESTROY.
 * - Applies suggested scaling and moves/resizes the window on WM_DPICHANGED.
 * - Resizes/moves embedded child content on WM_SIZE and sets focus to it on WM_ACTIVATE.
 * - Updates immersive theme on WM_DWMCOLORIZATIONCOLORCHANGED.
 *
 * @return LRESULT `0` if the message was handled, otherwise the result returned by DefWindowProc for the stored window handle.
 */
LRESULT
Win32Window::MessageHandler(HWND hwnd,
                            UINT const message,
                            WPARAM const wparam,
                            LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      Destroy();
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                   newHeight, SWP_NOZORDER | SWP_NOACTIVATE);

      return 0;
    }
    case WM_SIZE: {
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        // Size and position the child window.
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    }

    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;

    case WM_DWMCOLORIZATIONCOLORCHANGED:
      UpdateTheme(hwnd);
      return 0;
  }

  return DefWindowProc(window_handle_, message, wparam, lparam);
}

/**
 * @brief Destroys the window and performs associated cleanup.
 *
 * Calls the instance OnDestroy hook, destroys the native window if present and clears the stored handle.
 * If this is the last active window, asks the WindowClassRegistrar to unregister the window class.
 */
void Win32Window::Destroy() {
  OnDestroy();

  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_active_window_count == 0) {
    WindowClassRegistrar::GetInstance()->UnregisterWindowClass();
  }
}

/**
 * Maps a native window handle to the associated Win32Window instance.
 *
 * @return Win32Window* Pointer to the Win32Window associated with the given HWND, or `nullptr` if no association is stored.
 */
Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

/**
 * @brief Attaches a child window to this window, sizes it to fill the client area, and gives it input focus.
 *
 * Reparents the provided HWND to this window, moves and resizes it to match the current client rectangle, and sets keyboard focus to the child.
 *
 * @param content Handle of the child window to embed and size to the client area.
 */
void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();

  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);

  SetFocus(child_content_);
}

/**
 * @brief Retrieves the window's client-area rectangle.
 *
 * @return RECT The client-area rectangle in client coordinates (origin at the top-left of the client area).
 */
RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

/**
 * @brief Retrieves the native Win32 window handle for this window.
 *
 * @return HWND The window's native handle, or nullptr if the window has not been created or has been destroyed.
 */
HWND Win32Window::GetHandle() {
  return window_handle_;
}

/**
 * @brief Configure whether closing this window should terminate the application message loop.
 *
 * If enabled, the window will post a quit message when it is destroyed; if disabled, destroying the
 * window will not post a quit message.
 *
 * @param quit_on_close If `true`, post a quit message when the window is closed; otherwise do not.
 */
void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

/**
 * @brief Hook invoked after the native window has been created for subclass initialization.
 *
 * Default implementation performs no initialization. Subclasses may override to set up
 * resources or child controls and return `false` to indicate creation should be treated as failed.
 *
 * @return `true` if initialization succeeded, `false` otherwise.
 */
bool Win32Window::OnCreate() {
  // No-op; provided for subclasses.
  return true;
}

/**
 * @brief Hook invoked when the window is being destroyed to allow subclasses to clean up.
 *
 * The default implementation does nothing; override to perform teardown specific to the subclass.
 */
void Win32Window::OnDestroy() {
  // No-op; provided for subclasses.
}

/**
 * @brief Applies the user's preferred light/dark theme to the specified window.
 *
 * Reads the current user's AppsUseLightTheme registry value and, when available,
 * enables immersive dark mode for the given window when the registry indicates
 * dark mode is preferred.
 *
 * @param window Handle to the window whose theme should be updated.
 */
void Win32Window::UpdateTheme(HWND const window) {
  DWORD light_mode;
  DWORD light_mode_size = sizeof(light_mode);
  LSTATUS result = RegGetValue(HKEY_CURRENT_USER, kGetPreferredBrightnessRegKey,
                               kGetPreferredBrightnessRegValue,
                               RRF_RT_REG_DWORD, nullptr, &light_mode,
                               &light_mode_size);

  if (result == ERROR_SUCCESS) {
    BOOL enable_dark_mode = light_mode == 0;
    DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,
                          &enable_dark_mode, sizeof(enable_dark_mode));
  }
}