class_name JsonLoaderSingleton
extends Node

func load_json(path: String, fallback: Variant = null) -> Variant:
	if not FileAccess.file_exists(path):
		return fallback
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return fallback
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	return fallback if parsed == null else parsed
