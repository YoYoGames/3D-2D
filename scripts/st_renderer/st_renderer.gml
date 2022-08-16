/// @func ST_Renderer()
///
/// @extends BBMOD_Renderer
function ST_Renderer()
	: BBMOD_Renderer() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Id.Surface}
	SurMaterialIndices = noone;

	/// @var {Struct.BBMOD_Color}
	MaterialHighlightColor = BBMOD_C_FUCHSIA;

	static Renderer_render = render;

	static render = function () {
		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);

		Renderer_render();

		////////////////////////////////////////////////////////////////////////////////
		// Material highlight
		SurMaterialIndices = bbmod_surface_check(
			SurMaterialIndices, get_render_width(), get_render_height());

		if (global.stMaterialHighlightInstance != undefined)
		{
			surface_set_target(SurMaterialIndices);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			global.stMaterialHighlightInstance.Asset.DrawMaterialIndices();
			surface_reset_target();
		}

		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		return self;
	};

	static present = function () {
		global.__bbmodRendererCurrent = self;

		var _world = matrix_get(matrix_world);
		var _width = get_width();
		var _height = get_height();
		var _renderWidth = get_render_width();
		var _renderHeight = get_render_height();
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;
		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);

		if (UseAppSurface)
		{
			var _surFinal = application_surface;
			var _drawGizmo = (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected));

			////////////////////////////////////////////////////////////////////
			// Highlighted instances
			if (_drawGizmo && surface_exists(SurInstanceHighlight))
			{
				surface_set_target(_surFinal);
				matrix_set(matrix_world, matrix_build_identity());
				var _shader = BBMOD_ShInstanceHighlight;
				shader_set(_shader);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
					_texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
					InstanceHighlightColor.Red / 255.0,
					InstanceHighlightColor.Green / 255.0,
					InstanceHighlightColor.Blue / 255.0,
					InstanceHighlightColor.Alpha);
				draw_surface_stretched(
					SurInstanceHighlight, 0, 0, _renderWidth, _renderHeight);
				shader_reset();
				surface_reset_target();
			}

			////////////////////////////////////////////////////////////////////
			// Highlight material
			if (global.stMaterialHighlightInstance != undefined
				&& surface_exists(SurMaterialIndices))
			{
				surface_set_target(_surFinal);
				matrix_set(matrix_world, matrix_build_identity());
				var _shader = ST_ShMaterialHighlight;
				shader_set(_shader);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
					_texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
					MaterialHighlightColor.Red / 255.0,
					MaterialHighlightColor.Green / 255.0,
					MaterialHighlightColor.Blue / 255.0,
					MaterialHighlightColor.Alpha);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fMaterialIndex"),
					global.stMaterialHighlightIndex / 255.0);
				draw_surface_stretched(SurMaterialIndices, 0, 0, _renderWidth, _renderHeight);
				shader_reset();
				surface_reset_target();
			}

			////////////////////////////////////////////////////////////////////
			// Gizmo
			if (_drawGizmo && surface_exists(SurGizmo))
			{
				surface_set_target(_surFinal);
				matrix_set(matrix_world, matrix_build_identity());
				draw_surface_stretched(SurGizmo, 0, 0, _renderWidth, _renderHeight);
				surface_reset_target();
			}

			matrix_set(matrix_world, _world);

			////////////////////////////////////////////////////////////////////
			// Post-processing
			if (EnablePostProcessing)
			{
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					SurPostProcess = bbmod_surface_check(SurPostProcess, _width, _height);
					surface_set_target(SurPostProcess);
					matrix_set(matrix_world, matrix_build_identity());
				}
				var _shader = BBMOD_ShPostProcess;
				shader_set(_shader);
				var _uLut = shader_get_sampler_index(_shader, "u_texLut");
				texture_set_stage(_uLut, ColorGradingLUT);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
					_texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"),
					ChromaticAberration);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fGrayscale"),
					Grayscale);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fVignette"),
					Vignette);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vVignetteColor"),
					color_get_red(VignetteColor) / 255,
					color_get_green(VignetteColor) / 255,
					color_get_blue(VignetteColor) / 255);
				draw_surface_stretched(
					application_surface,
					(Antialiasing == BBMOD_EAntialiasing.None) ? X : 0,
					(Antialiasing == BBMOD_EAntialiasing.None) ? Y : 0,
					_width, _height);
				shader_reset();
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					surface_reset_target();
					matrix_set(matrix_world, _world);
					_surFinal = SurPostProcess;
				}
			}

			////////////////////////////////////////////////////////////////////
			// Anti-aliasing
			if (Antialiasing == BBMOD_EAntialiasing.FXAA)
			{
				var _shader = BBMOD_ShFXAA;
				shader_set(_shader);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexelVS"),
					_texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexelPS"),
					_texelWidth, _texelHeight);
				draw_surface_stretched(_surFinal, X, Y, _width, _height);
				shader_reset();
			}
			else if (!EnablePostProcessing)
			{
				draw_surface_stretched(application_surface, X, Y, _width, _height);
			}
		}
		else
		{
			var _drawGizmo = (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected));

			////////////////////////////////////////////////////////////////////
			// Highlighted instances
			if (_drawGizmo)
			{
				if (!ds_list_empty(Gizmo.Selected)
					&& surface_exists(SurInstanceHighlight))
				{
					var _shader = BBMOD_ShInstanceHighlight;
					shader_set(_shader);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
						_texelWidth, _texelHeight);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
						InstanceHighlightColor.Red / 255.0,
						InstanceHighlightColor.Green / 255.0,
						InstanceHighlightColor.Blue / 255.0,
						InstanceHighlightColor.Alpha);
					draw_surface_stretched(SurInstanceHighlight, X, Y, _width, _height)
					shader_reset();
				}
			}

			////////////////////////////////////////////////////////////////////
			// Highlight material
			if (global.stMaterialHighlightInstance != undefined
				&& surface_exists(SurMaterialIndices))
			{
				surface_set_target(_surFinal);
				matrix_set(matrix_world, matrix_build_identity());
				var _shader = ST_ShMaterialHighlight;
				shader_set(_shader);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
					_texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
					MaterialHighlightColor.Red / 255.0,
					MaterialHighlightColor.Green / 255.0,
					MaterialHighlightColor.Blue / 255.0,
					MaterialHighlightColor.Alpha);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fMaterialIndex"),
					global.stMaterialHighlightIndex / 255.0);
				draw_surface_stretched(SurMaterialIndices, X, Y, _width, _height);
				shader_reset();
				surface_reset_target();
			}
			
			////////////////////////////////////////////////////////////////////
			// Gizmo
			if (_drawGizmo && surface_exists(SurGizmo))
			{
				draw_surface_stretched(SurGizmo, X, Y, _width, _height);
			}
		}

		gpu_pop_state();
	};

	static Renderer_destroy = destroy;

	static destroy = function () {
		Renderer_destroy();
		if (surface_exists(SurMaterialIndices))
		{
			surface_free(SurMaterialIndices);
		}
		return undefined;
	};
}
