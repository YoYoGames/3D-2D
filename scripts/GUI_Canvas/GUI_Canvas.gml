/// @func GUI_Canvas([_props[, _children]])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Canvas(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Id.Surface}
	/// @readonly
	Surface = noone;

	/// @var {Real}
	ScrollX = _props[$ "ScrollX"] ?? 0;

	/// @var {Real}
	ScrollY = _props[$ "ScrollY"] ?? 0;

	/// @var {Real}
	/// @readonly
	ContentWidth = 0;

	/// @var {Real}
	/// @readonly
	ContentHeight = 0;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_white;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite");

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	static Widget_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _parentX = RealX + _paddingLeft;
		var _parentY = RealY + _paddingTop;
		var _parentWidth = RealWidth - _paddingLeft - (PaddingRight ?? Padding);
		var _parentHeight = RealHeight - _paddingTop - (PaddingBottom ?? Padding);
		var _scrollX = ScrollX;
		var _scrollY = ScrollY;

		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible)
				{
					ComputeRealSize(_parentWidth, _parentHeight);
					var _x = ((_parentWidth - RealWidth) * AnchorLeft) + (RealWidth * PivotLeft) + X;
					var _y = ((_parentHeight - RealHeight) * AnchorTop) + (RealHeight * PivotTop) + Y;
					SetProps({
						"RealX": round(_parentX + _x + _scrollX),
						"RealY": round(_parentY + _y + _scrollY),
					});
					Layout(_force);
				}
			}
		}

		if (array_length(Children) > 0)
		{
			var _bbox = GetInnerBoundingBox();
			SetProps({
				"ContentWidth": _bbox[2] - (RealX + ScrollX) + (PaddingRight ?? Padding),
				"ContentHeight": _bbox[3] - (RealY + ScrollY) + (PaddingBottom ?? Padding),
			});
			
		}
		else
		{
			SetProps({
				"ContentWidth": 0,
				"ContentHeight": 0,
			});
		}

		return self;
	};

	static GetBoundingBox = function (_dest=[RealX, RealY, RealX + RealWidth, RealY + RealHeight]) {
		gml_pragma("forceinline");
		if (Visible)
		{
			_dest[@ 0] = min(_dest[0], RealX);
			_dest[@ 1] = min(_dest[1], RealY);
			_dest[@ 2] = max(_dest[2], RealX + RealWidth);
			_dest[@ 3] = max(_dest[3], RealY + RealHeight);
		}
		return _dest;
	};

	static FindWidgetAt = function (_x, _y, _allowDisabled=true) {
		if (!Visible)
		{
			return undefined;
		}
		if ((!IsDisabled() || _allowDisabled)
			&& _x >= RealX && _x <= RealX + RealWidth
			&& _y >= RealY && _y <= RealY + RealHeight)
		{
			for (var i = array_length(Children) - 1; i >= 0; --i)
			{
				var _found = Children[i].FindWidgetAt(_x, _y, _allowDisabled);
				if (_found)
				{
					return _found;
				}
			}
			return self;
		}
		return undefined;
	};

	static Draw = function () {
		if (floor(RealWidth) <= 0 || floor(RealHeight) <= 0)
		{
			return self;
		}

		Surface = GUI_CheckSurface(Surface, RealWidth, RealHeight);

		gpu_push_state();
		gpu_set_colorwriteenable(true, true, true, false);
		surface_set_target(Surface);
		draw_clear(BackgroundColor);
		var _matrixWorld = matrix_get(matrix_world);
		if (BackgroundSprite != undefined)
		{
			matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				0, 0, RealWidth, RealHeight);
		}
		matrix_set(matrix_world, matrix_build(-RealX, -RealY, 0, 0, 0, 0, 1, 1, 1));
		DrawChildren();
		matrix_set(matrix_world, _matrixWorld);
		surface_reset_target();
		gpu_pop_state();

		draw_surface(Surface, RealX, RealY);

		return self;
	};

	static Widget_Destroy = Destroy;

	static Destroy = function () {
		Widget_Destroy();
		if (surface_exists(Surface))
		{
			surface_free(Surface);
		}
		return undefined;
	};
}
