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
		 */
		public Color (double red = 0.0,
		              double green = 0.0,
		              double blue = 0.0,
		              double alpha = 1.0) {
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		}
	}
}
