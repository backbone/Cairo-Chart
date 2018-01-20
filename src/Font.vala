namespace CairoChart {

	/**
	 * ``Font`` style.
	 */
	public struct Font {

		/**
		 * A font family name, encoded in UTF-8.
		 */
		string family;

		/**
		 * The new font size, in user space units.
		 */
		double size;

		/**
		 * The slant for the font.
		 */
		Cairo.FontSlant slant;

		/**
		 * The weight for the font.
		 */
		Cairo.FontWeight weight;

		/**
		 * Font/Text orientation.
		 */
		Gtk.Orientation orient;

		/**
		 * Constructs a new ``Font``.
		 * @param family a font family name, encoded in UTF-8.
		 * @param size the new font size, in user space units.
		 * @param slant the slant for the font.
		 * @param weight the weight for the font.
		 * @param orient font/text orientation.
		 */
		public Font (string family = "Sans",
		              double size = 10,
		              Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
		              Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
		              Gtk.Orientation orient = Gtk.Orientation.HORIZONTAL
		) {
			this.family = family;
			this.size = size;
			this.slant = slant;
			this.weight = weight;
			this.orient = orient;
		}
	}
}
