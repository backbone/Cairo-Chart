public class Gtk.Chart {
	public Chart () {
	}

	public virtual signal bool draw(Cairo.Context context) {

		double width = context.copy_clip_rectangle_list().rectangles[0].width;
		double height = context.copy_clip_rectangle_list().rectangles[0].height;

		// Line width
		context.set_line_width (1);

		// Axis
		context.move_to (30,  30);
		context.line_to (30, height - 30);
		context.line_to (width - 30, height - 30);
		context.stroke ();

		// Arrows (X)
		context.move_to (width - 40,  height - 35);
		context.line_to (width - 30,  height - 30);
		context.line_to (width - 40,  height - 25);
		context.stroke ();

		// Arrows (Y)
		context.move_to (25,  40);
		context.line_to (30,  30);
		context.line_to (35,  40);
		context.stroke ();

		// Text:
		context.set_source_rgb (0.1, 0.1, 0.1);
		context.select_font_face ("Adventure", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
		context.set_font_size (20);
		context.move_to (10, 40);
		context.show_text ("Y");
		context.move_to (width - 45, height - 7);
		context.show_text ("X");

		// Grid (X)

		// Grid (Y)

		// Marks (X)

		// Marks (Y)

		// Legend


		return true;
	}
}
