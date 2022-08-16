/// @func GUI_ByteArrayToHex(_bytes)
///
/// @desc Converts an array of number between 0..255 into a string of
/// hexadecimal representations of each number.
///
/// @param {Array} _bytes The array with numbers.
///
/// @return {String} The resulting string.
function GUI_ByteArrayToHex(_bytes)
{
	var _str = "";
	var i = 0;
	repeat (array_length(_bytes))
	{
		_str += GUI_ByteToHex(_bytes[i++]);
	}
	return _str;
}

/// @func GUI_ByteToHex(_byte)
///
/// @desc Converts a number in range 0..255 into a hexadecimal representation.
///
/// @param {Real} _byte The number to convert.
///
/// @return {String} The hexadecimal representation.
function GUI_ByteToHex(_byte)
{
	gml_pragma("forceinline");
	return (GUI_NibbleToHex((_byte & 0xF0) >> 4) + GUI_NibbleToHex(_byte & 0xF));
}

/// @func GUI_NibbleToHex(_nibble)
///
/// @desc Converts a number in range 0..15 into its hexadecimal representation.
///
/// @param {Real} _nibble The number to convert.
///
/// @return {String} The hexadecimal representation.
function GUI_NibbleToHex(_nibble)
{
	gml_pragma("forceinline");
	static _nibbleToHex = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
	return _nibbleToHex[_nibble];
}

/// @func GUI_HexToNibble(_hex)
///
/// @desc Converts a hex char into a nibble.
///
/// @param {String} _hex The character to convert.
///
/// @return {Real} The parsed nibble on success or `NaN` on fail.
function GUI_HexToNibble(_hex)
{
	var _char = string_char_at(_hex, 1);
	_char = ord(string_upper(_char));
	if (_char >= ord("0") && _char <= ord("9"))
	{
		return _char - ord("0");
	}
	else if (_char >= ord("A") && _char <= ord("F"))
	{
		return 10 + _char - ord("A");
	}
	else
	{
		return NaN;
	}
}

/// @func GUI_HexToReal(_hex)
///
/// @desc Converts hex string into a number.
///
/// @param {String} _hex The hex string.
///
/// @return {Real} The parsed number on success or `NaN` on fail.
function GUI_HexToReal(_hex)
{
	var _real = 0;
	var _index = 1;
	repeat (string_length(_hex))
	{
		var _char = string_char_at(_hex, _index++);
		var _nibble = GUI_HexToNibble(_char);
		if (is_nan(_nibble))
		{
			return NaN;
		}
		_real = (_real << 4) | _nibble;
	}
	return _real;
}
