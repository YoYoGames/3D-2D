// Set FileDialog Environment Variables
environment_set_variable("IMGUI_DIALOG_WIDTH", "800");
environment_set_variable("IMGUI_DIALOG_HEIGHT", "400");
environment_set_variable("IMGUI_DIALOG_PARENT", string(int64(window_handle())));
environment_set_variable("IMGUI_FONT_PATH", working_directory + "data/fonts");
environment_set_variable("IMGUI_FONT_SIZE", "24");
environment_set_variable("IMGUI_ALL_FILES", "All Files");
IfdLoadFonts();
