/// @func GUI_Text(_text[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Text(_text, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String}
	Text = _text;

	/// @var {String}
	TextReal = Text;

	/// @var {String}
	/// Possible options are "clip", "ellipsis" or `undefined`.
	/// Default value is "clip".
	TextOverflow = _props[$ "TextOverflow"] ?? "clip";

	/// @var {Real}
	TextAlign = _props[$ "TextAlign"] ?? 0.0;

	/// @var {Real}
	VerticalAlign = _props[$ "VerticalAlign"] ?? 0.5;

	SetSize(
		_props[$ "Width"] ?? "auto",
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Constant.Color}
	BackgroundColor = GUI_StructGet(_props, "BackgroundColor");

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	static Widget_Layout = Layout;

	static Layout = function (_force=false) {
		Widget_Layout(_force);

		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingRight = PaddingRight ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _paddingBottom = PaddingBottom ?? Padding;
		var _textReal = Text;

		if (Width == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "row"))
		{
			var _realWidth = RealWidth;
			_realWidth = _paddingLeft + string_width(_textReal) + _paddingRight;
			_realWidth = GetClampedRealWidth(_realWidth, Parent.RealWidth);
			SetProps({ RealWidth: _realWidth });
		}
		else
		{
			var _availableWidth = RealWidth - _paddingLeft - (PaddingRight ?? Padding);

			if (TextOverflow == "ellipsis")
			{
				if (string_width(_textReal) > _availableWidth)
				{
					var _stringLength = string_length(_textReal);
					while (string_width(_textReal + "...") > _availableWidth && _stringLength > 0)
					{
						_textReal = string_delete(_textReal, _stringLength--, 1);
					}
					_textReal += "...";
				}
			}

			if (TextOverflow != undefined)
			{
				var _stringLength = string_length(_textReal);
				while (string_width(_textReal) > _availableWidth && _stringLength > 0)
				{
					_textReal = string_delete(_textReal, _stringLength--, 1);
				}
			}
		}

		if (Height == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "column"))
		{
			var _realHeight = RealHeight;
			_realHeight = _paddingTop + string_height(_textReal) + _paddingBottom;
			_realHeight = GetClampedRealHeight(_realHeight, Parent.RealHeight);
			SetProps({ RealHeight: _realHeight });
		}

		SetProps({ TextReal: _textReal });

		return self;
	};

	static Draw = function () {
		DrawBackground();

		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _availableWidth = RealWidth - _paddingLeft - (PaddingRight ?? Padding);
		var _availableHeight = RealHeight - _paddingTop - (PaddingBottom ?? Padding);

		draw_text_color(
			floor(RealX + _paddingLeft + ((_availableWidth - string_width(TextReal)) * TextAlign)),
			floor(RealY + _paddingTop + ((_availableHeight - string_height(TextReal)) * VerticalAlign)),
			TextReal, Color, Color, Color, Color, 1.0);

		DrawChildren();

		return self;
	};
}
