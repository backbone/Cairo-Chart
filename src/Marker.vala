namespace CairoChart {

	/**
	 * {@link Series} Marker.
	 */
	public class Marker {

		Chart chart;

		/**
		 * ``Marker`` shape.
		 */
		public enum Shape {
			NONE = 0,
			SQUARE,
			CIRCLE,
			TRIANGLE,
			PRICLE_SQUARE,
			PRICLE_CIRCLE,
			PRICLE_TRIANGLE
		}

		/**
		 * ``Marker`` shape.
		 */
		public Shape type;

		/**
		 * ``Marker`` size.
		 */
		public double size;

		/**
		 * Constructs a new ``Marker``.
		 * @param type ``Marker`` shape.
		 * @param size ``Marker`` size.
		 */
		public Marker (Chart chart,
		               Shape type = Shape.NONE,
		               double size = 8.0
		) {
			this.chart = chart;
			this.type = type;
			this.size = size;
		}

		/**
		 * Gets a copy of the ``Marker``.
		 */
		public virtual Marker copy () {
			return new Marker (chart, type, size);
		}

		/**
		 * Draws the ``Marker`` at specific position.
		 * @param p coordinates.
		 */
		public virtual void draw_at_pos (Point p) {
			chart.ctx.move_to (p.x, p.y);
			switch (type) {
			case Shape.SQUARE:
				chart.ctx.rectangle (p.x - size / 2, p.y - size / 2, size, size);
				chart.ctx.fill();
				break;

			case Shape.CIRCLE:
				chart.ctx.arc (p.x, p.y, size / 2, 0, 2 * GLib.Math.PI);
				chart.ctx.fill();
				break;

			case Shape.TRIANGLE:
				chart.ctx.move_to (p.x - size / 2, p.y - size / 2);
				chart.ctx.rel_line_to (size, 0);
				chart.ctx.rel_line_to (-size / 2, size);
				chart.ctx.rel_line_to (-size / 2, -size);
				chart.ctx.fill();
				break;

			case Shape.PRICLE_SQUARE:
				chart.ctx.rectangle (p.x - size / 2, p.y - size / 2, size, size);
				chart.ctx.stroke();
				break;

			case Shape.PRICLE_CIRCLE:
				chart.ctx.arc (p.x, p.y, size / 2, 0, 2 * GLib.Math.PI);
				chart.ctx.stroke();
				break;

			case Shape.PRICLE_TRIANGLE:
				chart.ctx.move_to (p.x - size / 2, p.y - size / 2);
				chart.ctx.rel_line_to (size, 0);
				chart.ctx.rel_line_to (-size / 2, size);
				chart.ctx.rel_line_to (-size / 2, -size);
				chart.ctx.stroke();
				break;
			}
		}
	}
}
