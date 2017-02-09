using Gtk;

int main (string[] args) {
    init (ref args);

    var window = new Window ();
    window.title = "Gtk.Chart Test.";
    window.border_width = 10;
    window.window_position = WindowPosition.CENTER;
    window.set_default_size (640, 480);
    window.destroy.connect (main_quit);

    var da = new DrawingArea();
    var chart = new Gtk.Chart();
    var label = new Label ("Gtk.Chart Test!");
    var button = new Button.with_label("Click me");
    button.clicked.connect (() => {
		da.draw.connect((context) => {
			chart.draw(context);
			return true;
		});

		da.queue_draw_area(0, 0, da.get_allocated_width(), da.get_allocated_height());
	});

    var vbox2 = new Box(Orientation.VERTICAL, 0);
    vbox2.pack_end(button, false, false, 0);

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
