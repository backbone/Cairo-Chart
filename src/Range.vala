namespace CairoChart {

	/**
	 * Linear range.
	 */
	public class Range {

		double _low = 0;
		double _high = 1;

		/**
		 * Zoomed low bound.
		 */
		double zlow = 0;

		/**
		 * Zoomed high bound.
		 */
		double zhigh = 1;

		/**
		 * Low bound.
		 */
		public double low {
			get {
				return _low;
			}
			set {
				zlow = _low = value;
			}
		}

		/**
		 * High bound.
		 */
		public double high {
			get {
				return _high;
			}
			set {
				zhigh = _high = value;
			}
		}

		/**
		 * ``Range`` value.
		 */
		public double range {
			get {
				return _high - _low;
			}
			set {
				zhigh = _high = _low + value;
			}
		}

		/**
		 * ``Range`` zoomed value.
		 */
		public double zrange {
			get {
				return zhigh - zlow;
			}
			set {
				zhigh = zlow + value;
			}
		}

		/**
		 * Constructs a new ``Range``.
		 */
		public Range () { }

		/**
		 * Constructs a new ``Range`` with a ``Range`` instance.
		 */
		public Range.with_range (Range range) {
			this.low = range.low;
			this.high = range.high;
		}

		/**
		 * Constructs a new ``Range`` with absolute coordinates.
		 */
		public Range.with_abs (double low, double high) {
			this.low = low;
			this.high = high;
		}

		/**
		 * Constructs a new ``Range`` with relative coordinates.
		 */
		public Range.with_rel (double low, double range) {
			this.low = low;
			this.range = range;
		}

		/**
		 * Gets a copy of the ``Range``.
		 */
		public Range copy () {
			return new Range.with_range(this);
		}

		/**
		 * Unzooms ``Range``.
		 */
		public void unzoom () {
			zlow = low;
			zhigh = high;
		}
	}
}
