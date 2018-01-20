namespace CairoChart {

	/**
	 *
	 */
	[Compact]
	public class Rect {

		/**
		 *
		 */
		public double x0 = 0;

		/**
		 *
		 */
		public double x1 = 1;

		/**
		 *
		 */
		public double y0 = 0;

		/**
		 *
		 */
		public double y1 = 1;

		/**
		 *
		 */
		public double width {
			get {
				return x1 - x0;
			}
			protected set {
				width = value;
				x1 = x0 + width;
			}
		}

		/**
		 *
		 */
		public double height {
			get {
				return y1 - y0;
			}
			protected set {
				width = value;
				y1 = y0 + height;
			}
		}

		/**
		 *
		 */
		Rect () { }

		/**
		 *
		 */
		Rect.with_abs () {
		}

		/**
		 *
		 */
		Rect.with_rel () {
		}
	}
}
