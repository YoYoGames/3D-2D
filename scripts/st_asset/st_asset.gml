/// @func ST_Asset(_model, _materials[, _animationNames[, _animations]])
///
/// @desc
///
/// @param {Struct.BBMOD_Model} _model
/// @param {Array<Struct.BBMOD_Material>} _materials
/// @param {Array<String>} _animationNames
/// @param {Array<Struct.BBMOD_Animation>} _animations
function ST_Asset(_model, _materials, _animationNames=[], _animations=[]) constructor
{
	/// @var {String}
	Path = "";

	/// @var {Bool}
	FlipUVHorizontally = false;

	/// @var {Bool}
	FlipUVVertically = false;

	/// @var {Real}
	SamplingRate = 30;

	/// @var {String}
	Name = "";

	/// @var {Struct.BBMOD_Model}
	/// @readonly
	Model = _model;

	/// @var {Bool}
	/// @readonly
	IsAnimated = (array_length(_animations) > 0);

	if (!IsAnimated)
	{
		for (var i = 0; i < array_length(Model.Meshes); ++i)
		{
			if (Model.Meshes[i].VertexFormat.Bones)
			{
				IsAnimated = true;
				break;
			}
		}
	}

	/// @var {Struct.BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Rotation = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Array<Struct.BBMOD_Material>}
	Materials = _materials;

	/// @var {Array<Id.Surface>}
	MaterialsPreview = undefined;

	/// @var {Id.DsMap<String, Asset.GMSprite>}
	/// @private
	static Sprites = ds_map_create();

	/// @var {Array<String>}
	/// @readonly
	MaterialSprites = array_create(array_length(Materials), undefined);

	/// @var {Array<String>}
	AnimationNames = _animationNames;

	/// @var {Array<Struct.BBMOD_Animation>}
	/// @readonly
	Animations = _animations;

	/// @var {Array<Array<Id.Surface>>} Preview of animation frames.
	AnimationsPreview = undefined;

	/// @var {Struct.BBMOD_AnimationPlayer}
	AnimationPlayer = IsAnimated
		? new BBMOD_AnimationPlayer(Model)
		: undefined;

	/// @var {Real}
	AnimationIndex = undefined;

	/// @var {Array<Array<Bool>>}
	FrameFilters = [];

	/// @var {Struct.ST_Asset}
	AttachedTo = undefined;

	/// @var {Real}
	AttachedToBone = undefined;

	/// @var {Array<Struct.ST_Asset>}
	Attachments = [];

	/// @var {Bool}
	AreAttachmentsVisible = true;

	/// @var {Array<Real>}
	Matrix = undefined;

	/// @var {Bool}
	Visible = true;

	ResetFrameFilters();

	// Play the first animation
	var _animationCount = array_length(Animations);
	if (_animationCount > 0
		&& AnimationPlayer)
	{
		PlayAnimation(0);
	}

	/// @func ResetFrameFilters()
	///
	/// @desc
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static ResetFrameFilters = function () {
		var _animationCount = array_length(Animations);
		if (_animationCount > 0)
		{
			FrameFilters = array_create(_animationCount);
			for (var i = 0; i < _animationCount; ++i)
			{
				FrameFilters[i] = array_create(Animations[i].Duration, true);
			}
		}
		else
		{
			FrameFilters = [];
		}
		return self;
	};

	static GetPosition = function () {
		gml_pragma("forceinline");
		if (Matrix)
		{
			return Matrix.Transform(Position);
		}
		return Position;
	};

	static GetRotation = function () {
		gml_pragma("forceinline");
		if (Matrix)
		{
			return new BBMOD_Vec3()
				.FromArray(
					new BBMOD_Matrix().RotateEuler(Rotation).Mul(Matrix)
						.ToEuler());
		}
		return Rotation;
	};

	static GetPositionX = function () { return GetPosition().X; };
	static GetPositionY = function () { return GetPosition().Y; };
	static GetPositionZ = function () { return GetPosition().Z; };
	static GetRotationX = function () { return Rotation.X; };
	static GetRotationY = function () { return Rotation.Y; };
	static GetRotationZ = function () { return Rotation.Z; };
	static GetScaleX    = function () { return Scale.X; };
	static GetScaleY    = function () { return Scale.Y; };
	static GetScaleZ    = function () { return Scale.Z; };

	static SetPositionX = function (_value) {
		if (Matrix)
		{
			Matrix.Inverse().Transform(new BBMOD_Vec3(_value, GetPositionY(), GetPositionZ())).Copy(Position);
			return;
		}
		Position.X = _value;
	};

	static SetPositionY = function (_value) {
		if (Matrix)
		{
			Matrix.Inverse().Transform(new BBMOD_Vec3(GetPositionX(), _value, GetPositionZ())).Copy(Position);
			return;
		}
		Position.Y = _value;
	};

	static SetPositionZ = function (_value) {
		if (Matrix)
		{
			Matrix.Inverse().Transform(new BBMOD_Vec3(GetPositionX(), GetPositionY(), _value)).Copy(Position);
			return;
		}
		Position.Z = _value;
	};

	static SetRotationX = function (_value) { Rotation.X = _value; };
	static SetRotationY = function (_value) { Rotation.Y = _value; };
	static SetRotationZ = function (_value) { Rotation.Z = _value; };

	static SetScaleX = function (_value) { Scale.X = _value; };
	static SetScaleY = function (_value) { Scale.Y = _value; };
	static SetScaleZ = function (_value) { Scale.Z = _value; };

	/// @func Attach(_asset[, _boneIndex])
	///
	/// @desc
	///
	/// @param {ST_Asset} _asset
	/// @param {Real} [_boneIndex]
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static Attach = function (_asset, _boneIndex=undefined) {
		array_push(Attachments, _asset);
		_asset.AttachedTo = self;
		_asset.AttachedToBone = _boneIndex;
		return self;
	};

	/// @func LoadSprite(_path)
	///
	/// @desc
	///
	/// @param {String} _path
	///
	/// @return {Asset.GMSprite}
	static LoadSprite = function (_path) {
		if (ds_map_exists(Sprites, _path))
		{
			sprite_delete(Sprites[? _path]);
		}
		var _sprite = sprite_add(_path, 1, false, false, 0, 0);
		Sprites[? _path] = _sprite;
		return _sprite;
	};

	/// @func PlayAnimation(_index)
	///
	/// @desc
	///
	/// @param {Real} _index
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static PlayAnimation = function (_index) {
		AnimationIndex = _index;
		AnimationPlayer.play(Animations[_index], true);
		return self;
	};

	/// @func GetAnimationFrameCount(_index)
	///
	/// @desc
	///
	/// @param {Real} _index
	///
	/// @return {Real}
	static GetAnimationFrameCount = function (_index) {
		var _count = 0;
		var _frameFilters = FrameFilters[_index];
		for (var i = array_length(_frameFilters) - 1; i >= 0; --i)
		{
			if (_frameFilters[i])
			{
				++_count;
			}
		}
		return _count;
	};

	/// @func GetAnimationFrameIndex()
	///
	/// @desc
	///
	/// @return {Real}
	static GetAnimationFrameIndex = function () {
		gml_pragma("forceinline");
		var _animation = AnimationPlayer ? AnimationPlayer.Animation : undefined;
		if (_animation
			&& !_animation.IsTransition)
		{
			return _animation.get_animation_time(AnimationPlayer.Time) % _animation.Duration;
		}
		return undefined;
	};

	/// @func Update(_deltaTime)
	///
	/// @desc
	///
	/// @param {Real} _deltaTime
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static Update = function (_deltaTime) {
		if (AnimationPlayer
			&& AnimationIndex != undefined)
		{
			var _animation = AnimationPlayer.Animation;
			if (_animation && !_animation.IsTransition)
			{
				var _frameFilter = FrameFilters[AnimationIndex];
				var _hasFrames = false;
				for (var i = array_length(_frameFilter) - 1; i >= 0; --i)
				{
					if (_frameFilter[i])
					{
						_hasFrames = true;
						break;
					}
				}
				if (_hasFrames)
				{
					while (true)
					{
						var _index = _animation.get_animation_time(AnimationPlayer.Time) % _animation.Duration;
						if (_frameFilter[_index])
						{
							break
						}
						AnimationPlayer.Time += 1.0 / _animation.TicsPerSecond;
					}
					AnimationPlayer.update(_deltaTime);
				}
			}
			else
			{
				AnimationPlayer.update(_deltaTime);
			}
		}
		return self;
	};

	/// @func GetTransform([_tpose])
	///
	/// @desc
	///
	/// @param {Bool} [_tpose]
	///
	/// @return {Array<Real>}
	static GetTransform = function (_tpose=false) {
		var _transform = undefined;
		if (AnimationPlayer)
		{
			if (_tpose || !AnimationPlayer.Animation)
			{
				_transform = array_create(Model.BoneCount * 8, 0);
				var _dq = new BBMOD_DualQuaternion();
				var i = 0;
				repeat (Model.BoneCount)
				{
					_dq.ToArray(_transform, i * 8);
					++i;
				}
			}
			else
			{
				_transform = AnimationPlayer.get_transform();
			}
		}
		return _transform;
	};

	/// @func Draw([_matrix[, _transform]])
	///
	/// @desc Draws the Asset.
	///
	/// @param {Struct.BBMOD_Matrix} [_matrix]
	/// @param {Array<Real>} [_transform]
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static Draw = function (_matrix=undefined, _transform=undefined) {
		bbmod_material_reset();
		var _m = new BBMOD_Matrix()
			.Scale(Scale)
			.RotateEuler(Rotation)
			.Translate(Position);
		if (_matrix)
		{
			_m = _m.Mul(_matrix);
		}

		// Draw attachments first
		if (AreAttachmentsVisible)
		{
			var _animationPlayer = AnimationPlayer;
			var i = 0;
			repeat (array_length(Attachments))
			{
				with (Attachments[i++])
				{
					var _attachmentMatrix = new BBMOD_Matrix()
						.Scale(Scale)
						.RotateEuler(Rotation)
						.Translate(Position);
					if (AttachedToBone != undefined)
					{
						var _boneMatrix = new BBMOD_Matrix(_animationPlayer.get_node_transform(AttachedToBone).ToMatrix());
						_attachmentMatrix = _attachmentMatrix.Mul(_boneMatrix);
					}
					_attachmentMatrix = _attachmentMatrix.Mul(_m);
					_attachmentMatrix.ApplyWorld();
					Model.submit(Materials);
				}
			}
		}

		// Draw model
		_m.ApplyWorld();
		Model.submit(Materials, _transform ?? GetTransform());

		matrix_set(matrix_world, matrix_build_identity());
		bbmod_material_reset();
		return self;
	};

	/// @func DrawAnimationFrame(_animationIndex, _animationFrame[, _matrix])
	///
	/// @desc
	///
	/// @param {Real} _animationIndex
	/// @param {Real} _animationFrame
	/// @param {Struct.BBMOD_Matrix} [_matrix]
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static DrawAnimationFrame = function (_animationIndex, _animationFrame, _matrix=undefined) {
		var _animation = Animations[_animationIndex];
		var _animationLast = AnimationPlayer.Animation;
		var _timeLast = AnimationPlayer.Time;
		var _paused = AnimationPlayer.Paused;
		AnimationPlayer.Paused = false;
		AnimationPlayer.play(_animation, true);
		AnimationPlayer.Time = _animationFrame / _animation.TicsPerSecond;
		AnimationPlayer.update(0.0);
		//var _animationPlayer = new BBMOD_AnimationPlayer(Model);
		//_animationPlayer.play(_animation, true);
		//_animationPlayer.Time = _animationFrame / _animation.TicsPerSecond;
		//_animationPlayer.update(0.0);
		Draw(_matrix);
		//_animationPlayer.destroy();
		AnimationPlayer.play(_animationLast, true);
		AnimationPlayer.Time = _timeLast;
		AnimationPlayer.update(0.0);
		AnimationPlayer.Paused = _paused;
		return self;
	};

	/// @func Render([_matrix[, _transform]])
	///
	/// @desc Submits the Asset for rendering.
	///
	/// @param {Struct.BBMOD_Matrix} [_matrix]
	/// @param {Array<Real>} [_transform]
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static Render = function (_matrix=Matrix, _transform=undefined) {
		bbmod_material_reset();
		var _m = new BBMOD_Matrix()
			.Scale(Scale)
			.RotateEuler(Rotation)
			.Translate(Position);
		if (_matrix)
		{
			_m = _m.Mul(_matrix);
		}

		// Draw attachments first
		//if (AreAttachmentsVisible)
		//{
			var _animationPlayer = AnimationPlayer;
			var i = 0;
			repeat (array_length(Attachments))
			{
				with (Attachments[i++])
				{
					var _attachmentMatrix = new BBMOD_Matrix()
						//.Scale(Scale)
						//.RotateEuler(Rotation)
						//.Translate(Position)
						;
					if (AttachedToBone != undefined)
					{
						var _boneMatrix = new BBMOD_Matrix(_animationPlayer.get_node_transform(AttachedToBone).ToMatrix());
						_attachmentMatrix = _attachmentMatrix.Mul(_boneMatrix);
					}
					_attachmentMatrix = _attachmentMatrix.Mul(_m);
					Matrix = _attachmentMatrix;
					//_attachmentMatrix.ApplyWorld();
					Visible = other.AreAttachmentsVisible;
					//Model.render(Materials);
				}
			}
		//}

		// Draw model
		_m.ApplyWorld();
		Model.render(Materials, _transform ?? GetTransform());

		matrix_set(matrix_world, matrix_build_identity());
		bbmod_material_reset();
		return self;
	};

	/// @func DrawMaterialIndices([_matrix[, _transform]])
	///
	/// @desc Draws the Asset with a shader that shows material indices.
	///
	/// @param {Struct.BBMOD_Matrix} [_matrix]
	/// @param {Array<Real>} [_transform]
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static DrawMaterialIndices = function (_matrix=Matrix, _transform=undefined) {
		// TODO: Do material highlight in a single render pass, using MRTs
		_transform ??= GetTransform();

		gpu_push_state();
		gpu_set_zwriteenable(true);
		gpu_set_ztestenable(true);

		var _m = new BBMOD_Matrix()
			.Scale(Scale)
			.RotateEuler(Rotation)
			.Translate(Position);
		if (_matrix)
		{
			_m = _m.Mul(_matrix);
		}

		_m.ApplyWorld();

		var _shader = undefined;

		with (Model)
		{
			if (RootNode != undefined)
			{
				with (RootNode)
				{
					var _meshes = Model.Meshes;
					var _renderStack = global.__bbmodRenderStack;
					var _node = self;

					var _world = matrix_get(matrix_world);
					ds_stack_push(_renderStack, _node);

					while (!ds_stack_empty(_renderStack))
					{
						_node = ds_stack_pop(_renderStack);

						if (!_node.IsRenderable || !_node.Visible)
						{
							continue;
						}

						var _nodeTransform = undefined;
						var _nodeMatrix = undefined;

						var _meshIndices = _node.Meshes;
						var _children = _node.Children;
						var i = 0;

						repeat (array_length(_meshIndices))
						{
							var _mesh = _meshes[_meshIndices[i++]];
							var _materialIndex = _mesh.MaterialIndex;
							var _isAnimated = _mesh.VertexFormat.Bones;

							if (_isAnimated)
							{
								matrix_set(matrix_world, _world);
							}
							else
							{
								if (!_nodeTransform)
								{
									if (_transform == undefined)
									{
										_nodeTransform = _node.Transform;
									}
									else
									{
										_nodeTransform = new BBMOD_DualQuaternion()
											.FromArray(_transform, _node.Index * 8);
									}
									_nodeMatrix = matrix_multiply(_nodeTransform.ToMatrix(), _world);
								}

								matrix_set(matrix_world, _nodeMatrix);
							}

							var _shaderMesh = _isAnimated
								? ST_ShMaterialIndexAnimated : ST_ShMaterialIndex;

							if (_shader != _shaderMesh)
							{
								if (_shader != undefined)
								{
									shader_reset();
								}
								_shader = _shaderMesh;
								shader_set(_shader);
							}

							shader_set_uniform_f(shader_get_uniform(_shader, "u_fMaterialIndex"),
								_materialIndex / 255.0);

							if (_isAnimated)
							{
								shader_set_uniform_f_array(shader_get_uniform(_shader, "bbmod_Bones"),
									_transform);
							}

							with (_mesh)
							{
								vertex_submit(VertexBuffer, PrimitiveType, -1);
							}
						}

						i = 0;
						repeat (array_length(_children))
						{
							ds_stack_push(_renderStack, _children[i++]);
						}
					}

					matrix_set(matrix_world, _world);
				}
			}
		}

		if (_shader != undefined)
		{
			shader_reset();
		}

		matrix_set(matrix_world, matrix_build_identity());
		gpu_pop_state();
		return self;
	};

	/// @func Duplicate()
	///
	/// @desc Creates a deep copy of the Asset.
	///
	/// @return {Struct.ST_Asset} The created copy.
	static Duplicate = function () {
		var _materialCount = array_length(Materials);
		var _materials = array_create(_materialCount);
		for (var i = 0; i < _materialCount; ++i)
		{
			_materials[i] = Materials[i].clone();
		}

		var _animationCount = array_length(AnimationNames);
		var _animationNames = array_create(_animationCount);
		var _animations = array_create(_animationCount);
		for (var i = 0; i < _animationCount; ++i)
		{
			_animationNames[i] = AnimationNames[i];
			_animations[i] = Animations[i].ref();
		}

		var _copy = new ST_Asset(Model.ref(), _materials, _animationNames, _animations);
		Position.Copy(_copy.Position);
		Rotation.Copy(_copy.Rotation);
		Scale.Copy(_copy.Scale);

		_copy.AnimationIndex = AnimationIndex;
		_copy.FrameFilters = array_create(array_length(FrameFilters));
		array_copy(_copy.FrameFilters, 0, FrameFilters, 0, array_length(FrameFilters));

		for (var i = 0; i < array_length(Attachments); ++i)
		{
			_copy.Attach(Attachments[i].Duplicate());
		}

		_copy.AreAttachmentsVisible = AreAttachmentsVisible;
		_copy.Matrix = Matrix.Clone();
		_copy.Visible = Visible;

		if (AttachedTo)
		{
			AttachedTo.Attach(_copy, AttachedToBone);
		}

		return _copy;
	};

	/// @func FreeAnimationsPreview()
	///
	/// @desc
	///
	/// @return {Struct.ST_Asset} Returns `self`.
	static FreeAnimationsPreview = function () {
		if (AnimationsPreview != undefined)
		{
			for (var i = array_length(AnimationsPreview) - 1; i >= 0; --i)
			{
				var _frames = AnimationsPreview[i];
				for (var j = array_length(_frames) - 1; j >= 0; --j)
				{
					var _surface = _frames[j];
					if (surface_exists(_surface))
					{
						surface_free(_surface);
					}
				}
			}
			AnimationsPreview = undefined;
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @desc Frees resources used by the Asset from memory.
	///
	/// @return {Undefined}
	static Destroy = function () {
		if (AttachedTo)
		{
			var _attachments = AttachedTo.Attachments;
			for (var i = array_length(_attachments) - 1; i >= 0; --i)
			{
				if (_attachments[i] == self)
				{
					array_delete(_attachments, i, 1);
					break;
				}
			}
			AttachedTo = undefined;
		}

		if (Model)
		{
			Model.free();
			Model = undefined;
		}

		for (var i = array_length(Materials) - 1; i >= 0; --i)
		{
			Materials[i].free();
		}
		Materials = [];

		//var _key = ds_map_find_first(Sprites);
		//repeat (ds_map_size(Sprites))
		//{
		//	sprite_delete(Sprites[? _key]);
		//	_key = ds_map_find_next(Sprites, _key);
		//}
		//ds_map_clear(Sprites);

		for (var i = array_length(Animations) - 1; i >= 0; --i)
		{
			Animations[i].free();
		}
		Animations = [];

		if (AnimationPlayer)
		{
			AnimationPlayer.destroy();
			AnimationPlayer = undefined;
		}

		FreeAnimationsPreview();

		if (MaterialsPreview != undefined)
		{
			for (var i = array_length(MaterialsPreview) - 1; i >= 0; --i)
			{
				var _surface = MaterialsPreview[i];
				if (surface_exists(_surface))
				{
					surface_free(_surface);
				}
			}
			MaterialsPreview = undefined;
		}

		return undefined;
	};
}
