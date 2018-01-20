namespace CairoChart {

	/**
	 * Text font.
	 */
	public class Font {

		/**
		 * ``Font`` orientation.
		 */
		public enum Orientation {

			/**
			 * Horizontal font/text orientation.
			 */
			HORIZONTAL = 0,

			/**
			 * Vertical font/text orientation.
			 */
			VERTICAL
		}

		/**
		 * ``Font`` Style.
		 */
		public struct Style {

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
			Orientation orientation;

			/**
			 * Constructs a new ``Style``.
			 * @param family a font family name, encoded in UTF-8.
			 * @param size the new font size, in user space units.
			 * @param slant the slant for the font.
			 * @param weight the weight for the font.
			 * @param orientation font/text orientation.
			 */
			public Style (string family = "Sans",
			              double size = 10,
			              Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
			              Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
			              Font.Orientation orientation = Font.Orientation.HORIZONTAL
			) {
				this.family = family;
				this.size = size;
				this.slant = slant;
				this.weight = weight;
				this.orientation = orientation;
			}
		}

		private Font () { }
	}
}
