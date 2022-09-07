#macro GUI_LINE_HEIGHT 24

#macro GUI_FONT_HEIGHT string_height("Q")

/// @func GUI_StructGet(_struct, _key[, _default])
///
/// @desc
///
/// @param {Struct} _struct
/// @param {String} _key
/// @param {Mixed} _default
///
/// @return {Mixed}
function GUI_StructGet(_struct, _key, _default=undefined)
{
	gml_pragma("forceinline");
	return variable_struct_exists(_struct, _key) ? _struct[$ _key] : _default;
}

function GUI_StructExtend(_dest, _src1)
{
	for (var a = 1; a < argument_count; ++a)
	{
		var _src = argument[a];
		var _names = variable_struct_get_names(_src);
		for (var n = array_length(_names) - 1; n >= 0; --n)
		{
			var _name = _names[n];
			_dest[$ _name] = _src[$ _name];
		}
	}
	return _dest;
}

function GUI_DrawRectangle(_x, _y, _width, _height, _color=c_white, _alpha=1.0)
{
	gml_pragma("forceinline");
	draw_sprite_stretched_ext(GUI_SprRectangle, 0, _x, _y, _width, _height, _color, _alpha);
}

function GUI_DrawText(_x, _y, _string, _color=c_black, _alpha=1.0)
{
	gml_pragma("forceinline");
	draw_text_color(_x, _y, _string, _color, _color, _color, _color, _alpha);
}

function GUI_GetTextPartLeft(_string, _width)
{
	var _stringLength = string_length(_string);
	while (string_width(_string) > _width)
	{
		_string = string_copy(_string, 1, --_stringLength);
		if (_string == "")
		{
			break;
		}
	}
	return _string;
}

function GUI_DrawTextPartLeft(_x, _y, _string, _width, _color=c_black, _alpha=1.0)
{
	gml_pragma("forceinline");
	draw_text_color(_x, _y, GUI_GetTextPartLeft(_string, _width), _color, _color, _color, _color, _alpha);
}

function GUI_GetTextPartRight(_string, _width)
{
	while (string_width(_string) > _width)
	{
		_string = string_delete(_string, 1, 1);
		if (_string == "")
		{
			break;
		}
	}
	return _string;
}

function GUI_DrawTextPartRight(_x, _y, _string, _width, _color=c_black, _alpha=1.0)
{
	gml_pragma("forceinline");
	draw_text_color(_x, _y, GUI_GetTextPartRight(_string, _width), _color, _color, _color, _color, _alpha);
}

function GUI_DrawShadow(_x, _y, _width, _height, _color=c_black, _alpha=0.4)
{
	var _spriteOffset = -13;
	draw_sprite_stretched_ext(
		GUI_SprShadow, 0,
		_x + _spriteOffset,
		_y + 3 + _spriteOffset,
		_width - _spriteOffset * 2,
		_height - 1 - _spriteOffset * 2,
		_color, _alpha);
}

function GUI_CheckSurface(_surface, _width, _height)
{
	if (!surface_exists(_surface))
	{
		_surface = surface_create(_width, _height);
	}
	else if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		surface_resize(_surface, _width, _height);
	}
	return _surface;
}

/// @func GUI_ParseSize(_value, _dest[, _allowAuto])
///
/// @desc
///
/// @param {String/Real} _value
/// @param {Array} _dest
/// @param {Bool} [_allowAuto]
///
/// @throws {String}
function GUI_ParseSize(_value, _dest, _allowAuto=true)
{
	if (is_real(_value))
	{
		_dest[@ 0] = _value;
		_dest[@ 1] = "px";
		return;
	}

	if (_value == "auto")
	{
		if (!_allowAuto)
		{
			throw "'auto' not allowed!";
		}
		_dest[@ 0] = "auto";
		_dest[@ 1] = "";
		return;
	}

	var _stateSign = 0;
	var _stateInteger = 1;
	var _stateDecimal = 2;
	var _stateUnit = 3;
	var _state = _stateSign;

	var _sign = 1;
	var _before = ""
	var _number = "";
	var _unit = "";

	var _length = string_length(_value);
	var _index = 1;

	while (_index <= _length)
	{
		var _char = string_char_at(_value, _index++);

		switch (_state)
		{
		case _stateSign:
			if (_char == "+")
			{
			}
			else if (_char == "-")
			{
				_sign *= -1;
			}
			else if (string_digits(_char) == _char)
			{
				_state = _stateInteger;
				--_index;
			}
			else if (_char == ".")
			{
				_before = "0";
				_number += ".";
				_state = _stateDecimal;
			}
			else
			{
				throw "Unexpected symbol '" + _char + "'!";
			}
			break;

		case _stateInteger:
			if (string_digits(_char) == _char)
			{
				_number += _char;
			}
			else if (_char == ".")
			{
				_number += _char;
				_state = _stateDecimal;
			}
			else
			{
				_state = _stateUnit;
				--_index;
			}
			break;

		case _stateDecimal:
			if (string_digits(_char) == _char)
			{
				_number += _char;
			}
			else
			{
				_state = _stateUnit;
				--_index;
			}
			break;

		case _stateUnit:
			_unit += _char;
			break;
		}
	}

	if (_number == ".")
	{
		throw "Invalid number '.'!";
	}

	if (_unit != ""
		&& _unit != "px"
		&& _unit != "%")
	{
		throw "Invalid unit '" + _unit + "'!";
	}

	_dest[@ 0] = _sign * real(_before + _number);
	_dest[@ 1] = (_unit == "") ? "px" : _unit;
}

/// @func GUI_RealToString(_real[, _dec])
///
/// @desc Converts a number into a string.
///
/// @param {Real} _real The number to convert.
/// @param {Real} [_dec] Maximum number of decimal places. Default value is 4.
///
/// @return {String} The created string.
function GUI_RealToString(_real, _dec=4)
{
	var _string = string_format(_real, -1, _dec);
	var _stringLength = string_length(_string);

	repeat (_stringLength)
	{
		var _char = string_char_at(_string, _stringLength);

		if (_char == "0")
		{
			--_stringLength;
			continue;
		}

		if (_char == ".")
		{
			--_stringLength;
		}

		break;
	}

	return string_copy(_string, 1, _stringLength);
}
