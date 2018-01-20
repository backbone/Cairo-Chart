namespace CairoChart {

	/**
	 * Linear range.
	 */
	[Compact]
	public class Range {

		/**
		 * Low bound.
		 */
		public double low = 0;

		/**
		 * High bound.
		 */
		public double high = 1;

		/**
		 * ``Range`` value.
		 */
		public double range {
			get {
				return high - low;
			}
			set {
				high = low + value;
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
	}
}
