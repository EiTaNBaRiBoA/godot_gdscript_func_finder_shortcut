@tool
extends EditorPlugin

var use_shift: bool = false ## Hold shift with page-up and page-down to scroll to funcs

## Editor setting path
const SCRIPT_USE_SHIFT: StringName = &"plugin/gdscript_func_finder/use_shift"


func _enter_tree() -> void:
	if ProjectSettings.has_setting(SCRIPT_USE_SHIFT):
		use_shift = ProjectSettings.get_setting(SCRIPT_USE_SHIFT, use_shift)
	else:
		ProjectSettings.set_setting(SCRIPT_USE_SHIFT, use_shift)
		ProjectSettings.set_initial_value(SCRIPT_USE_SHIFT, use_shift)
		ProjectSettings.set_as_basic(SCRIPT_USE_SHIFT, true)

	ProjectSettings.settings_changed.connect(sync_settings)


func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(sync_settings)


func sync_settings() -> void:
	use_shift = ProjectSettings.get_setting(SCRIPT_USE_SHIFT, use_shift)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Page Up
		if event.keycode == KEY_PAGEUP and event.pressed and (!use_shift or event.shift_pressed):
			var code_edit: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
			if code_edit.has_focus():
				move_prev_function(code_edit)
				get_viewport().set_input_as_handled()

		# Page down
		if event.keycode == KEY_PAGEDOWN and event.pressed and (!use_shift or event.shift_pressed):
			var code_edit: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
			if code_edit.has_focus():
				move_next_function(code_edit)
				get_viewport().set_input_as_handled()


func move_prev_function(code_edit: CodeEdit) -> void:
	var caret_line = code_edit.get_caret_line()
	var text_lines = code_edit.text.split("\n")

	# Search backward for the function definition
	for i in range(caret_line-1, -1, -1):
		var line = text_lines[i].strip_edges()
		if line.begins_with("func "):
			code_edit.set_caret_line(i)
			code_edit.set_caret_column(line.length())
			return


func move_next_function(code_edit: CodeEdit) -> void:
	var caret_line = code_edit.get_caret_line()
	var text_lines = code_edit.text.split("\n")

	# Search fowards for the function definition
	for i in range(caret_line+1, text_lines.size()):
		var line = text_lines[i].strip_edges()
		if line.begins_with("func "):
			code_edit.set_caret_line(i)
			code_edit.set_caret_column(line.length())
			return
