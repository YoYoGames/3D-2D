/// @func GUI_Event(_type[, _data])
///
/// @desc
///
/// @param {String} _type
/// @param {Any} [_data]
function GUI_Event(_type, _data=undefined) constructor
{
	/// @var {String}
	/// @readonly
	Type = _type;

	/// @var {Any}
	/// @readonly
	Data = _data;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	Target = undefined;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	TargetCurrent = undefined;

	/// @var {Bool}
	Bubble = true;
}
