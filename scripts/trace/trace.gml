function trace() {
	var r = "";
	for (var i = 0; i < argument_count; i++) {
		r += string(argument[i]) + " ";
	}
	show_debug_message(r);
}
