namespace CairoChart {

	/**
	 * 64-bit point.
	 */
	public struct Point {

		/**
		 * X-coordinate.
		 */
		double x;

		/**
		 * Y-coordinate.
		 */
		double y;

		/**
		 * Constructs a new ``Point``.
		 * @param x x-coordinate.
		 * @param y y-coordinate.
		 */
		public Point (double x = 0, double y = 0) {
			this.x = x; this.y = y;
		}
	}

	/**
	 * 128-bit point.
	 */
	public struct Point128 {

		/**
		 * X-coordinate.
		 */
		Float128 x;

		/**
		 * Y-coordinate.
		 */
		Float128 y;

		/**
		 * Constructs a new ``Point128``.
		 * @param x x-coordinate.
		 * @param y y-coordinate.
		 */
		public Point128 (Float128 x = 0, Float128 y = 0) {
			this.x = x; this.y = y;
		}
	}
}
