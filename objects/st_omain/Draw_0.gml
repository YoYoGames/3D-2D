////////////////////////////////////////////////////////////////////////////////
// Render animation previews
if (Asset
	&& Asset.IsAnimated
	&& TaskQueue.BlockingTaskCount == 0)
{
	var _animationCount = array_length(Asset.Animations);

	if (Asset.AnimationsPreview == undefined)
	{
		Asset.AnimationsPreview = array_create(_animationCount, undefined);
		RenderPreviewAnimation = 0;
	}

	for (var i = 0; i < _animationCount; ++i)
	{
		var _animation = Asset.Animations[i];
		var _animationDuration = _animation.Duration;
		if (Asset.AnimationsPreview[i] == undefined)
		{
			Asset.AnimationsPreview[@ i] = array_create(_animationDuration, noone);
			RenderPreviewFrame = 0;
		}
	}

	repeat (4) // TODO: Make configurable
	{
		var i = RenderPreviewAnimation;
		var j = RenderPreviewFrame;

		var _animation = Asset.Animations[i];
		var _animationDuration = _animation.Duration;

		var _width = 84;
		var _height = 84;
		var _asset = Asset;
		var _animationIndex = i;
		var _frame = j;
		var _surface = bbmod_surface_check(
			Asset.AnimationsPreview[_animationIndex][_frame], _width, _height);

		with (AssetRenderer)
		{
			UpdateCamera();
			var _matrix = new BBMOD_Matrix()
				.Scale(Scale, Scale, Scale)
				.RotateEuler(Rotation)
				.Translate(Position);
			surface_set_target(_surface);
			draw_clear_alpha(BackgroundColor, BackgroundAlpha);
			Camera.apply();
			if (_animationIndex != undefined)
			{
				_asset.DrawAnimationFrame(_animationIndex, _frame, _matrix);
			}
			else
			{
				_asset.Draw(_matrix, _asset.GetTransform(true));
			}
			surface_reset_target();
		}

		Asset.AnimationsPreview[_animationIndex][@ _frame] = _surface;

		++RenderPreviewFrame;
		if (RenderPreviewFrame >= _animationDuration)
		{
			RenderPreviewFrame = 0;
			++RenderPreviewAnimation;
			if (RenderPreviewAnimation >= _animationCount)
			{
				RenderPreviewAnimation = 0;
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Render material previews
var _assets = [];

if (Asset)
{
	array_push(_assets, Asset);
	for (var i = array_length(Asset.Attachments) - 1; i >= 0; --i)
	{
		array_push(_assets, Asset.Attachments[i]);
	}
}

for (var j = array_length(_assets) - 1; j >= 0; --j)
{
	var _asset = _assets[j];
	var _size = 128;

	if (_asset.MaterialsPreview == undefined)
	{
		_asset.MaterialsPreview = array_create(_asset.Model.MaterialCount, noone);
	}

	for (var i = 0; i < _asset.Model.MaterialCount; ++i)
	{
		MaterialBall.Materials[0].BaseOpacity = _asset.Materials[i].BaseOpacity;
		MaterialBall.Materials[0].BaseOpacityMultiplier =
			_asset.Materials[i].BaseOpacityMultiplier.Clone();

		var _surface = bbmod_surface_check(_asset.MaterialsPreview[i], _size, _size);

		surface_set_target(_surface);
		draw_clear_alpha(c_black, 0);
		MaterialPreviewCamera.apply();
		bbmod_material_reset();
		MaterialBall.submit();
		bbmod_material_reset();
		surface_reset_target();

		_asset.MaterialsPreview[@ i] = _surface;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// Render scene
//
draw_clear_alpha(#252525, 0);
Camera.apply();

with (ST_OAttachment)
{
	bbmod_set_instance_id(id);
	if (Asset && Asset.Visible)
	{
		Asset.Render();
	}
}
with (ST_OAsset)
{
	bbmod_set_instance_id(id);
	if (Asset && Asset.Visible)
	{
		Asset.Render();
	}
}

global.stMaterialHighlight = true;
Renderer.render();
global.stMaterialHighlight = false;

////////////////////////////////////////////////////////////////////////////////
// Grid

// TODO: Use a shader?
Camera.apply();
gpu_push_state();
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
var _scale = power(10, floor(log10(max(Camera.Zoom - 10, 1))));
matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _scale, _scale, _scale));
draw_primitive_begin(pr_linelist);
var _count = 10;
for (var i = -_count; i <= _count; ++i)
{
	draw_vertex_color(i, -_count, #585A5C, 1.0);
	draw_vertex_color(i, +_count, #585A5C, 1.0);
}
for (var i = -_count; i <= _count; ++i)
{
	draw_vertex_color(-_count, i, #585A5C, 1.0);
	draw_vertex_color(+_count, i, #585A5C, 1.0);
}
draw_primitive_end();
matrix_set(matrix_world, matrix_build_identity());
gpu_pop_state();
