/// @func GUI_Input(_value[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String/Real} _value
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Input(_value, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String/Real}
	Value = _value;

	/// @var {Bool}
	/// @readonly
	IsReal = is_real(Value);

	/// @var {String}
	Before = _props[$ "Before"] ?? "";

	/// @var {String}
	After = _props[$ "After"] ?? "";

	Draggable = _props[$ "Draggable"] ?? IsReal;

	SetSize(
		_props[$ "Width"] ?? 200,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	/// @var {Bool}
	WholeNumbers = _props[$ "WholeNumbers"] ?? false;

	/// @var {Bool}
	Min = GUI_StructGet(_props, "Min");

	/// @var {Bool}
	Max = GUI_StructGet(_props, "Max");

	/// @var {Bool}
	Step = _props[$ "Step"] ?? 1.0;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Constant.Color}
	ColorDisabled = _props[$ "ColorDisabled"] ?? c_dkgray;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite", GUI_SprInput);

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	/// @var {Constant.Color}
	BeamColor = _props[$ "BeamColor"] ?? c_white;

	/// @var {Real}
	/// @ignore
	BeamTimer = 0.0;

	/// @var {Real}
	/// @ignore
	EditFrom = 1;

	/// @var {Real}
	/// @ignore
	EditTo = 1;

	/// @var {String}
	/// @ignore
	InputString = "";

	/// @var {Real} The index from which we start drawing the input text.
	/// @ignore
	IndexDrawStart = 1;

	OnPress = function () {
		if (!Draggable)
		{
			Focus();
		}
	};

	OnClick = function () {
		if (Draggable)
		{
			Focus();
		}
	};

	OnDoubleClick = function () {
		if (IsFocused())
		{
			EditFrom = 1;
			EditTo = string_length(InputString) + 1;
			IndexDrawStart = 1;
		}
	};

	OnFocus = function () {
		BeamTimer = 1.0;
		InputString = GUI_RealToString(Value);
		EditFrom = string_length(InputString) + 1;
		EditTo = EditFrom;
		IndexDrawStart = 1;
		keyboard_string = "";
	};

	OnBlur = function () {
		Change(InputString);
	};

	OnDragStart = function () {
		Blur();
		if (Root && IsReal)
		{
			Root.LockCursor();
		}
	};

	OnDrag = function (_self, _diffX, _diffY) {
		if (IsReal)
		{
			var _step = Step;
			if (keyboard_check(vk_shift))
			{
				_step += 10.0;
			}
			else if (keyboard_check(vk_control))
			{
				_step /= 10.0;
			}
			Change(Value + (_diffX * _step));
		}
	};

	OnDragEnd = function () {
		if (Root && IsReal)
		{
			Root.UnlockCursor();
		}
	};

	/// @func SetValue(_value)
	///
	/// @desc
	///
	/// @param {String/Real} _value
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static SetValue = function (_value) {
		if (IsReal)
		{
			try
			{
				_value = real(_value);
				if (WholeNumbers)
				{
					_value = floor(_value);
				}
				if (Min != undefined)
				{
					_value = max(_value, Min);
				}
				if (Max != undefined)
				{
					_value = min(_value, Max);
				}
			}
			catch (_ignore)
			{
				_value = Value;
			}
		}
		SetProps({
			"Value": _value,
		});
		return self;
	};

	/// @func Change(_value)
	///
	/// @desc
	///
	/// @param {String/Real} _value
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static Change = function (_value) {
		gml_pragma("forceinline");
		var _valueOld = Value;
		SetValue(_value);
		if (Value != _valueOld && OnChange)
		{
			OnChange(Value, _valueOld);
		}
		return self;
	};

	/// @func DeleteSelected()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static DeleteSelected = function () {
		if (EditFrom != EditTo)
		{
			var _minIndex = min(EditFrom, EditTo);
			InputString = string_delete(InputString,
				_minIndex, abs(EditFrom - EditTo));
			EditFrom = _minIndex;
			EditTo = _minIndex;
		}
		return self;
	};

	/// @func CopySelected()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static CopySelected = function () {
		if (EditFrom != EditTo)
		{
			clipboard_set_text(string_copy(InputString,
				min(EditFrom, EditTo), abs(EditFrom - EditTo)));
		}
		return self;
	};

	/// @func CopySelected()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static PasteClipboard = function () {
		if (clipboard_has_text())
		{
			// Delete selected part
			if (EditFrom != EditTo)
			{
				DeleteSelected();
			}
			// Insert string
			InputString = string_insert(clipboard_get_text(),
				InputString, EditFrom);
			EditFrom += string_length(clipboard_get_text());
			EditTo = EditFrom;
		}
		return self;
	};

	/// @func CutSelected()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static CutSelected = function () {
		if (EditFrom != EditTo)
		{
			clipboard_set_text(string_copy(InputString,
				min(EditFrom, EditTo),
				abs(EditFrom - EditTo)));
			DeleteSelected();
		}
		return self;
	};

	/// @func SelectAll()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Input} Returns `self`.
	static SelectAll = function () {
		EditFrom = 1;
		EditTo = string_length(InputString) + 1;
		return self;
	};

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();

		if (IsFocused())
		{
			var _inputStringLength = string_length(InputString);

			// Multitype
			static _enableRepeat = false;
			var _inputRepeat = false;

			if (keyboard_check_pressed(vk_anykey))
			{
				_enableRepeat = true;
				_inputRepeat = true;
				BeamTimer = current_time;
			}

			if (current_time > BeamTimer + 450)
			{
				_inputRepeat = _enableRepeat;
				_enableRepeat = !_enableRepeat;
			}

			// Type
			var _keyboardStringLength = string_length(keyboard_string);

			if (_keyboardStringLength > 0)
			{
				// Delete selected part
				if (EditFrom != EditTo)
				{
					DeleteSelected();
				}

				// Insert string
				InputString = string_insert(keyboard_string, InputString, EditFrom);
				EditFrom += _keyboardStringLength;
				EditTo = EditFrom;
				keyboard_string = "";
			}

			// Backspace
			if (keyboard_check(vk_backspace) && _inputRepeat)
			{
				if (EditFrom == EditTo)
				{
					if (keyboard_check(vk_control))
					{
						InputString = string_delete(InputString, 1, EditFrom - 1);
						EditFrom = 1;
						EditTo = 1;
					}
					else
					{
						InputString = string_delete(InputString, EditFrom - 1, 1);
						EditFrom = max(EditFrom - 1, 1);
						EditTo = EditFrom;
					}
				}
				else
				{
					DeleteSelected();
				}
			}
			else if (keyboard_check(vk_delete) && _inputRepeat)
			{
				// Delete
				if (EditFrom != EditTo)
				{
					DeleteSelected();
				}
				else
				{
					InputString = string_delete(InputString, EditFrom,
						keyboard_check(vk_control) ? (_inputStringLength - EditFrom + 1) : 1);
				}
			}

			// Update string length
			_inputStringLength = string_length(InputString);

			// Control
			if (keyboard_check(vk_control))
			{
				if (keyboard_check_pressed(ord("A")))
				{
					SelectAll();
				}
				else if (keyboard_check_pressed(ord("D")))
				{
					DeleteSelected();
				}
				else if (keyboard_check_pressed(ord("X")))
				{
					CutSelected();
				}
				else if (keyboard_check_pressed(ord("C")))
				{
					CopySelected();
				}
				else if (keyboard_check(ord("V")) && _inputRepeat)
				{
					PasteClipboard();
					_inputStringLength = string_length(InputString);
				}
			}

			// Arrows
			if (keyboard_check(vk_left) && _inputRepeat)
			{
				EditTo = max(keyboard_check(vk_control) ? 1 : (EditTo - 1), 1);

				if (!keyboard_check(vk_shift))
				{
					EditFrom = EditTo;
				}
			}
			else if (keyboard_check(vk_right) && _inputRepeat)
			{
				EditTo = min(
					(keyboard_check(vk_control) ? _inputStringLength : EditTo) + 1,
					_inputStringLength + 1);

				if (!keyboard_check(vk_shift))
				{
					EditFrom = EditTo;
				}
			}

			// Home/end
			if (keyboard_check_pressed(vk_home))
			{
				EditTo = 1;

				if (!keyboard_check(vk_shift))
				{
					EditFrom = EditTo;
				}
			}
			else if (keyboard_check_pressed(vk_end))
			{
				EditTo = _inputStringLength + 1;

				if (!keyboard_check(vk_shift))
				{
					EditFrom = EditTo;
				}
			}

			// Blur
			if (keyboard_check_pressed(vk_escape))
			{
				Blur();
			}

			if (keyboard_check_pressed(vk_enter)
				|| (mouse_check_button_pressed(mb_left) && !IsMouseOver()))
			{
				Blur();
			}
		}

		if (IsMouseOver())
		{
			if (!Draggable || IsFocused())
			{
				Root.Cursor = cr_beam;
			}
			else if (Draggable && !Root.MouseLocked)
			{
				Root.Cursor = cr_size_we;
			}
		}

		return self;
	};

	static Draw = function () {
		////////////////////////////////////////////////////////////////////////
		// Background
		if (BackgroundSprite != undefined)
		{
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
		}

		////////////////////////////////////////////////////////////////////////
		// Text
		var _inputString = IsFocused() ? InputString : GUI_RealToString(Value);
		var _string = Before + _inputString + After;
		var _stringLength = string_length(_string);
		IndexDrawStart = clamp(IndexDrawStart, 1, _stringLength + 1);
		var _textOffset = 4;
		var _textX = RealX + _textOffset;
		var _textMaxX = RealX + RealWidth - _textOffset;
		var _textY = RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5);

		var _beamFromX;
		var _beamToX;
		var _beamWidth = 2;

		if (IsFocused())
		{
			// TODO: Cleanup

			// Move window based on beam position
			_beamFromX = _textX + string_width(Before + string_copy(_inputString, 1, EditFrom - 1));
			_beamToX = _textX + string_width(Before + string_copy(_inputString, 1, EditTo - 1));
			var _drawStartX = _textX + string_width(string_copy(_string, 1, IndexDrawStart - 1));

			while (_beamToX + _beamWidth >= _drawStartX + RealWidth - _textOffset)
			{
				++IndexDrawStart;
				if (IndexDrawStart > _stringLength + 1)
				{
					IndexDrawStart = _stringLength + 1;
					break;
				}
				_drawStartX = _textX + string_width(string_copy(_string, 1, IndexDrawStart - 1));
			}

			while (_beamToX + _beamWidth < _drawStartX)
			{
				--IndexDrawStart;
				if (IndexDrawStart < 1)
				{
					IndexDrawStart = 1;
					break;
				}
				_drawStartX = _textX + string_width(string_copy(_string, 1, IndexDrawStart - 1));
			}

			// Delete from the start
			var _portionToDelete = string_copy(_string, 1, IndexDrawStart - 1);
			var _widthToDelete = string_width(_portionToDelete);
			_string = string_delete(_string, 1, IndexDrawStart - 1);
			_beamFromX -= _widthToDelete;
			_beamToX -= _widthToDelete;

			// Delete from the end
			var __stringWidth = string_width(_string);
			var __stringWidthMax = RealWidth - (_textOffset * 2);
			var __stringLength = string_length(_string);

			while (__stringWidth > __stringWidthMax && _string != "")
			{
				__stringWidth -= string_width(string_char_at(_string, __stringLength));
				_string = string_delete(_string, __stringLength--, 1);
			}

			// Control beam position
			if (mouse_check_button(mb_left))
			{
				var _beamX = _beamToX;
				var _index = EditTo;
				var _stringLength = string_length(_inputString);
				var _charWidth = string_width(string_char_at(_inputString, _index));

				while (window_mouse_get_x() > _beamX)
				{
					if (mouse_check_button_pressed(mb_left))
					{
						EditFrom = _index;
					}
					EditTo = _index;
					_beamX += _charWidth;
					if (++_index > _stringLength + 1)
					{
						break;
					}
					_charWidth = string_width(string_char_at(_inputString, _index));
				}

				while (window_mouse_get_x() < _beamX)
				{
					if (mouse_check_button_pressed(mb_left))
					{
						EditFrom = _index;
					}
					EditTo = _index;
					_beamX -= _charWidth;
					if (--_index < 1)
					{
						break;
					}
					_charWidth = string_width(string_char_at(_inputString, _index));
				}
			}
		}
		else
		{
			// Show the end of the string when the input is not selected
			while (string_width(_string) > RealWidth - _textOffset * 2)
			{
				_string = string_delete(_string, 1, 1);
				if (_string == "")
				{
					break;
				}
			}
		}

		var _color = IsDisabled() ? ColorDisabled : Color;
		draw_text_color(_textX, _textY, _string, _color, _color, _color, _color, 1.0);

		////////////////////////////////////////////////////////////////////////
		// Draw beam
		if (IsFocused())
		{
			if (_beamFromX == _beamToX)
			{
				if (mouse_check_button(mb_left)
					|| keyboard_check(vk_anykey)
					|| dsin((current_time - BeamTimer) * 0.45) > 0.0)
				{
					GUI_DrawRectangle(_beamFromX, _textY + 1, _beamWidth, GUI_FONT_HEIGHT - 2, BeamColor);
				}
			}
			else
			{
				var _beamMinX = clamp(min(_beamFromX, _beamToX), _textX, _textMaxX);
				var _beamMaxX = clamp(max(_beamFromX, _beamToX), _textX, _textMaxX);
				GUI_DrawRectangle(_beamMinX, _textY + 1, _beamMaxX - _beamMinX, GUI_FONT_HEIGHT - 2, c_aqua, 0.3);
			}
		}

		DrawChildren();

		return self;
	};
}
