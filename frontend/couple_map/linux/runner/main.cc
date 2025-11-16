#include "my_application.h"

/**
 * @brief Application entry point that creates a MyApplication instance and runs it.
 *
 * Creates the application, hands control to GLib's application run loop, and returns the application's exit status.
 *
 * @param argc Number of command-line arguments.
 * @param argv Null-terminated array of command-line argument strings.
 * @return int Exit status returned by the application's run loop.
 */
int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}