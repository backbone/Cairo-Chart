namespace CairoChart {

	/**
	 * ``Font`` direction.
	 */
	public enum FontDirect {

		/**
		 * Horizontal font/text direction.
		 */
		HORIZONTAL = 0,

		/**
		 * Vertical font/text direction.
		 */
		VERTICAL
	}

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
		 * Font/Text direction.
		 */
		FontDirect direct;

		/**
		 * Constructs a new ``Font``.
		 * @param family a font family name, encoded in UTF-8.
		 * @param size the new font size, in user space units.
		 * @param slant the slant for the font.
		 * @param weight the weight for the font.
		 * @param direct font/text direction.
		 */
		public Font (string family = "Sans",
		              double size = 10,
		              Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
		              Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
		              FontDirect direct = FontDirect.HORIZONTAL
		) {
			this.family = family;
			this.size = size;
			this.slant = slant;
			this.weight = weight;
			this.direct = direct;
		}
	}
}
