namespace CairoChart {

	/**
	 * Linear range.
	 */
	public class Range {

		Float128 _min = 0;
		Float128 _max = 1;

		/**
		 * Zoomed min bound.
		 */
		public Float128 zmin = 0;

		/**
		 * Zoomed max bound.
		 */
		public Float128 zmax = 1;

		/**
		 * Low bound.
		 */
		public Float128 min {
			get {
				return _min;
			}
			set {
				zmin = _min = value;
			}
		}

		/**
		 * High bound.
		 */
		public Float128 max {
			get {
				return _max;
			}
			set {
				zmax = _max = value;
			}
		}

		/**
		 * ``Range`` value.
		 */
		public Float128 range {
			get {
				return _max - _min;
			}
			set {
				zmax = _max = _min + value;
			}
		}

		/**
		 * ``Range`` zoomed value.
		 */
		public Float128 zrange {
			get {
				return zmax - zmin;
			}
			set {
				zmax = zmin + value;
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
			this.min = range.min;
			this.max = range.max;
		}

		/**
		 * Constructs a new ``Range`` with absolute coordinates.
		 */
		public Range.with_abs (Float128 min, Float128 max) {
			this.min = min;
			this.max = max;
		}

		/**
		 * Constructs a new ``Range`` with relative coordinates.
		 */
		public Range.with_rel (Float128 min, Float128 range) {
			this.min = min;
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
			zmin = min;
			zmax = max;
		}
	}
}
