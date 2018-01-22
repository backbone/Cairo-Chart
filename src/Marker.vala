namespace CairoChart {

	/**
	 * {@link Series} Marker.
	 */
	public class Marker {

		Chart chart = null;

		/**
		 * ``Marker`` shape.
		 */
		public enum Type {
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
		public Type type = Type.NONE;

		/**
		 * ``Marker`` size.
		 */
		public double size = 8.0;

		/**
		 * Constructs a new ``Marker``.
		 * @param type ``Marker`` shape.
		 * @param size ``Marker`` size.
		 */
		public Marker (Chart chart,
		               Type type = Type.NONE,
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
		 * @param x x-coordinate.
		 * @param y y-coordinate.
		 */
		public virtual void draw_at_pos (double x, double y) {
			chart.ctx.move_to (x, y);
			switch (type) {
			case Type.SQUARE:
				chart.ctx.rectangle (x - size / 2, y - size / 2, size, size);
				chart.ctx.fill();
				break;

			case Type.CIRCLE:
				chart.ctx.arc (x, y, size / 2, 0, 2 * GLib.Math.PI);
				chart.ctx.fill();
				break;

			case Type.TRIANGLE:
				chart.ctx.move_to (x - size / 2, y - size / 2);
				chart.ctx.rel_line_to (size, 0);
				chart.ctx.rel_line_to (-size / 2, size);
				chart.ctx.rel_line_to (-size / 2, -size);
				chart.ctx.fill();
				break;

			case Type.PRICLE_SQUARE:
				chart.ctx.rectangle (x - size / 2, y - size / 2,
				                   size, size);
				chart.ctx.stroke();
				break;

			case Type.PRICLE_CIRCLE:
				chart.ctx.arc (x, y, size / 2, 0, 2 * GLib.Math.PI);
				chart.ctx.stroke();
				break;

			case Type.PRICLE_TRIANGLE:
				chart.ctx.move_to (x - size / 2, y - size / 2);
				chart.ctx.line_to (x + size / 2, y - size / 2);
				chart.ctx.line_to (x, y + size / 2);
				chart.ctx.line_to (x - size / 2, y - size / 2);
				chart.ctx.stroke();
				break;
			}
		}
	}
}
