#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <stdio.h>
#include <windows.h>

#include <iostream>

/**
 * @brief Allocates and attaches a native Windows console to the current process and routes standard output streams to it.
 *
 * If a console is successfully created and attached, the function connects the process's stdout/stderr and synchronizes C++ iostreams with the console output. If a console cannot be allocated, the process's existing I/O state is left unchanged.
 */
void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE *unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

/**
 * @brief Retrieve command line arguments converted to UTF-8.
 *
 * Obtains the process command line from the Windows API, converts each argument (except the binary name) from UTF-16 to UTF-8, and returns them as a vector of std::string.
 *
 * @return std::vector<std::string> A vector of command line arguments encoded in UTF-8, excluding the program binary name. Returns an empty vector if the Windows API call fails.
 */
std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line arguments to UTF-8 for the Engine to use.
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;

  // Skip the first argument as it's the binary name.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}

/**
 * @brief Convert a null-terminated UTF-16 (wide) string to a UTF-8 encoded string.
 *
 * @param utf16_string Pointer to a null-terminated UTF-16 wide string. May be `nullptr`.
 * @return std::string The UTF-8 encoded result. Returns an empty string if `utf16_string` is `nullptr` or if the conversion fails.
 */
std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  unsigned int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, nullptr, 0, nullptr, nullptr)
    -1; // remove the trailing null character
  int input_length = (int)wcslen(utf16_string);
  std::string utf8_string;
  if (target_length == 0 || target_length > utf8_string.max_size()) {
    return utf8_string;
  }
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      input_length, utf8_string.data(), target_length, nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}