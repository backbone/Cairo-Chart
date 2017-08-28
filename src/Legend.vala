namespace Gtk.CairoChart {
	public class Legend {
		public enum Position {
			TOP = 0,	// default
			LEFT,
			RIGHT,
			BOTTOM
		}
		public Position position = Position.TOP;
		public FontStyle font_style = FontStyle();
		public Color bg_color = Color(1, 1, 1);
		public LineStyle border_style = new LineStyle ();
		public double indent = 5;

		public Legend () {
			border_style.color = Color (0, 0, 0, 0.3);
		}
	}
}
