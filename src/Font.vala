namespace CairoChart {

	public class Font {

		public enum Orientation {
			HORIZONTAL = 0,
			VERTICAL
		}

		public struct Style {
			string family;
			Cairo.FontSlant slant;
			Cairo.FontWeight weight;

			Orientation orientation;
			double size;

			public Style (string family = "Sans",
			                  Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
			                  Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
			                  double size = 10,
			                  Font.Orientation orientation = Font.Orientation.HORIZONTAL) {
				this.family = family;
				this.slant = slant;
				this.weight = weight;
				this.size = size;
				this.orientation = orientation;
			}
		}
	}
}
