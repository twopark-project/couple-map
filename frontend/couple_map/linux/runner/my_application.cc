#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
/**
 * @brief Shows the window containing the given Flutter view when the view's first frame is rendered.
 *
 * Displays the view's top-level GTK widget so the application window becomes visible once Flutter has produced its initial frame.
 *
 * @param view The FlView whose toplevel widget will be shown.
 */
static void first_frame_cb(MyApplication* self, FlView *view)
{
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

/**
 * @brief Activate the application by creating and configuring its main window and embedding the Flutter view.
 *
 * Creates a new top-level window for the application, chooses a header bar or traditional title bar
 * based on the windowing environment, sets the default window size and title, constructs an
 * FlDartProject with the stored Dart entrypoint arguments, creates an FlView with a black
 * background, and attaches the view to the window. The window is shown when the Flutter view
 * emits its first frame; Flutter plugins are registered and the view is given focus.
 *
 * @param application The GApplication instance to activate (expected to be a MyApplication).
 */
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "couple_map");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "couple_map");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000 for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb), self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

/**
 * @brief Handles the application's command-line invocation, stores Dart entrypoint arguments, registers and activates the application.
 *
 * Strips the program name from the provided argument vector and saves the remaining arguments
 * into the application's `dart_entrypoint_arguments`. Attempts to register the GApplication;
 * on failure sets `*exit_status` to 1 and logs a warning. On success activates the application
 * and sets `*exit_status` to 0.
 *
 * @param application The GApplication instance.
 * @param arguments Pointer to the argument vector; the first element (binary name) is removed and the remainder is stored.
 * @param exit_status Output location for the process exit status (0 on success, 1 on registration failure).
 * @return gboolean `TRUE` indicating the command line was handled.
 */
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

/**
 * @brief Perform application-specific startup initialization.
 *
 * Chains any required startup actions to the parent GApplication startup
 * implementation.
 *
 * @param application The GApplication instance being started.
 */
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

/**
 * @brief Perform application shutdown tasks and chain to the parent implementation.
 *
 * Runs any MyApplication-specific shutdown actions, then invokes the parent
 * GApplication::shutdown implementation to complete shutdown processing.
 */
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

/**
 * @brief Release resources owned by a MyApplication instance before finalization.
 *
 * Frees the stored `dart_entrypoint_arguments` array and delegates to the parent
 * class's `dispose` implementation.
 *
 * @param object The GObject instance being disposed (a `MyApplication`).
 */
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

/**
 * @brief Initializes the MyApplicationClass by overriding its GApplication and GObject virtual methods.
 *
 * Sets the class handlers used for application activation, command-line handling, startup, shutdown,
 * and instance disposal.
 *
 * @param klass The MyApplicationClass being initialized.
 */
static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

/**
 * @brief Instance initializer for MyApplication.
 *
 * Performs per-instance initialization for a MyApplication object.
 *
 * @param self The MyApplication instance being initialized.
 */
static void my_application_init(MyApplication* self) {}

/**
 * @brief Create a new MyApplication instance configured for desktop integration.
 *
 * Creates and returns a MyApplication initialized with the application ID
 * and non-unique application flags. Also sets the process program name to
 * APPLICATION_ID to improve integration with desktop environments and .desktop files.
 *
 * @return MyApplication* Newly allocated MyApplication with "application-id" set to
 *         APPLICATION_ID and "flags" set to G_APPLICATION_NON_UNIQUE.
 */
MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}