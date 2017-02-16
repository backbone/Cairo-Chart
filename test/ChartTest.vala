using Gtk, CairoChart;

void plot_chart1 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();

	s1.title = new Text("Series 1"); s1.color = new Color (1, 0, 0);
	s1.points = {new Series.Point(0, 0), new Series.Point(2, 1), new Series.Point(1, 3)};
	s1.axis_x.position = Series.Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = new Color (0, 1, 0);
	s2.points = {new Series.Point(5, -3), new Series.Point(25, -18), new Series.Point(-11, 173)};
	s3.title = new Text("Series 3"); s3.color = new Color (0, 0, 1);
	s3.points = {new Series.Point(9, 17), new Series.Point(2, 10), new Series.Point(122, 31)};
	s3.axis_y.position = Series.Axis.Position.HIGH;

	s1.axis_x.min = 0; s1.axis_x.max = 2;
	s1.axis_y.min = 0; s1.axis_y.max = 3;
	s1.place.x_low = 0.25; s1.place.x_high = 0.75;
	s1.place.y_low = 0.3; s1.place.y_high = 0.9;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_low = 0.5; s2.place.x_high = 1;
	s2.place.y_low = 0.0; s2.place.y_high = 0.5;

	s3.axis_x.min = 0; s3.axis_x.max = 130;
	s3.axis_y.min = 15; s3.axis_y.max = 35;
	s3.place.x_low = 0; s3.place.x_high = 0.5;
	s3.place.y_low = 0.5; s3.place.y_high = 1.0;

	s2.marker_type = Series.MarkerType.CIRCLE;
	s3.marker_type = Series.MarkerType.PRICLE_TRIANGLE;

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

	s1.title = new Text("Series 1"); s1.color = new Color (1, 0, 0);
	s1.points = {new Series.Point(-12, 0), new Series.Point(2, 1), new Series.Point(20, 3)};
	s2.axis_y.position = Series.Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = new Color (0, 1, 0);
	s2.points = {new Series.Point(5, -3), new Series.Point(25, -18), new Series.Point(-11, 173)};
	s3.title = new Text("Series 3"); s3.color = new Color (0, 0, 1);
	s3.points = {new Series.Point(9, 17), new Series.Point(2, 10), new Series.Point(-15, 31)};
	s3.axis_y.position = Series.Axis.Position.HIGH;

	s1.axis_x.min = -15; s1.axis_x.max = 30;
	s1.axis_y.min = 0; s1.axis_y.max = 3;
	s1.place.x_low = 0.0; s1.place.x_high = 1.0;
	s1.place.y_low = 0.3; s1.place.y_high = 0.9;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_low = 0.0; s2.place.x_high = 1.0;
	s2.place.y_low = 0.0; s2.place.y_high = 0.5;

	s3.axis_x.min = -15; s3.axis_x.max = 30;
	s3.axis_y.min = 15; s3.axis_y.max = 35;
	s3.place.x_low = 0.0; s3.place.x_high = 1.0;
	s3.place.y_low = 0.5; s3.place.y_high = 1.0;

	s1.marker_type = Series.MarkerType.PRICLE_CIRCLE;
	s2.marker_type = Series.MarkerType.PRICLE_SQUARE;

	s1.axis_x.title = new Text("All Series: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("All Series: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("All Series: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");

	chart.series = { s1, s2, s3 };
}

void plot_chart3 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();

	s1.title = new Text("Series 1"); s1.color = new Color (1, 0, 0);
	s1.points = {new Series.Point(0, 70), new Series.Point(2, 155), new Series.Point(1, -3)};
	s1.axis_x.position = Series.Axis.Position.HIGH;
	s1.axis_y.position = Series.Axis.Position.HIGH;
	s1.axis_x.format = "%.3Lf";
	s2.title = new Text("Series 2"); s2.color = new Color (0, 1, 0);
	s2.points = {new Series.Point(5, -3), new Series.Point(25, -18), new Series.Point(-11, 173)};
	s2.axis_y.position = Series.Axis.Position.HIGH;
	s3.title = new Text("Series 3"); s3.color = new Color (0, 0, 1);
	s3.points = {new Series.Point(9, -17), new Series.Point(2, 10), new Series.Point(122, 31)};
	s3.axis_y.position = Series.Axis.Position.HIGH;

	s1.axis_x.min = 0; s1.axis_x.max = 2;
	s1.axis_y.min = -20; s1.axis_y.max = 200;
	s1.place.x_low = 0.25; s1.place.x_high = 0.75;
	s1.place.y_low = 0.0; s1.place.y_high = 1.0;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_low = 0.5; s2.place.x_high = 1;
	s2.place.y_low = 0.0; s2.place.y_high = 1.0;

	s3.axis_x.min = 0; s3.axis_x.max = 130;
	s3.axis_y.min = -20; s3.axis_y.max = 200;
	s3.place.x_low = 0; s3.place.x_high = 0.5;
	s3.place.y_low = 0.0; s3.place.y_high = 1.0;

	s2.marker_type = Series.MarkerType.PRICLE_CIRCLE;
	s3.marker_type = Series.MarkerType.TRIANGLE;

	s1.axis_x.title = new Text("Series 1: Axis X.");
	s1.axis_y.title = new Text("Series 1: Axis Y.");
	s2.axis_x.title = new Text("Series 2: Axis X.");
	s2.axis_y.title = new Text("Series 2: Axis Y.");
	s3.axis_x.title = new Text("Series 3: Axis X.");
	s3.axis_y.title = new Text("Series 3: Axis Y.");

	chart.series = { s1, s2, s3 };
}

void plot_chart4 (Chart chart) {
	var s1 = new Series ();
	var s2 = new Series ();
	var s3 = new Series ();
	var s4 = new Series ();

	s1.axis_x.type = Series.Axis.Type.DATE_TIME;
	s3.axis_x.type = Series.Axis.Type.DATE_TIME;
	s4.axis_x.type = Series.Axis.Type.DATE_TIME;
	s4.axis_x.dsec_signs = 5;

	var now = new DateTime.now_local().to_unix();
	var high = (uint64) (253000000000L);

	s1.title = new Text("Series 1"); s1.color = new Color (1, 0, 0);
	s1.points = {new Series.Point(now, 70), new Series.Point(now - 100000, 155), new Series.Point(now + 100000, 30)};
	s1.axis_x.position = Series.Axis.Position.HIGH;
	s1.axis_y.position = Series.Axis.Position.HIGH;
	s2.title = new Text("Series 2"); s2.color = new Color (0, 1, 0);
	s2.points = {new Series.Point(5, -3), new Series.Point(25, -18), new Series.Point(-11, 173)};
	s2.axis_y.position = Series.Axis.Position.HIGH;
	s3.title = new Text("Series 3"); s3.color = new Color (0, 0, 1);
	s3.points = {new Series.Point(high - 2 + 0.73, -17), new Series.Point(high - 1 + 0.234, 10), new Series.Point(high + 1 + 0.411, 31)};
	s3.axis_y.position = Series.Axis.Position.HIGH;
	s4.title = new Text("Series 4"); s4.color = new Color (0.5, 0.3, 0.9);
	s4.points = {new Series.Point(high + 0.005, -19.05), new Series.Point(high + 0.0051, 28), new Series.Point(high + 0.0052, 55), new Series.Point(high + 0.0053, 44)};
	s4.axis_y.position = Series.Axis.Position.HIGH;

	s1.axis_x.min = now - 100000; s1.axis_x.max = now + 100000;
	s1.axis_y.min = -20; s1.axis_y.max = 200;
	s1.place.x_low = 0.25; s1.place.x_high = 0.75;
	s1.place.y_low = 0.0; s1.place.y_high = 1.0;

	s2.axis_x.min = -15; s2.axis_x.max = 30;
	s2.axis_y.min = -20; s2.axis_y.max = 200;
	s2.place.x_low = 0.2; s2.place.x_high = 1;
	s2.place.y_low = 0.0; s2.place.y_high = 1.0;

	s3.axis_x.min = high - 2; s3.axis_x.max = high + 1;
	s3.axis_y.min = -20; s3.axis_y.max = 200;
	s3.place.x_low = 0; s3.place.x_high = 0.8;
	s3.place.y_low = 0.0; s3.place.y_high = 1.0;

	s4.axis_x.min = high + 0.0049; s4.axis_x.max = high + 0.0054;
	s4.axis_y.min = -20; s4.axis_y.max = 200;
	s4.place.x_low = 0.2; s4.place.x_high = 1.0;
	s4.place.y_low = 0.0; s4.place.y_high = 1.0;

	s2.marker_type = Series.MarkerType.PRICLE_CIRCLE;
	s3.marker_type = Series.MarkerType.TRIANGLE;
	s4.marker_type = Series.MarkerType.PRICLE_SQUARE;

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
	var label = new Label ("Chart Test!");
	var button1 = new Button.with_label("Separate axes");
	var button2 = new Button.with_label("Common X axes");
	var button3 = new Button.with_label("Common Y axes");
	var button4 = new Button.with_label("Dates/Times");
	var button5 = new Button.with_label("rm Axis Titles");
	var button6 = new Button.with_label("rm Dates");
	var button7 = new Button.with_label("rm Times");

	plot_chart1 (chart1);
	plot_chart2 (chart2);
	plot_chart3 (chart3);
	plot_chart4 (chart4);

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

	button1.clicked.connect (() => {
			chart = chart1; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Chart.Legend.Position.TOP: radio_button1.set_active(true); break;
			case Chart.Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Chart.Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Chart.Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			default: break;
			}
	});
	button2.clicked.connect (() => {
			chart = chart2; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Chart.Legend.Position.TOP: radio_button1.set_active(true); break;
			case Chart.Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Chart.Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Chart.Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			default: break;
			}
	});
	button3.clicked.connect (() => {
			chart = chart3; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Chart.Legend.Position.TOP: radio_button1.set_active(true); break;
			case Chart.Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Chart.Legend.Position.LEFT: radio_button3.set_active(true); break;
			case Chart.Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			default: break;
			}
	});
	button4.clicked.connect (() => {
			chart = chart4; da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
			switch (chart.legend.position) {
			case Chart.Legend.Position.TOP: radio_button1.set_active(true); break;
			case Chart.Legend.Position.RIGHT: radio_button2.set_active(true); break;
			case Chart.Legend.Position.LEFT: radio_button4.set_active(true); break;
			case Chart.Legend.Position.BOTTOM: radio_button4.set_active(true); break;
			default: break;
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
				s.axis_x.date_format = "";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});

	button7.clicked.connect (() => {
			for (var i = 0; i < chart.series.length; ++i) {
				var s = chart.series[i];
				s.axis_x.time_format = "";
			}
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});


	radio_button1.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Chart.Legend.Position.TOP;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button2.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Chart.Legend.Position.RIGHT;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button3.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Chart.Legend.Position.LEFT;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});
	radio_button4.toggled.connect ((button) => {
		if (button.get_active()) {
			chart.legend.position = Chart.Legend.Position.BOTTOM;
			da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
		}
	});

	da.draw.connect((context) => {
	    // user's pre draw operations here...
		chart.context = context;
		var ret = chart.draw();
	    // user's post draw operations here...
		return ret;
	});
	da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());

	da.button_release_event.connect((event) => {
	    // user's pre button_release_event operations here...
		var ret = chart.button_release_event(event);
	    // user's post button_release_event operations here...
		return ret;
	});
	da.button_press_event.connect((event) => {
	    // user's pre button_press_event operations here...
		var ret = chart.button_press_event(event);
	    // user's post button_press_event operations here...
		return ret;
	});
	da.motion_notify_event.connect((event) => {
	    // user's pre motion_notify_event operations here...
		var ret = chart.motion_notify_event(event);
	    // user's post motion_notify_event operations here...
		return ret;
	});

	var vbox2 = new Box(Orientation.VERTICAL, 0);
	vbox2.pack_start(button1, false, false, 0);
	vbox2.pack_start(button2, false, false, 0);
	vbox2.pack_start(button3, false, false, 0);
	vbox2.pack_start(button4, false, false, 0);
	vbox2.pack_start(button5, false, false, 0);
	vbox2.pack_start(button6, false, false, 0);
	vbox2.pack_start(button7, false, false, 0);
	vbox2.pack_start(radio_button1, false, false, 0);
	vbox2.pack_start(radio_button2, false, false, 0);
	vbox2.pack_start(radio_button3, false, false, 0);
	vbox2.pack_start(radio_button4, false, false, 0);

	var hbox = new Box(Orientation.HORIZONTAL, 0);
	hbox.pack_start(da, true, true, 0);
	hbox.pack_end(vbox2, false, false, 0);

	var vbox = new Box(Orientation.VERTICAL, 0);
	vbox.pack_start(label, false, false, 0);
	vbox.pack_end(hbox, true, true, 0);

	window.add(vbox);

	window.show_all();

Double128 d = 5.5;
	Gtk.main();
	return 0;
}
