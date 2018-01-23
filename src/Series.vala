using Cairo;

namespace CairoChart {

	/**
	 * ``Chart`` series.
	 */
	public class Series {

		protected Chart chart { get; protected set; default = null; }

		/**
		 * 128-bit (X;Y) points.
		 */
		public Point128[] points = {};

		/**
		 * Sort style.
		 */
		public enum Sort {
			/**
			 * Sort by X.
			 */
			BY_X = 0,

			/**
			 * Sort by Y.
			 */
			BY_Y = 1,

			/**
			 * Do not sort points on draw().
			 */
			UNSORTED
		}

		/**
		 * Sort style.
		 */
		public Sort sort = Sort.BY_X;

		/**
		 * X-axis.
		 */
		public Axis axis_x;

		/**
		 * Y-axis.
		 */
		public Axis axis_y;

		/**
		 * ``Place`` of the ``Series`` on the {@link Chart}.
		 */
		public Place place = new Place();

		/**
		 * Title of the ``Chart``.
		 */
		public Text title;

		/**
		 * ``Marker`` style.
		 */
		public Marker marker;

		/**
		 * Grid style.
		 */
		public Grid grid = new Grid ();

		/**
		 * ``Series`` line style.
		 */
		public LineStyle line_style = LineStyle ();

		/**
		 * ``Series`` color (set only).
		 */
		public Color color {
			protected get { return Color(); }
			set {
				line_style.color = value;
				axis_x.color = value;
				axis_y.color = value;
				grid.style.color = value;
				grid.style.color.alpha = 0.5;
			}
			default = Color (0, 0, 0, 1);
		}

		/**
		 * Show the ``Series`` in zoomed area or not.
		 */
		public bool zoom_show = true;

		/**
		 * Constructs a new ``Series``.
		 * @param chart ``Chart`` instance.
		 */
		public Series (Chart chart) {
			this.chart = chart;
			title = new Text(chart);
			axis_x = new Axis(chart);
			axis_y = new Axis(chart);
			this.marker = new Marker(chart);
		}

		/**
		 * Gets a copy of the ``Series``.
		 */
		public virtual Series copy () {
			var series = new Series (chart);
			series.axis_x = this.axis_x.copy ();
			series.axis_y = this.axis_y.copy ();
			series.grid = this.grid.copy ();
			series.line_style = this.line_style;
			series.marker = this.marker;
			series.place = this.place.copy();
			series.points = this.points;
			series.sort = this.sort;
			series.title = this.title.copy();
			series.zoom_show = this.zoom_show;
			return series;
		}

		/**
		 * Draws the ``Series``.
		 */
		public virtual void draw () {
			var points = Math.sort_points(this, sort);
			line_style.apply(chart);
			// draw series line
			for (int i = 1; i < points.length; ++i) {
				Point c, d;
				if (Math.cut_line (
				        Point(chart.plarea.x0, chart.plarea.y0),
				        Point(chart.plarea.x1, chart.plarea.y1),
				        Point(get_scr_x(points[i - 1].x), get_scr_y(points[i - 1].y)),
				        Point(get_scr_x(points[i].x), get_scr_y(points[i].y)),
				        out c, out d)
				) {
					chart.ctx.move_to (c.x, c.y);
					chart.ctx.line_to (d.x, d.y);
				}
			}
			chart.ctx.stroke();
			for (int i = 0; i < points.length; ++i) {
				var x = get_scr_x(points[i].x);
				var y = get_scr_y(points[i].y);
				if (Math.point_in_rect (Point(x, y), chart.plarea.x0, chart.plarea.x1,
				                                     chart.plarea.y0, chart.plarea.y1))
					marker.draw_at_pos(Point(x, y));
			}
		}

		/**
		 * Gets screen point by real ``Series`` (X;Y) value.
		 * @param p real ``Series`` (X;Y) value.
		 */
		public virtual Point get_scr_point (Point128 p) {
			return Point (get_scr_x(p.x), get_scr_y(p.y));
		}

		/**
		 * Gets real ``Series`` (X;Y) value by plot area screen point.
		 * @param p (X;Y) screen point.
		 */
		public virtual Point128 get_real_point (Point p) {
			return Point128 (get_real_x(p.x), get_real_y(p.y));
		}

		/**
		 * Zooms out the ``Series``.
		 */
		public virtual void zoom_out () {
				zoom_show = true;
				axis_x.zoom_out();
				axis_y.zoom_out();
				place.zoom_out();
		}
	}
}
