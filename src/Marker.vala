namespace CairoChart {

	public class Marker {

		public static void draw_at_pos (Chart chart,
		                                Series.MarkerType marker_type,
		                                double x,
		                                double y,
		                                double marker_size = 8.0) {
			chart.context.move_to (x, y);
			switch (marker_type) {
			case Series.MarkerType.SQUARE:
				chart.context.rectangle (x - marker_size / 2, y - marker_size / 2,
				                   marker_size, marker_size);
				chart.context.fill();
				break;

			case Series.MarkerType.CIRCLE:
				chart.context.arc (x, y, marker_size / 2, 0, 2*Math.PI);
				chart.context.fill();
				break;

			case Series.MarkerType.TRIANGLE:
				chart.context.move_to (x - marker_size / 2, y - marker_size / 2);
				chart.context.line_to (x + marker_size / 2, y - marker_size / 2);
				chart.context.line_to (x, y + marker_size / 2);
				chart.context.line_to (x - marker_size / 2, y - marker_size / 2);
				chart.context.fill();
				break;

			case Series.MarkerType.PRICLE_SQUARE:
				chart.context.rectangle (x - marker_size / 2, y - marker_size / 2,
				                   marker_size, marker_size);
				chart.context.stroke();
				break;

			case Series.MarkerType.PRICLE_CIRCLE:
				chart.context.arc (x, y, marker_size / 2, 0, 2*Math.PI);
				chart.context.stroke();
				break;

			case Series.MarkerType.PRICLE_TRIANGLE:
				chart.context.move_to (x - marker_size / 2, y - marker_size / 2);
				chart.context.line_to (x + marker_size / 2, y - marker_size / 2);
				chart.context.line_to (x, y + marker_size / 2);
				chart.context.line_to (x - marker_size / 2, y - marker_size / 2);
				chart.context.stroke();
				break;
			}
		}
	}
}


