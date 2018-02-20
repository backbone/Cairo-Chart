namespace CairoChart {

	/**
	 * R/G/B/A Color.
	 */
	public struct Color {

		/**
		 * Red component.
		 */
		double red;

		/**
		 * Green component.
		 */
		double green;

		/**
		 * Blue component.
		 */
		double blue;

		/**
		 * Alpha component.
		 */
		double alpha;

		/**
		 * Constructs a new ``Color``.
		 * @param red red component.
		 * @param green green component.
		 * @param blue blue component.
		 * @param alpha alpha component.
		 */
		public Color (double red = 0,
		              double green = 0,
		              double blue = 0,
		              double alpha = 1
		) {
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		}
	}
}
