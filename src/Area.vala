namespace CairoChart {

	/**
	 * Area rectangle.
	 */
	public class Area {

		/**
		 * Left bound.
		 */
		public double x0 = 0;

		/**
		 * Top bound.
		 */
		public double x1 = 1;

		/**
		 * Right bound.
		 */
		public double y0 = 0;

		/**
		 * Bottom bound.
		 */
		public double y1 = 1;

		/**
		 * ``Area`` width.
		 */
		public virtual double width {
			get {
				return x1 - x0;
			}
			set {
				x1 = x0 + value;
			}
		}

		/**
		 * ``Area`` height.
		 */
		public virtual double height {
			get {
				return y1 - y0;
			}
			set {
				y1 = y0 + value;
			}
		}

		/**
		 * Constructs a new ``Area``.
		 */
		public Area () { }

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
		 * Constructs a new ``Area`` by 2 points.
		 * @param p0 top left position.
		 * @param p1 bottom right position.
		 */
		public Area.with_points (Point p0, Point p1) {
			this.x0 = p0.x;
			this.y0 = p0.y;
			this.x1 = p1.x;
			this.y1 = p1.y;
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
		public virtual Area copy () {
			return new Area.with_area(this);
		}
	}
}
