using Gtk, CairoChart;

void plot_chart1 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();

	s1.title = new Text("Series 1"); s1.color = Color (1, 0, 0);
	s1.points = {Point128(0, 0), Point128(2, 1), Point128(1, 3)};
	s1.axis_x.position = Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = Color (0, 1, 0);
	s2.points = {Point128(5, -3), Point128(25, -18), Point128(-11, 173)};
	s3.title = new Text("Series 3"); s3.color = Color (0, 0, 1);
	s3.points = {Point128(9, 17), Point128(2, 10), Point128(122, 31)};
	s3.axis_y.position = Axis.Position.HIGH;

	s1.axis_x.min = 0; s1.axis_x.max = 2;
	s1.axis_y.min = 0; s1.axis_y.max = 3;
	s1.place.x_min = 0.25; s1.place.x_max = 0.75;
	s1.place.y_min = 0.3; s1.place.y_max = 0.9;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_min = 0.5; s2.place.x_max = 1;
	s2.place.y_min = 0.0; s2.place.y_max = 0.5;

	s3.axis_x.min = 0; s3.axis_x.max = 130;
	s3.axis_y.min = 15; s3.axis_y.max = 35;
	s3.place.x_min = 0; s3.place.x_max = 0.5;
	s3.place.y_min = 0.5; s3.place.y_max = 1.0;

	s1.marker.type = Marker.Type.SQUARE;
	s2.marker.type = Marker.Type.CIRCLE;
	s3.marker.type = Marker.Type.PRICLE_TRIANGLE;

	s1.axis_x.title = new Text("Series 1: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("Series 2: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("Series 3: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");

	chart.series = { s1, s2, s3 };
}

void plot_chart2 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();

	s1.title = new Text("Series 1"); s1.color = Color (1, 0, 0);
	s1.points = {Point128(-12, 0), Point128(2, 1), Point128(20, 3)};
	s2.axis_y.position = Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = Color (0, 1, 0);
	s2.points = {Point128(5, -3), Point128(25, -18), Point128(-11, 173)};
	s3.title = new Text("Series 3"); s3.color = Color (0, 0, 1);
	s3.points = {Point128(9, 17), Point128(2, 10), Point128(-15, 31)};
	s3.axis_y.position = Axis.Position.HIGH;

	s1.axis_x.min = -15; s1.axis_x.max = 30;
	s1.axis_y.min = 0; s1.axis_y.max = 3;
	s1.place.x_min = 0.0; s1.place.x_max = 1.0;
	s1.place.y_min = 0.3; s1.place.y_max = 0.9;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_min = 0.0; s2.place.x_max = 1.0;
	s2.place.y_min = 0.0; s2.place.y_max = 0.5;

	s3.axis_x.min = -15; s3.axis_x.max = 30;
	s3.axis_y.min = 15; s3.axis_y.max = 35;
	s3.place.x_min = 0.0; s3.place.x_max = 1.0;
	s3.place.y_min = 0.5; s3.place.y_max = 1.0;

	s1.marker.type = Marker.Type.PRICLE_CIRCLE;
	s2.marker.type = Marker.Type.PRICLE_SQUARE;
	s3.marker.type = Marker.Type.SQUARE;

	s1.axis_x.title = new Text("All Series: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("All Series: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("All Series: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");

	//s1.axis_x.position = s2.axis_x.position = s3.axis_x.position = Axis.Position.HIGH;
	//s1.axis_x.type = s2.axis_x.type = s3.axis_x.type = Axis.Type.DATE_TIME;
	//s1.axis_x.max = s2.axis_x.max = s3.axis_x.max = 5*24*3600;

	chart.series = { s1, s2, s3 };
}

void plot_chart3 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();

	s1.title = new Text("Series 1"); s1.color = Color (1, 0, 0);
	s1.points = {Point128(0, 70), Point128(2, 155), Point128(1, -3)};
	s1.axis_x.position = Axis.Position.HIGH;
	s1.axis_y.position = Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = Color (0, 1, 0);
	s2.points = {Point128(5, -3), Point128(25, -18), Point128(-11, 173)};
	s2.axis_y.position = Axis.Position.HIGH;
	s3.title = new Text("Series 3"); s3.color = Color (0, 0, 1);
	s3.points = {Point128(9, -17), Point128(2, 10), Point128(122, 31)};
	s3.axis_y.position = Axis.Position.HIGH;

	s1.axis_x.min = 0; s1.axis_x.max = 2;
	s1.axis_y.min = -20; s1.axis_y.max = 200;
	s1.place.x_min = 0.25; s1.place.x_max = 0.75;
	s1.place.y_min = 0.0; s1.place.y_max = 1.0;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_min = 0.5; s2.place.x_max = 1;
	s2.place.y_min = 0.0; s2.place.y_max = 1.0;

	s3.axis_x.min = 0; s3.axis_x.max = 130;
	s3.axis_y.min = -20; s3.axis_y.max = 200;
	s3.place.x_min = 0; s3.place.x_max = 0.5;
	s3.place.y_min = 0.0; s3.place.y_max = 1.0;

	s1.marker.type = Marker.Type.SQUARE;
	s2.marker.type = Marker.Type.PRICLE_CIRCLE;
	s3.marker.type = Marker.Type.TRIANGLE;

	s1.axis_x.title = new Text("Series 1: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("Series 2: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("Series 3: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");

	//s1.axis_y.position = s2.axis_y.position = s3.axis_y.position = Axis.Position.LOW;

	chart.series = { s1, s2, s3 };
}

void plot_chart4 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();
	var s4 = new Series ();

	s1.axis_x.type = Axis.Type.DATE_TIME;
	s3.axis_x.type = Axis.Type.DATE_TIME;
	s4.axis_x.type = Axis.Type.DATE_TIME;
	s4.axis_x.dsec_signs = 5;

	var now = new DateTime.now_local().to_unix();
	var high = (uint64) (253000000000L);

	s1.title = new Text("Series 1"); s1.color = Color (1, 0, 0);
	s1.points = {Point128(now, 70), Point128(now - 100000, 155), Point128(now + 100000, 30)};
	s1.axis_x.position = Axis.Position.HIGH;
	s1.axis_y.position = Axis.Position.HIGH;
	s2.title = new Text("Series 2"); s2.color = Color (0, 1, 0);
	s2.points = {Point128(5, -3), Point128(25, -18), Point128(-11, 173)};
	s2.axis_y.position = Axis.Position.HIGH;
	s3.title = new Text("Series 3"); s3.color = Color (0, 0, 1);
	s3.points = {Point128(high - 2 + 0.73, -17), Point128(high - 1 + 0.234, 10), Point128(high + 1 + 0.411, 31)};
	s3.axis_y.position = Axis.Position.HIGH;
	s4.title = new Text("Series 4"); s4.color = Color (0.5, 0.3, 0.9);
	s4.points = {Point128(high + 0.005, -19.05), Point128(high + 0.0051, 28), Point128(high + 0.0052, 55), Point128(high + 0.0053, 44)};
	s4.axis_y.position = Axis.Position.HIGH;

	s1.axis_x.min = now - 100000; s1.axis_x.max = now + 100000;
	s1.axis_y.min = -20; s1.axis_y.max = 200;
	s1.place.x_min = 0.25; s1.place.x_max = 0.75;
	s1.place.y_min = 0.0; s1.place.y_max = 1.0;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_min = 0.2; s2.place.x_max = 1;
	s2.place.y_min = 0.0; s2.place.y_max = 1.0;

	s3.axis_x.min = high - 2; s3.axis_x.max = high + 1;
	s3.axis_y.min = -20; s3.axis_y.max = 200;
	s3.place.x_min = 0; s3.place.x_max = 0.8;
	s3.place.y_min = 0.0; s3.place.y_max = 1.0;

	s4.axis_x.min = high + 0.0049; s4.axis_x.max = high + 0.0054;
	s4.axis_y.min = -20; s4.axis_y.max = 200;
	s4.place.x_min = 0.2; s4.place.x_max = 1.0;
	s4.place.y_min = 0.0; s4.place.y_max = 1.0;

	s1.marker.type = Marker.Type.SQUARE;
	s2.marker.type = Marker.Type.PRICLE_CIRCLE;
	s3.marker.type = Marker.Type.TRIANGLE;
	s4.marker.type = Marker.Type.PRICLE_SQUARE;

	s1.axis_x.title = new Text("Series 1: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("Series 2: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("Series 3: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");
	s4.axis_x.title = new Text("Series 4: Axis X.");
	s4.axis_y.title = new Text("Series 4: Axis Y.");

	chart.series = { s1, s2, s3, s4 };
}

bool point_in_chart (Chart chart, double x, double y) {
	if (x < chart.plot_x_min) return false;
	if (x > chart.plot_x_max) return false;
	if (y < chart.plot_y_min) return false;
	if (y > chart.plot_y_max) return false;
	return true;
}

enum MouseState {
	FREE = 0,  // default
	DRAW_SELECTION,
	MOVING_CHART,
	CURSOR_SELECTION
}

int main (string[] args) {
	init (ref args);

	var window = new Window ();
	window.title = "Chart Test.";
	window.border_width = 5;
	window.window_position = WindowPosition.CENTER;
	window.set_default_size (640, 480);
	window.destroy.connect (main_quit);

	var chart1 = new Chart();
	var chart2 = new Chart();
	var chart3 = new Chart();
	var chart4 = new Chart();
	var label = new Gtk.Label ("Chart Test!");
	var button1 = new Button.with_label("Separate axes");
	var button2 = new Button.with_label("Joint X axes");
	var button3 = new Button.with_label("Joint Y axes");
	var button4 = new Button.with_label("Dates/Times");
	var button5 = new Button.with_label("rm Axis Titles");
	var button6 = new Button.with_label("Dates only");
	var button7 = new Button.with_label("Times only");
	var button8 = new Button.with_label("Date+Time");

	plot_chart1 (chart1);
	plot_chart2 (chart2);
	plot_chart3 (chart3);
	plot_chart4 (chart4);

	chart1.selection_style = Line.Style(Color(0.3, 0.3, 0.3, 0.7), 1);

	var da = new DrawingArea();
	da.set_events ( Gdk.EventMask.BUTTON_PRESS_MASK
	               |Gdk.EventMask.BUTTON_RELEASE_MASK
	               |Gdk.EventMask.POINTER_MOTION_MASK
	);

	var chart = chart1;

	var radio_button1 = new RadioButton.with_label (null, "Top Legend");
	var radio_button2 = new RadioButton.with_label (radio_button1.get_group(), "Right Legend");
	var radio_button3 = new RadioButton.with_label_from_widget (radio_button1, "Left Legend");
	var radio_button4 = new RadioButton.with_label_from_widget (radio_button1, "Bottom Legend");
	var radio_button7 = new RadioButton.with_label (null, "Vertical Cursors");
	var radio_button8 = new RadioButton.with_label_from_widget (radio_button7, "Horizontal Cursors");

	button1.clicked.connect (() => {
			chart = chart1; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Legend.Position.TOP: radio_button1.set_active(true); break;
			case Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			}
			switch (chart.cursor_style.orientation) {
			case Cursors.Orientation.VERTICAL: radio_button7.set_active(true); break;
			case Cursors.Orientation.HORIZONTAL: radio_button8.set_active(true); break;
			}
	});
	button2.clicked.connect (() => {
			chart = chart2; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Legend.Position.TOP: radio_button1.set_active(true); break;
			case Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			}
			switch (chart.cursor_style.orientation) {
			case Cursors.Orientation.VERTICAL: radio_button7.set_active(true); break;
			case Cursors.Orientation.HORIZONTAL: radio_button8.set_active(true); break;
			}
	});
	button3.clicked.connect (() => {
			chart = chart3; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Legend.Position.TOP: radio_button1.set_active(true); break;
			case Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			}
			switch (chart.cursor_style.orientation) {
			case Cursors.Orientation.VERTICAL: radio_button7.set_active(true); break;
			case Cursors.Orientation.HORIZONTAL: radio_button8.set_active(true); break;
			}
	});
	button4.clicked.connect (() => {
			chart = chart4; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Legend.Position.TOP: radio_button1.set_active(true); break;
			case Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Legend.Position.LEFT: radio_button4.set_active(true); break;
			case Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			}
			switch (chart.cursor_style.orientation) {
			case Cursors.Orientation.VERTICAL: radio_button7.set_active(true); break;
			case Cursors.Orientation.HORIZONTAL: radio_button8.set_active(true); break;
			}
	});
	button5.clicked.connect (() => {
			for (var i = 0; i < chart.series.length; ++i) {
				var s = chart.series[i];
				s.axis_x.title.text = "";
				s.axis_y.title.text = "";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});
	button6.clicked.connect (() => {
			for (var i = 0; i < chart.series.length; ++i) {
				var s = chart.series[i];
				s.axis_x.date_format = "%Y.%m.%d";
				s.axis_x.time_format = "";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});

	button7.clicked.connect (() => {
			for (var i = 0; i < chart.series.length; ++i) {
				var s = chart.series[i];
				s.axis_x.date_format = "";
				s.axis_x.time_format = "%H:%M:%S";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});

	button8.clicked.connect (() => {
			for (var i = 0; i < chart.series.length; ++i) {
				var s = chart.series[i];
				s.axis_x.date_format = "%Y.%m.%d";
				s.axis_x.time_format = "%H:%M:%S";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});


	radio_button1.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Legend.Position.TOP;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button2.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Legend.Position.RIGHT;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button3.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Legend.Position.LEFT;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button4.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Legend.Position.BOTTOM;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});


/*	var radio_button5 = new RadioButton.with_label (null, "Labels");
	var radio_button6 = new RadioButton.with_label_from_widget (radio_button5, "Cursors");
	radio_button5.toggled.connect ((button) => {
		// TODO: set labels
		if (button.get_active()) {
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button6.toggled.connect ((button) => {
		// TODO: set cursors
		if (button.get_active()) {
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});*/

	radio_button7.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.cursor_style.orientation = Cursors.Orientation.VERTICAL;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button8.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.cursor_style.orientation = Cursors.Orientation.HORIZONTAL;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});

	MouseState mouse_state = MouseState.FREE;

	double sel_x0 = 0, sel_x1 = 0, sel_y0 = 0, sel_y1 = 0;
	double mov_x0 = 0, mov_y0 = 0;

	da.draw.connect((context) => {
		chart.context = context;
		chart.width = da.get_allocated_width();
		chart.height = da.get_allocated_height();
		chart.clear();

		// user's pre draw operations here...
		// ...

		/*var ret = */chart.draw();

	    // user's post draw operations here...
		if (mouse_state == MouseState.DRAW_SELECTION)
			chart.draw_selection (Cairo.Rectangle() {x = sel_x0, y = sel_y0, width = sel_x1 - sel_x0, height = sel_y1 - sel_y0});

		// show delta
		var str = chart.cursors2.get_cursors_delta_str(chart);
		if (str != "") {
			var text = "Δ = " + str;
			var text_t = new Text(text);
			var w = text_t.get_width(context);
			var h = text_t.get_height(context);
			var x0 = chart.plot_x_max - w - 5;
			var y0 = chart.plot_y_min + h + 5;
			chart.set_source_rgba(chart.legend.bg_color);
			context.rectangle (x0, y0 - h, w, h);
			context.fill();
			context.move_to (x0, y0);
			chart.set_source_rgba(chart.joint_axis_color);
			context.show_text(text);
		}

		return true;//ret;
	});

	da.button_press_event.connect((event) => {
		if (!point_in_chart(chart, event.x, event.y)) return true;

		switch (event.button) {
		case 1:  // start cursor position selection
			if ((event.state & Gdk.ModifierType.SHIFT_MASK) != 0) { // remove cursor
				chart.set_active_cursor (event.x, event.y, true);
				chart.remove_active_cursor();
				mouse_state = MouseState.FREE;
			} else { // add cursor
				chart.set_active_cursor (event.x, event.y);
				mouse_state = MouseState.CURSOR_SELECTION;
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			break;

		case 2:  // start zoom area selection
			sel_x0 = sel_x1 = event.x;
			sel_y0 = sel_y1 = event.y;
			mouse_state = MouseState.DRAW_SELECTION;
			break;

		case 3:  // start moving
			mov_x0 = event.x;
			mov_y0 = event.y;
			mouse_state = MouseState.MOVING_CHART;
			break;
		}

		return true; // return ret;
	});
	da.button_release_event.connect((event) => {

		if (!point_in_chart(chart, event.x, event.y)) return true;

		switch (event.button) {
		case 1:  // start cursor position selection
			if ((event.state & Gdk.ModifierType.SHIFT_MASK) != 0) { // remove cursor
				//chart.remove_active_cursor ();
				//da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
				//mouse_state = MouseState.FREE;
			} else { // add cursor
				chart.add_active_cursor ();
				mouse_state = MouseState.FREE;
			}
			break;

		case 2:
			sel_x1 = event.x;
			sel_y1 = event.y;
			if (sel_x1 > sel_x0 && sel_y1 > sel_y0)
				chart.zoom_in (Cairo.Rectangle(){x = sel_x0, y = sel_y0, width = sel_x1 - sel_x0, height = sel_y1 - sel_y0});
			else
				chart.zoom_out ();
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			mouse_state = MouseState.FREE;
			break;

		case 3:
			mouse_state = MouseState.FREE;
			break;
		}

		return true; // return ret;
	});
	da.motion_notify_event.connect((event) => {
		if (!point_in_chart(chart, event.x, event.y)) return true;

		switch (mouse_state) {
		case MouseState.DRAW_SELECTION:
			sel_x1 = event.x;
			sel_y1 = event.y;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			break;

		case MouseState.MOVING_CHART:
			var delta_x = event.x - mov_x0, delta_y = event.y - mov_y0;
			chart.move (Point(){x = delta_x, y = delta_y});
			mov_x0 = event.x;
			mov_y0 = event.y;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			break;

		case MouseState.CURSOR_SELECTION:
			chart.set_active_cursor (event.x, event.y);
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			break;
		}

		return true; // return ret;
	});
	da.add_events(Gdk.EventMask.SCROLL_MASK);
	da.scroll_event.connect((event) => {

		//var ret = chart.scroll_notify_event(event);

		return true; // return ret;
	});

	var vbox2 = new Box(Orientation.VERTICAL, 0);
	vbox2.pack_start(button1, false, false, 0);
	vbox2.pack_start(button2, false, false, 0);
	vbox2.pack_start(button3, false, false, 0);
	vbox2.pack_start(button4, false, false, 0);
	vbox2.pack_start(button5, false, false, 0);
	vbox2.pack_start(button6, false, false, 0);
	vbox2.pack_start(button7, false, false, 0);
	vbox2.pack_start(button8, false, false, 0);
	vbox2.pack_start(radio_button1, false, false, 0);
	vbox2.pack_start(radio_button2, false, false, 0);
	vbox2.pack_start(radio_button3, false, false, 0);
	vbox2.pack_start(radio_button4, false, false, 0);
	//vbox2.pack_start(radio_button5, false, false, 0);
	//vbox2.pack_start(radio_button6, false, false, 0);
	vbox2.pack_start(radio_button7, false, false, 0);
	vbox2.pack_start(radio_button8, false, false, 0);

	var hbox = new Box(Orientation.HORIZONTAL, 0);
	hbox.pack_start(da, true, true, 0);
	hbox.pack_end(vbox2, false, false, 0);

	var vbox = new Box(Orientation.VERTICAL, 0);
	vbox.pack_start(label, false, false, 0);
	vbox.pack_end(hbox, true, true, 0);

	window.add(vbox);

	window.show_all();

	Gtk.main();
	return 0;
}
