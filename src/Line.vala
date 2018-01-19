namespace CairoChart {

	/**
	 * ``Chart`` line.
	 */
	public class Line {

		/**
		 * Line Style.
		 */
		public struct Style {

			/**
			 * Line color.
			 */
			Color color;

			/**
			 * A line width.
			 */
			double width;

			/**
			 * An array specifying alternate lengths of on and off stroke portions.
			 */
			double[]? dashes;

			/**
			 * An offset into the dash pattern at which the stroke should start.
			 */
			double dash_offset;
			/**
			 * A line join style.
			 */
			Cairo.LineJoin join;

			/**
			 * A line cap style.
			 */
			Cairo.LineCap cap;

			/**
			 * Constructs a new ``Style``.
			 * @param color line color.
			 * @param width a line width.
			 * @param dashes an array specifying alternate lengths of on and off stroke portions.
			 * @param dash_offset an offset into the dash pattern at which the stroke should start.
			 * @param join a line join style.
			 * @param cap a line cap style.
			 */
			public Style (Color color = Color(),
			              double width = 1,
			              double[]? dashes = null,
			              double dash_offset = 0,
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

			/**
			 * Applies current style to the {@link Chart} ``Context``.
			 */
			public void apply (Chart chart) {
				chart.color = color;
				chart.ctx.set_line_join(join);
				chart.ctx.set_line_cap(cap);
				chart.ctx.set_line_width(width);
				chart.ctx.set_dash(dashes, dash_offset);
			}
		}

		private Line () { }
	}
}
