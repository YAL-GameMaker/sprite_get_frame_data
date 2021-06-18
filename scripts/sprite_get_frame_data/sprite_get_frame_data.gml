globalvar __sprite_frame_data_map;
/// @param {string} json_path
/// @param {string?} ?yyp_path
function sprite_get_frame_data_init(_json_path, _yyp_path) {
	if (false) return argument[1];
	if (_yyp_path != undefined && (_yyp_path == "" || !file_exists(_yyp_path))) {
		show_debug_message("sprite_get_frame_data_init: Project file doesn't exist - loading included file");
		_yyp_path = undefined;
	}
	__sprite_frame_data_map = {};
	if (_yyp_path != undefined) {
		var _project_dir = filename_dir(_yyp_path);
		var _json_map = {};
		if (_yyp_path != undefined) {
			var _sprite_name = file_find_first(_project_dir + "/sprites/*", fa_readonly|fa_directory);
			for (; _sprite_name != ""; _sprite_name = file_find_next()) {
				var _sprite_index = asset_get_index(_sprite_name);
				if (_sprite_index == -1) continue; // not part of project file!
				var _sprite_path = _project_dir + "/sprites/" + _sprite_name + "/" + _sprite_name + ".yy";
				if (!file_exists(_sprite_path)) continue;
				var _buf = buffer_load(_sprite_path);
				var _sprite = json_parse(buffer_read(_buf, buffer_string));
				buffer_delete(_buf);
				var _keyFrames = _sprite.sequence.tracks[0].keyframes.Keyframes;
				var _frame_count = array_length(_keyFrames);
				var _frame_data = array_create(_frame_count);
				var _frame_durations = array_create(_frame_count);
				var t = 0;
				for (var i = 0; i < _frame_count; i++) {
					var tl = _keyFrames[i].Length;
					_frame_durations[i] = tl;
					_frame_data[i] = {
						from: t,
						to: t + tl,
						len: tl,
					}
					t += tl;
				}
				if (_frame_count > 0) _json_map[$ _sprite_name] = _frame_durations;
				__sprite_frame_data_map[$ _sprite_index] = _frame_data;
			}
			file_find_close();
		}
		//
		var _text_file = file_text_open_write(_project_dir + "/datafiles/" + _json_path);
		file_text_write_string(_text_file, json_stringify(_json_map));
		file_text_close(_text_file);
	} else {
		var _buf = buffer_load(_json_path);
		var _json_map = json_parse(buffer_read(_buf, buffer_string));
		buffer_delete(_buf);
		var _sprite_names = variable_struct_get_names(_json_map);
		var _sprite_count = array_length(_sprite_names);
		for (var i = 0; i < _sprite_count; i++) {
			var _sprite_name = _sprite_names[i];
			var _sprite_index = asset_get_index(_sprite_name);
			if (_sprite_index == -1) continue;
			var _frame_durations = _json_map[$ _sprite_name];
			var _frame_count = array_length(_frame_durations);
			var _frame_data = array_create(_frame_count);
			var _frameStart = 0;
			for (var k = 0; k < _frame_count; k++) {
				var _frameDur = _frame_durations[k];
				_frame_data[k] = {
					from: _frameStart,
					to: _frameStart + _frameDur,
					len: _frameDur,
				}
				_frameStart += _frameDur;
			}
			__sprite_frame_data_map[$ _sprite_index] = _frame_data;
		}
	}
}

/// @param {sprite} sprite
/// @returns {array}
function sprite_get_frame_data(_sprite) {
	return __sprite_frame_data_map[$ _sprite];
}

/// @param {sprite} sprite
/// @returns {number} total time duration of the sprite
function sprite_get_duration(_sprite) {
	var _frame_data = __sprite_frame_data_map[$ _sprite];
	if (_frame_data == undefined) return 0;
	return _frame_data[array_length(_frame_data) - 1].to;
}

/// @param {sprite} sprite
/// @param {int} subimg
/// @returns {number} time duration of the frame
function sprite_get_frame_duration(_sprite, _subimg) {
	var _frame_data = __sprite_frame_data_map[$ _sprite];
	if (_frame_data == undefined) return 0;
	return _frame_data[_subimg].len;
}

/// @param {sprite} sprite
/// @param {int} subimg
/// @returns {number} time offset for the beginning of the frame
function sprite_get_frame_start(_sprite, _subimg) {
	var _frame_data = __sprite_frame_data_map[$ _sprite];
	if (_frame_data == undefined) return 0;
	return _frame_data[_subimg].from;
}

/// @param {sprite} sprite
/// @param {int} subimg
/// @returns {number} time offset for the end of the frame
function sprite_get_frame_end(_sprite, _subimg) {
	var _frame_data = __sprite_frame_data_map[$ _sprite];
	if (_frame_data == undefined) return 0;
	return _frame_data[_subimg].to;
}

/// @param {sprite} sprite
/// @param {number} time
/// @returns {int} frame index at the given time, -1 if out of bounds
function sprite_get_frame_index(_sprite, _time) {
	if (_time < 0) return -1;
	var _frame_data = __sprite_frame_data_map[$ _sprite];
	if (_frame_data == undefined) return -1;
	//show_debug_message(_frame_data)
	var _end = array_length(_frame_data) - 1;
	if (_time > _frame_data[_end].to) return -1;
	var _start = 0;
	while (_start <= _end) {
		var _mid = (_start + _end) div 2;
		var _frame = _frame_data[_mid];
		//trace(`t=$_time start=$_start end=$_end mid=$_mid frame=$_frame`)
		if (_time < _frame.from) {
			_end = _mid;
		} else if (_time >= _frame.to) {
			_start = _mid == _start ? _start + 1 : _mid;
		} else {
			return _mid;
		}
	}
	return -1;
}