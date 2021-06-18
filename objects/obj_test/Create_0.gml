var _json = "sprite-durations.json";
if (1) {
    // development version
    sprite_get_frame_data_init(_json,
        "" // set the path to your YYP here, e.g. "C:/git/sprite_get_frame_data/sprite_get_frame_data.yyp"
    );
} else {
    // release version
    sprite_get_frame_data_init(_json);
}

show_debug_message("Start of frame 2 in spr_test: " + string(sprite_get_frame_start(spr_test, 2)));
show_debug_message("End of frame 2 in spr_test: " + string(sprite_get_frame_end(spr_test, 2)));
show_debug_message("Duration of frame 2 in spr_test: " + string(sprite_get_frame_duration(spr_test, 2)));
show_debug_message("Frame at time=4 in spr_test: " + string(sprite_get_frame_index(spr_test, 4)));
show_debug_message("Duration of spr_test: " + string(sprite_get_duration(spr_test)));
show_debug_message("Frame data for spr_test: " + string(sprite_get_frame_data(spr_test)));
