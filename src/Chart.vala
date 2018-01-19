namespace CairoChart {

	/**
	 * Cairo/GTK+ ``Chart``.
	 */
	public class Chart {

		/**
		 * ``Chart`` Position.
		 */
		public Cairo.Rectangle area = Cairo.Rectangle();

		/**
		 * Current evaluated area.
		 */
		public Cairo.Rectangle evarea = Cairo.Rectangle()
		                                { x = 0, y = 0, width = 1, height = 1 };

		/**
		 * Zoom area limits (relative coordinates: 0.0-1.0).
		 */
		public Cairo.Rectangle zoom = Cairo.Rectangle()
		                              { x = 0, y = 0, width = 1, height = 1 };

		/**
		 * Plot area bounds.
		 */
		public Cairo.Rectangle plarea = Cairo.Rectangle()
		                                { x = 0, y = 0, width = 1, height = 1 };

		/**
		 * Cairo ``Context`` of the Drawing Area.
		 */
		public Cairo.Context ctx = null;

		/**
		 * Background ``Color``.
		 */
		public Color bg_color = Color(1, 1, 1);

		/**
		 * Border ``Color``.
		 */
		public Color border_color = Color(0, 0, 0, 0.3);

		/**
		 * ``Chart`` Title.
		 */
		public Text title = new Text("Cairo Chart");

		/**
		 * Legend.
		 */
		public Legend legend = new Legend();

		/**
		 * ``Chart`` Series array.
		 */
		public Series[] series = {};

		/**
		 * index of the 1'st shown series in a zoommed area.
		 */
		public int zoom_1st_idx { get; protected set; default = 0; }

		/**
		 * Joint/common X axes or not.
		 */
		public bool joint_x { get; protected set; default = false; }

		/**
		 * Joint/common Y axes or not.
		 */
		public bool joint_y { get; protected set; default = false; }

		/**
		 * Joint/common {@link Axis} ``Color``.
		 */
		public Color joint_color = Color (0, 0, 0, 1);

		/**
		 * Selection line style.
		 */
		public Line.Style selection_style = Line.Style ();

		/**
		 * ``Chart`` cursors.
		 */
		public Cursors cursors { get; protected set; default = null; }

		/**
		 * Set paint color for further drawing.
		 */
		public Color color {
			private get { return Color(); }
			set { ctx.set_source_rgba (value.red, value.green, value.blue, value.alpha); }
			default = Color();
		}

		/**
		 * Constructs a new ``Chart``.
		 */
		public Chart () {
			cursors = new Cursors (this);
		}

		/**
		 * Gets a copy of the ``Chart``.
		 */
		public Chart copy () {
			var chart = new Chart ();
			chart.area = this.area;
			chart.bg_color = this.bg_color;
			chart.border_color = this.border_color;
			chart.ctx = this.ctx;
			chart.cursors = this.cursors.copy();
			chart.evarea = this.evarea;
			chart.joint_color = this.joint_color;
			chart.joint_x = this.joint_x;
			chart.joint_y = this.joint_y;
			chart.legend = this.legend.copy();
			chart.plarea = this.plarea;
			chart.selection_style = this.selection_style;
			chart.series = this.series;
			chart.title = this.title.copy();
			chart.zoom = this.zoom;
			chart.zoom_1st_idx = this.zoom_1st_idx;
			return chart;
		}

		/**
		 * Clears the ``Chart`` with a {@link bg_color} background color.
		 */
		public virtual void clear () {
			if (ctx != null) {
				color = bg_color;
				ctx.paint();
			}
		}

		/**
		 * Draws the ``Chart``.
		 */
		public virtual bool draw () {

			evarea = area;

			draw_title ();
			fix_evarea ();

			legend.draw (this);
			fix_evarea ();

			rot_axes_titles ();

			cursors.get_crossings();

			eval_plarea ();

			draw_haxes ();
			fix_evarea ();

			draw_vaxes ();
			fix_evarea ();

			draw_plarea_border ();
			fix_evarea ();

			draw_series ();
			fix_evarea ();

			cursors.draw ();
			fix_evarea ();

			return true;
		}

		/**
		 * Draws selection with a {@link selection_style} line style.
		 * @param rect selection square.
		 */
		public virtual void draw_selection (Cairo.Rectangle rect) {
			selection_style.apply(this);
			ctx.rectangle (rect.x, rect.y, rect.width, rect.height);
			ctx.stroke();
		}

		/**
		 * Zooms the ``Chart``.
		 * @param rect selected zoom area.
		 */
		public virtual void zoom_in (Cairo.Rectangle rect) {
			foreach (var s in series) {
				if (!s.zoom_show) continue;
				var real_x0 = s.get_real_x (rect.x);
				var real_x1 = s.get_real_x (rect.x + rect.width);
				var real_width = real_x1 - real_x0;
				var real_y0 = s.get_real_y (rect.y);
				var real_y1 = s.get_real_y (rect.y + rect.height);
				var real_height = real_y0 - real_y1;
				// if selected square does not intersect with the series's square
				if (   real_x1 <= s.axis_x.zoom_min || real_x0 >= s.axis_x.zoom_max
				    || real_y0 <= s.axis_y.zoom_min || real_y1 >= s.axis_y.zoom_max) {
					s.zoom_show = false;
					continue;
				}
				if (real_x0 >= s.axis_x.zoom_min) {
					s.axis_x.zoom_min = real_x0;
					s.place.zoom_x_min = 0.0;
				} else {
					s.place.zoom_x_min = (s.axis_x.zoom_min - real_x0) / real_width;
				}
				if (real_x1 <= s.axis_x.zoom_max) {
					s.axis_x.zoom_max = real_x1;
					s.place.zoom_x_max = 1.0;
				} else {
					s.place.zoom_x_max = (s.axis_x.zoom_max - real_x0) / real_width;
				}
				if (real_y1 >= s.axis_y.zoom_min) {
					s.axis_y.zoom_min = real_y1;
					s.place.zoom_y_min = 0.0;
				} else {
					s.place.zoom_y_min = (s.axis_y.zoom_min - real_y1) / real_height;
				}
				if (real_y0 <= s.axis_y.zoom_max) {
					s.axis_y.zoom_max = real_y0;
					s.place.zoom_y_max = 1.0;
				} else {
					s.place.zoom_y_max = (s.axis_y.zoom_max - real_y1) / real_height;
				}
			}

			zoom_1st_idx = 0;
			for (var si = 0; si < series.length; ++si)
				if (series[si].zoom_show) {
					zoom_1st_idx = si;
					break;
				}
			var new_zoom = zoom;
			var rmpx = rect.x - plarea.x;
			var pzw = zoom.width / plarea.width;
			new_zoom.x += rmpx * pzw;
			var x_max = zoom.x + (rmpx + rect.width) * pzw;
			new_zoom.width = x_max - new_zoom.x;
			var rmpy = rect.y - plarea.y;
			var pzh = zoom.height / plarea.height;
			new_zoom.y += rmpy * pzh;
			var y_max = zoom.y + (rmpy + rect.height) * pzh;
			new_zoom.height = y_max - new_zoom.y;
			zoom = new_zoom;
		}

		/**
		 * Zooms out the ``Chart``.
		 */
		public virtual void zoom_out () {
			foreach (var s in series) {
				s.zoom_show = true;
				s.axis_x.zoom_min = s.axis_x.min;
				s.axis_x.zoom_max = s.axis_x.max;
				s.axis_y.zoom_min = s.axis_y.min;
				s.axis_y.zoom_max = s.axis_y.max;
				s.place.zoom_x_min = s.place.x_min;
				s.place.zoom_x_max = s.place.x_max;
				s.place.zoom_y_min = s.place.y_min;
				s.place.zoom_y_max = s.place.y_max;
			}
			zoom = Cairo.Rectangle() { x = 0, y = 0, width = 1, height = 1 };
			zoom_1st_idx = 0;
		}

		/**
		 * Moves the ``Chart``.
		 * @param delta delta Δ(x;y) value to move the ``Chart``.
		 */
		public virtual void move (Point delta) {
			var d = delta;
			d.x /= plarea.width; d.x *= - 1.0;
			d.y /= plarea.height; d.y *= - 1.0;
			var rzxmin = zoom.x, rzxmax = zoom.x + zoom.width, rzymin = zoom.y, rzymax = zoom.y + zoom.height;
			zoom_out();
			d.x *= plarea.width;
			d.y *= plarea.height;
			var xmin = plarea.x + plarea.width * rzxmin;
			var xmax = plarea.x + plarea.width * rzxmax;
			var ymin = plarea.y + plarea.height * rzymin;
			var ymax = plarea.y + plarea.height * rzymax;

			d.x *= rzxmax - rzxmin; d.y *= rzymax - rzymin;

			if (xmin + d.x < plarea.x) d.x = plarea.x - xmin;
			if (xmax + d.x > plarea.x + plarea.width) d.x = plarea.x + plarea.width - xmax;
			if (ymin + d.y < plarea.y) d.y = plarea.y - ymin;
			if (ymax + d.y > plarea.y + plarea.height) d.y = plarea.y + plarea.height - ymax;

			zoom_in (Cairo.Rectangle(){x = xmin + d.x, y = ymin + d.y, width = xmax - xmin, height = ymax - ymin});
		}

		protected virtual void fix_evarea () {
			if (evarea.width < 0) evarea.width = 0;
			if (evarea.height < 0) evarea.height = 0;
		}
		protected virtual void rot_axes_titles () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				s.axis_y.title.style.orientation = Font.Orientation.VERTICAL;
			}
		}

		protected virtual void eval_plarea () {
			plarea.x = evarea.x + legend.spacing;
			plarea.width = evarea.width - 2 * legend.spacing;
			plarea.y = evarea.y + legend.spacing;
			plarea.height = evarea.height - 2 * legend.spacing;

			// Check for joint axes
			joint_x = joint_y = true;
			int nzoom_series_show = 0;
			for (var si = series.length - 1; si >=0; --si) {
				var s = series[si], s0 = series[0];
				if (!s.zoom_show) continue;
				++nzoom_series_show;
				if (!s.equal_x_axis(s0)) joint_x = false;
				if (!s.equal_y_axis(s0)) joint_y = false;
			}
			if (nzoom_series_show == 1) joint_x = joint_y = false;

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].join_calc(true, si, ref nskip);

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].join_calc(false, si, ref nskip);
		}

		protected virtual void draw_plarea_border () {
			color = border_color;
			ctx.set_dash(null, 0);
			ctx.move_to (plarea.x, plarea.y);
			ctx.line_to (plarea.x, plarea.y + plarea.height);
			ctx.line_to (plarea.x + plarea.width, plarea.y + plarea.height);
			ctx.line_to (plarea.x + plarea.width, plarea.y);
			ctx.line_to (plarea.x, plarea.y);
			ctx.stroke ();
		}
		protected virtual void draw_title () {
			var sz = title.get_size(ctx);
			var title_height = sz.height + (legend.position == Legend.Position.TOP ? title.vspacing * 2 : title.vspacing);
			evarea.y += title_height;
			evarea.height -= title_height;
			color = title.color;
			ctx.move_to (area.width/2 - sz.width/2, sz.height + title.vspacing);
			title.show(ctx);
		}
		protected virtual void draw_haxes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_horizontal_axis (si, ref nskip);
		}
		protected virtual void draw_vaxes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_vertical_axis (si, ref nskip);
		}
		protected virtual void draw_series () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				if (s.zoom_show && s.points.length != 0)
					s.draw();
			}
		}
	}
}
