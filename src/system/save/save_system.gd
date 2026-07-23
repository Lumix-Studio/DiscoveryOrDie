extends RefCounted
class_name SaveSystem


func save_resource(resource: SavePattern, path:String) -> void:
	ResourceSaver.save(resource, path)

func load_resource(path:String) -> SavePattern:
	if FileAccess.file_exists(path):
		return ResourceLoader.load(path)
	return SavePattern.new()
