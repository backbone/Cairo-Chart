namespace CairoChart {

	public class Line {

		public struct Style {

			double width;
			Cairo.LineJoin join;
			Cairo.LineCap cap;
			double[]? dashes;
			double dash_offset;
			Color color;

			public Style (Color color = Color(),
			                  double width = 1,
			                  double[]? dashes = null, double dash_offset = 0,
			                  Cairo.LineJoin join = Cairo.LineJoin.MITER,
			                  Cairo.LineCap cap = Cairo.LineCap.ROUND
			                  ) {
				this.width = width;
				this.join = join;
				this.cap = cap;
				this.dashes = dashes;
				this.dash_offset = dash_offset;
				this.color = color;
			}
		}
	}
}