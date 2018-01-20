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
			protected set {
				high = low + value;
			}
		}

		/**
		 * Constructs a new ``Range``.
		 */
		Range () { }

		/**
		 * Constructs a new ``Range`` with a ``Range`` instance.
		 */
		Range.with_range (Range range) {
			this.low = range.low;
			this.high = range.high;
		}

		/**
		 * Constructs a new ``Range`` with absolute coordinates.
		 */
		Range.with_abs (double low, double high) {
			this.low = low;
			this.high = high;
		}

		/**
		 * Constructs a new ``Range`` with relative coordinates.
		 */
		Range.with_rel (double low, double range) {
			this.low = low;
			this.high = low + range;
		}

		/**
		 * Gets a copy of the ``Range``.
		 */
		 public Range copy () {
			return new Range.with_range(this);
		 }
	}
}
