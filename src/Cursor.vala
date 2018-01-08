namespace CairoChart {

	public class Cursor {

		public enum Orientation {
			VERTICAL = 0,  // default
			HORIZONTAL
		}

		public struct Style {

			public Orientation orientation;
			public double select_distance;
			public Line.Style line_style;

			public Style () {
				orientation = Orientation.VERTICAL;
				select_distance = 32;
				line_style = Line.Style(Color(0.2, 0.2, 0.2, 0.8));
			}
		}
	}
}
