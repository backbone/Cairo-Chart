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
		public LineStyle border_style = LineStyle ();
		public double indent = 5;

		public Legend copy () {
			var legend = new Legend ();
			legend.position = this.position;
			legend.font_style = this.font_style;
			legend.bg_color = this.bg_color;
			legend.indent = this.indent;
			return legend;
		}

		public Legend () {
			border_style.color = Color (0, 0, 0, 0.3);
		}
	}
}
