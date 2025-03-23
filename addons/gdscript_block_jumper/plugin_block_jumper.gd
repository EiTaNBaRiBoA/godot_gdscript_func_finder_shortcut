@tool
extends EditorPlugin

var shift_move_space: bool:
	get:
		return ProjectSettings.get_setting(SCRIPT_SHIFT_USAGE, false)

## Editor setting path
const SCRIPT_SHIFT_USAGE: StringName = &"plugin/gdscript_block_jumper/shift_move_to_space_behavior"


func _enter_tree() -> void:
	if ProjectSettings.has_setting(SCRIPT_SHIFT_USAGE):
		shift_move_space = ProjectSettings.get_setting(SCRIPT_SHIFT_USAGE, shift_move_space)
	else:
		ProjectSettings.set_setting(SCRIPT_SHIFT_USAGE, shift_move_space)
		ProjectSettings.set_initial_value(SCRIPT_SHIFT_USAGE, shift_move_space)
		ProjectSettings.set_as_basic(SCRIPT_SHIFT_USAGE, true)

	ProjectSettings.settings_changed.connect(sync_settings)


func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(sync_settings)


func sync_settings() -> void:
	shift_move_space = ProjectSettings.get_setting(SCRIPT_SHIFT_USAGE, shift_move_space)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# Page Up
		if event.keycode == KEY_PAGEUP and event.pressed:
			var code_edit: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
			if code_edit.has_focus():
				if event.shift_pressed:
					var shift_action := move_prev_empty_line if shift_move_space else move_prev_function
					shift_action.call(code_edit)
				else:
					var normal_action := move_prev_function if shift_move_space else move_prev_empty_line
					normal_action.call(code_edit)
				get_viewport().set_input_as_handled()

		# Page down
		if event.keycode == KEY_PAGEDOWN and event.pressed:
			var code_edit: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
			if code_edit.has_focus():
				if event.shift_pressed:
					var shift_action := move_next_empty_line if shift_move_space else move_next_function
					shift_action.call(code_edit)
				else:
					var normal_action := move_next_function if shift_move_space else move_next_empty_line
					normal_action.call(code_edit)
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


func move_next_empty_line(code_edit: CodeEdit) -> void:
	var caret_line = code_edit.get_caret_line()
	var text_lines = code_edit.text.split("\n")
	var skip_next_empty = text_lines[caret_line].is_empty()

	# Search fowards for the function definition
	for i in range(caret_line+1, text_lines.size()):
		var line = text_lines[i].strip_edges()
		if skip_next_empty:
			if line.is_empty():
				continue
			else:
				skip_next_empty = false
				continue
		if line.is_empty():
			code_edit.set_caret_line(i)
			code_edit.set_caret_column(line.length())
			return


func move_prev_empty_line(code_edit: CodeEdit) -> void:
	var caret_line = code_edit.get_caret_line()
	var text_lines = code_edit.text.split("\n")
	var skip_next_empty = text_lines[caret_line].is_empty()

	# Search backward for the function definition
	for i in range(caret_line-1, -1, -1):
		var line = text_lines[i].strip_edges()
		if skip_next_empty:
			if line.is_empty():
				continue
			else:
				skip_next_empty = false
				continue
		if line.is_empty():
			code_edit.set_caret_line(i)
			code_edit.set_caret_column(line.length())
			return
