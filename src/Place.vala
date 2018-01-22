namespace CairoChart {

	/**
	 * Place rectangle.
	 */
	public class Place {

		double _x0 = 0;
		double _x1 = 1;
		double _y0 = 0;
		double _y1 = 1;

		/**
		 * Zoomed Left bound.
		 */
		public double zx0 = 0;

		/**
		 * Zoomed Top bound.
		 */
		public double zx1 = 1;

		/**
		 * Zoomed Right bound.
		 */
		public double zy0 = 0;

		/**
		 * Zoomed Bottom bound.
		 */
		public double zy1 = 1;

		/**
		 * Left bound.
		 */
		public virtual double x0 {
			get {
				return _x0;
			}
			set {
				zx0 = _x0 = value;
			}
		}

		/**
		 * Top bound.
		 */
		public virtual double y0 {
			get {
				return _y0;
			}
			set {
				zy0 = _y0 = value;
			}
		}

		/**
		 * Right bound.
		 */
		public virtual double x1 {
			get {
				return _x1;
			}
			set {
				zx1 = _x1 = value;
			}
		}

		/**
		 * Bottom bound.
		 */
		public virtual double y1 {
			get {
				return _y1;
			}
			set {
				zy1 = _y1 = value;
			}
		}

		/**
		 * ``Place`` width.
		 */
		public virtual double width {
			get {
				return _x1 - _x0;
			}
			set {
				zx1 = _x1 = _x0 + value;
			}
		}

		/**
		 * ``Place`` height.
		 */
		public virtual double height {
			get {
				return _y1 - _y0;
			}
			set {
				zy1 = _y1 = _y0 + value;
			}
		}

		/**
		 * ``Place`` zoomed width.
		 */
		public virtual double zwidth {
			get {
				return zx1 - zx0;
			}
			set {
				zx1 = zx0 + value;
			}
		}

		/**
		 * ``Place`` zoomed height.
		 */
		public virtual double zheight {
			get {
				return zy1 - zy0;
			}
			set {
				zy1 = zy0 + value;
			}
		}

		/**
		 * Constructs a new ``Place``.
		 */
		public Place () { }

		/**
		 * Constructs a new ``Place`` by other ``Place``.
		 * @param place ``Place`` instance.
		 */
		public Place.with_place (Place place) {
			this.x0 = place.x0;
			this.y0 = place.y0;
			this.x1 = place.x1;
			this.y1 = place.y1;
		}

		/**
		 * Constructs a new ``Place`` with absolute coordinates.
		 * @param x0 left bound.
		 * @param y0 top bound.
		 * @param x1 right bound.
		 * @param y1 bottom bound.
		 */
		public Place.with_abs (double x0, double y0, double x1, double y1) {
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
		}

		/**
		 * Constructs a new ``Place`` with relative coordinates.
		 * @param x0 left bound.
		 * @param y0 top bound.
		 * @param width ``Place`` width.
		 * @param height ``Place`` height.
		 */
		public Place.with_rel (double x0, double y0, double width, double height) {
			this.x0 = x0;
			this.y0 = y0;
			this.width = width;
			this.height = height;
		}

		/**
		 * Constructs a new ``Place`` by ``Cairo.Rectangle``.
		 * @param rectangle ``Cairo.Rectangle`` instance.
		 */
		public Place.with_rectangle (Cairo.Rectangle rectangle) {
			this.x0 = rectangle.x;
			this.y0 = rectangle.y;
			this.width = rectangle.width;
			this.height = rectangle.height;
		}

		/**
		 * Gets a copy of the ``Chart``.
		 */
		public virtual Place copy () {
			return new Place.with_place(this);
		}

		/**
		 * Unzooms ``Place``.
		 */
		public virtual void unzoom () {
			zx0 = x0;
			zy0 = y0;
			zx1 = x1;
			zy1 = y1;
		}
	}
}
