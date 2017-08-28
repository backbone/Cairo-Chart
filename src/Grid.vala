namespace Gtk.CairoChart {
	public class Grid {
		/*public enum GridType {
			PRICK_LINE = 0, // default
			LINE
		}*/
		public Color color = Color (0, 0, 0, 0.1);

		public LineStyle line_style = LineStyle ();

		public Grid copy () {
			var grid = new Grid ();
			grid.color = this.color;
			grid.line_style = this.line_style;
			return grid;
		}

		public Grid () {
			line_style.dashes = {2, 3};
		}
	}
}
