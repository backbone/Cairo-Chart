namespace Gtk.CairoChart {
	public struct LineStyle {
		double width;
		Cairo.LineJoin line_join;
		Cairo.LineCap line_cap;
		double[]? dashes;
		double dash_offset;
		Color color;

		public LineStyle (double width = 1,
		                  Cairo.LineJoin line_join = Cairo.LineJoin.MITER,
		                  Cairo.LineCap line_cap = Cairo.LineCap.ROUND,
		                  double[]? dashes = null, double dash_offset = 0,
		                  Color color = Color()) {
			this.width = width;
			this.line_join = line_join;
			this.line_cap = line_cap;
			this.dashes = dashes;
			this.dash_offset = dash_offset;
			this.color = color;
		}
	}
}
