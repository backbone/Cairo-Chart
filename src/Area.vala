namespace CairoChart {

	/**
	 * Area rectangle.
	 */
	public class Area {

		double _x0 = 0;
		double _x1 = 1;
		double _y0 = 0;
		double _y1 = 1;
		double _zx0 = 0;
		double _zx1 = 1;
		double _zy0 = 0;
		double _zy1 = 1;

		/**
		 * Left bound.
		 */
		public double x0 {
			get {
				return _x0;
			}
			set {
				_zx0 = _x0 = value;
			}
		}

		/**
		 * Top bound.
		 */
		public double y0 {
			get {
				return _y0;
			}
			set {
				_zy0 = _y0 = value;
			}
		}

		/**
		 * Right bound.
		 */
		public double x1 {
			get {
				return _x1;
			}
			set {
				_zx1 = _x1 = value;
			}
		}

		/**
		 * Bottom bound.
		 */
		public double y1 {
			get {
				return _y1;
			}
			set {
				_zy1 = _y1 = value;
			}
		}

		/**
		 * Zoomed Left bound.
		 */
		public double zx0 {
			get {
				return _zx0;
			}
			set {
				if (_x0 <= value <= _x1)
					_zx0 = value;
			}
		}

		/**
		 * Zoomed Top bound.
		 */
		public double zy0 {
			get {
				return _zy0;
			}
			set {
				if (_y0 <= value <= _y1)
					_zy0 = value;
			}
		}

		/**
		 * Zoomed Right bound.
		 */
		public double zx1 {
			get {
				return _zx1;
			}
			set {
				if (_x0 <= value <= _x1)
					_zx1 = value;
			}
		}

		/**
		 * Zoomed Bottom bound.
		 */
		public double zy1 {
			get {
				return _zy1;
			}
			set {
				if (_y0 <= value <= _y1)
					_zy1 = value;
			}
		}

		/**
		 * ``Area`` width.
		 */
		public double width {
			get {
				return _x1 - _x0;
			}
			set {
				_zx1 = _x1 = _x0 + value;
			}
		}

		/**
		 * ``Area`` height.
		 */
		public double height {
			get {
				return _y1 - _y0;
			}
			set {
				_zy1 = _y1 = _y0 + value;
			}
		}

		/**
		 * ``Area`` zoomed width.
		 */
		public double zwidth {
			get {
				return _zx1 - _zx0;
			}
			set {
				if (_zx0 <= _zx0 + value <= _x1)
					_zx1 = _zx0 + value;
			}
		}

		/**
		 * ``Area`` zoomed height.
		 */
		public double zheight {
			get {
				return _zy1 - _zy0;
			}
			set {
				if (_zy0 <= _zy0 + value <= _y1)
					_zy1 = _zy0 + value;
			}
		}

		/**
		 * Constructs a new ``Area``.
		 */
		public Area () { }

		/**
		 * Constructs a new ``Area`` with absolute coordinates.
		 * @param x0 left bound.
		 * @param y0 top bound.
		 * @param x1 right bound.
		 * @param y1 bottom bound.
		 */
		public Area.with_abs (double x0, double y0, double x1, double y1) {
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
		}

		/**
		 * Constructs a new ``Area`` with relative coordinates.
		 * @param x0 left bound.
		 * @param y0 top bound.
		 * @param width ``Area`` width.
		 * @param height ``Area`` height.
		 */
		public Area.with_rel (double x0, double y0, double width, double height) {
			this.x0 = x0;
			this.y0 = y0;
			this.width = width;
			this.height = height;
		}

		/**
		 * Constructs a new ``Area`` by other ``Area``.
		 * @param area ``Area`` instance.
		 */
		public Area.with_area (Area area) {
			this.x0 = area.x0;
			this.y0 = area.y0;
			this.x1 = area.x1;
			this.y1 = area.y1;
		}

		/**
		 * Constructs a new ``Area`` by ``Cairo.Rectangle``.
		 * @param rectangle ``Cairo.Rectangle`` instance.
		 */
		public Area.with_rectangle (Cairo.Rectangle rectangle) {
			this.x0 = rectangle.x;
			this.y0 = rectangle.y;
			this.width = rectangle.width;
			this.height = rectangle.height;
		}

		/**
		 * Gets a copy of the ``Chart``.
		 */
		public Area copy () {
			return new Area.with_area(this);
		}

		/**
		 * Unzooms ``Area``.
		 */
		public void unzoom () {
			_zx0 = x0;
			_zy0 = y0;
			_zx1 = x1;
			_zy1 = y1;
		}
	}
}
