namespace Gtk.CairoChart {
	public class Grid {
		/*public enum GridType {
			PRICK_LINE = 0, // default
			LINE
		}*/
		public Color color = Color (0, 0, 0, 0.1);

		public LineStyle line_style = new LineStyle ();

		public Grid () {
			line_style.dashes = {2, 3};
		}
	}
}
