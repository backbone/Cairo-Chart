namespace CairoChart {

	public class Marker {

		public enum Type {
			NONE = 0,	// default
			SQUARE,
			CIRCLE,
			TRIANGLE,
			PRICLE_SQUARE,
			PRICLE_CIRCLE,
			PRICLE_TRIANGLE
		}

		public Type type = Type.NONE;
		public double size = 8.0;

		public Marker (Type type = Type.NONE, double size = 8.0) {
			this.type = type;
			this.size = size;
		}

		public Marker copy () {
			return new Marker (type, size);
		}

		public virtual void draw_at_pos (Chart chart, double x, double y) {
			chart.context.move_to (x, y);
			switch (type) {
			case Type.SQUARE:
				chart.context.rectangle (x - size / 2, y - size / 2, size, size);
				chart.context.fill();
				break;

			case Type.CIRCLE:
				chart.context.arc (x, y, size / 2, 0, 2 * GLib.Math.PI);
				chart.context.fill();
				break;

			case Type.TRIANGLE:
				chart.context.move_to (x - size / 2, y - size / 2);
				chart.context.line_to (x + size / 2, y - size / 2);
				chart.context.line_to (x, y + size / 2);
				chart.context.line_to (x - size / 2, y - size / 2);
				chart.context.fill();
				break;

			case Type.PRICLE_SQUARE:
				chart.context.rectangle (x - size / 2, y - size / 2,
				                   size, size);
				chart.context.stroke();
				break;

			case Type.PRICLE_CIRCLE:
				chart.context.arc (x, y, size / 2, 0, 2 * GLib.Math.PI);
				chart.context.stroke();
				break;

			case Type.PRICLE_TRIANGLE:
				chart.context.move_to (x - size / 2, y - size / 2);
				chart.context.line_to (x + size / 2, y - size / 2);
				chart.context.line_to (x, y + size / 2);
				chart.context.line_to (x - size / 2, y - size / 2);
				chart.context.stroke();
				break;
			}
		}
	}
}


