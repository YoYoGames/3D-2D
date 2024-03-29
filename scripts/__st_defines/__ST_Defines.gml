/// @macro {Real}
#macro ST_VERSION_MAJOR 0

/// @macro {Real}
#macro ST_VERSION_MINOR 1

/// @macro {Real}
#macro ST_VERSION_PATCH 5

/// @macro {String}
#macro ST_VERSION_STRING \
	("v" + \
	string(ST_VERSION_MAJOR) + "." + \
	string(ST_VERSION_MINOR) + "."  + \
	string(ST_VERSION_PATCH))

/// @macro {String}
#macro ST_FILTER_MODEL "Model Files|*.fbx;*.dae;*.gltf;*.glb;*.obj|" \
	+ "FBX|*.fbx|" \
	+ "COLLADA|*.dae|" \
	+ "glTF|*.gltf;*.glb|" \
	+ "OBJ|*.obj"

/// @macro {String}
#macro ST_FILTER_TEXTURE "Image Files|*.png;*.jpg;*.jpeg;"

/// @macro {String}
#macro ST_FILTER_SAVE "Save Files|*.json"
