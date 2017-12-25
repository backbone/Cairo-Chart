namespace Gtk.CairoChart {
	public enum FontOrient {
			HORIZONTAL = 0,
			VERTICAL
	}

	public struct FontStyle {
		string family;
		Cairo.FontSlant slant;
		Cairo.FontWeight weight;

		FontOrient orientation;
		double size;

		public FontStyle (string family = "Sans",
		                  Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
		                  Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
		                  double size = 10,
		                  FontOrient orientation = FontOrient.HORIZONTAL) {
			this.family = family;
			this.slant = slant;
			this.weight = weight;
			this.size = size;
			this.orientation = orientation;
		}
	}
}
