global.__stQuestionCallback = ds_map_create();

/// @func GUI_ShowQuestionAsync(_string, _callback)
///
/// @desc
///
/// @param {String} _string
/// @param {Function} _callback
function GUI_ShowQuestionAsync(_string, _callback)
{
	var _id = show_question_async(_string);
	global.__stQuestionCallback[? _id] = _callback;
}

/// @func GUI_ProcessQuestionCallbacks(_asyncLoad)
///
/// @desc
///
/// @param {Id.DsMap} _asyncLoad
function GUI_ProcessQuestionCallbacks(_asyncLoad)
{
	var _id = _asyncLoad[? "id"];
	if (ds_map_exists(global.__stQuestionCallback, _id))
	{
		if (_asyncLoad[? "status"])
		{
			global.__stQuestionCallback[? _id]();
		}
		ds_map_delete(global.__stQuestionCallback, _id);
	}
}
