namespace CairoChart {

	/**
	 * Linear range.
	 */
	public class Range {

		double _low = 0;
		double _high = 1;
		double _zlow = 0;
		double _zhigh = 1;

		/**
		 * Low bound.
		 */
		public double low {
			get {
				return _low;
			}
			set {
				_zlow = _low = value;
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
				_zhigh = _high = value;
			}
		}

		/**
		 * Zoomed low bound.
		 */
		double zlow {
			get {
				return _zlow;
			}
			set {
				if (_low <= value <= _high)
					_zlow = value;
			}
		}

		/**
		 * Zoomed high bound.
		 */
		double zhigh {
			get {
				return _zhigh;
			}
			set {
				if (_low <= value <= _high)
					_zhigh = value;
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
				_zhigh = _high = _low + value;
			}
		}

		/**
		 * ``Range`` zoomed value.
		 */
		public double zrange {
			get {
				return _zhigh - _zlow;
			}
			set {
				if (_zlow <= _zlow + value <= _high)
					_zhigh = _zlow + value;
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
			_zlow = low;
			_zhigh = high;
		}
	}
}
