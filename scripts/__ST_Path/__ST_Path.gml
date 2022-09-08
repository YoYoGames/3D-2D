/// @macro {String}
#macro __ST_PATH_SEPARATOR ((os_type == os_windows) ? "\\" : "/")

/// @macro {String}
#macro __ST_PATH_CURRENT "."

/// @macro {String}
#macro __ST_PATH_PARENT ".."

/// @func ST_PathNormalize(_path)
///
/// @desc
///
/// @param {String} _path
///
/// @return {String}
function ST_PathNormalize(_path)
{
	gml_pragma("forceinline");
	return string_replace_all(_path,
		(os_type == os_windows) ? "/" : "\\", __ST_PATH_SEPARATOR);
}

/// @func ST_PathIsRelative(_path)
///
/// @desc Checks if a path is relative.
///
/// @param {String} _path The path to check.
///
/// @return {Bool} Returns `true` if the path is relative.
function ST_PathIsRelative(_path)
{
	gml_pragma("forceinline");
	_path = ST_PathNormalize(_path);
	return (ST_StringStartsWith(_path, __ST_PATH_CURRENT + __ST_PATH_SEPARATOR)
		|| ST_StringStartsWith(_path, __ST_PATH_PARENT + __ST_PATH_SEPARATOR));
}


/// @func ST_PathIsAbsolute(_path)
///
/// @desc Checks if a path is absolute.
///
/// @param {String} _path The path to check.
///
/// @return {Bool} Returns `true` if the path is absolute.
function ST_PathIsAbsolute(_path)
{
	gml_pragma("forceinline");
	return !ST_PathIsRelative(_path);
}

/// @func ST_PathGetRelative(_path[, _start])
///
/// @desc Retrieves a relative version of a path.
///
/// @param {String} _path The path to get a relative version of. Must be
/// absolute!
/// @param {String} [_start] Which path should it be relative to. Must be
/// absolute! Defaults to the working directory.
///
/// @return {String} The relative path.
///
/// @note If given paths are not on the same drive then an unmodified path is
/// returned!
function ST_PathGetRelative(_path, _start=working_directory)
{
	_path = ST_PathNormalize(_path);

	var _pathExploded = [];
	var _pathExplodedSize = ST_StringExplode(_path, __ST_PATH_SEPARATOR, _pathExploded);

	var _startExploded = [];
	var _startExplodedSize = ST_StringExplode(_start, __ST_PATH_SEPARATOR, _startExploded);

	if (os_type == os_windows
		&& _pathExploded[0] != _startExploded[0])
	{
		return _path;
	}

	var _pathRelative = [];
	var _levelStart = 0;
	repeat (min(_startExplodedSize, _pathExplodedSize))
	{
		if (_startExploded[_levelStart] != _pathExploded[_levelStart])
		{
			break;
		}
		++_levelStart;
	}

	var _levelEnd = _pathExplodedSize;
	var _levelCurrent = _startExplodedSize;

	if (_levelCurrent > _levelStart)
	{
		while (_levelCurrent > _levelStart)
		{
			array_push(_pathRelative, __ST_PATH_PARENT);
			--_levelCurrent;
		}
	}
	else
	{
		array_push(_pathRelative, __ST_PATH_CURRENT);
	}

	while (_levelCurrent < _levelEnd)
	{
		array_push(_pathRelative, _pathExploded[_levelCurrent++]);
	}

	return ST_StringJoinArray(__ST_PATH_SEPARATOR, _pathRelative);
}

/// @func ST_PathGetAbsolute(_path[, _start])
///
/// @desc Retrieves an absolute version of a path.
///
/// @param {String} _path The relative path to turn into absolute.
/// @param {String} [_start] Which path is it relative to. Must be absolute!
/// Defaults to the working directory.
///
/// @return {String} The absolute path.
///
/// @note If the path is already absolute then an unmodified path is returned.
function ST_PathGetAbsolute(_path, _start=working_directory)
{
	_path = ST_PathNormalize(_path);

	if (ST_PathIsAbsolute(_path))
	{
		return _path;
	}

	var _pathExploded = [];
	var _pathExplodedSize = ST_StringExplode(_path, __ST_PATH_SEPARATOR, _pathExploded);

	var _startExploded = [];
	var _startExplodedSize = ST_StringExplode(_start, __ST_PATH_SEPARATOR, _startExploded);

	var _pathRelative = [];
	array_copy(_pathRelative, 0, _startExploded, 0, _startExplodedSize);

	var i = _startExplodedSize - 1;
	var j = 0;

	repeat (_pathExplodedSize)
	{
		var _str = _pathExploded[j++];

		switch (_str)
		{
		case __ST_PATH_CURRENT:
			break;

		case __ST_PATH_PARENT:
			array_delete(_pathRelative, i--, 1);
			break;

		default:
			array_push(_pathRelative, _str);
			break;
		}
	}

	return ST_StringJoinArray(__ST_PATH_SEPARATOR, _pathRelative);
}
