namespace CairoChart {

	/**
	 * Cairo/GTK+ ``Chart``.
	 */
	public class Chart {

		/**
		 * ``Chart`` Position.
		 */
		public Area area = new Area();

		/**
		 * ``Chart`` Title.
		 */
		public Text title;

		/**
		 * Background ``Color``.
		 */
		public Color bg_color = Color(1, 1, 1);

		/**
		 * Border ``Color``.
		 */
		public Color border_color = Color(0, 0, 0, 0.3);

		/**
		 * ``Chart`` Series array.
		 */
		public Series[] series = {};

		/**
		 * Legend.
		 */
		public Legend legend;

		/**
		 * Joint/common {@link Axis} ``Color``.
		 */
		public Color joint_color = Color (0, 0, 0, 1);

		/**
		 * Selection line style.
		 */
		public LineStyle selection_style = LineStyle ();

		/**
		 * Zoom Scroll speed.
		 */
		public double zoom_scroll_speed = 64.0;

		/**
		 * Plot area bounds.
		 */
		public Area plarea = new Area();

		/**
		 * Zoom area limits (relative coordinates: 0-1).
		 */
		public Area zoom = new Area();

		/**
		 * Cairo ``Context`` of the Drawing Area.
		 */
		public Cairo.Context ctx = null;

		/**
		 * Current evaluated plot area.
		 */
		public Area evarea = new Area();

		/**
		 * ``Chart`` cursors.
		 */
		public virtual Cursors cursors { get; protected set; default = null; }

		/**
		 * Joint/common X axes or not.
		 */
		public virtual bool joint_x { get; protected set; default = false; }

		/**
		 * Joint/common Y axes or not.
		 */
		public virtual bool joint_y { get; protected set; default = false; }

		/**
		 * Index of the 1'st shown series in a zoomed area.
		 */
		public virtual int zoom_1st_idx { get; protected set; default = 0; }

		/**
		 * Set paint color for further drawing.
		 */
		public virtual Color color {
			protected get { return Color(); }
			set { ctx.set_source_rgba (value.red, value.green, value.blue, value.alpha); }
		}

		/**
		 * Constructs a new ``Chart``.
		 */
		public Chart () {
			cursors = new Cursors (this);
			title = new Text(this, "Cairo Chart");
			legend = new Legend(this);
		}

		/**
		 * Gets a copy of the ``Chart``.
		 */
		public virtual Chart copy () {
			var chart = new Chart ();
			chart.area = this.area.copy();
			chart.bg_color = this.bg_color;
			chart.border_color = this.border_color;
			chart.ctx = this.ctx;
			chart.cursors = this.cursors.copy();
			chart.evarea = this.evarea.copy();
			chart.joint_color = this.joint_color;
			chart.joint_x = this.joint_x;
			chart.joint_y = this.joint_y;
			chart.legend = this.legend.copy();
			chart.plarea = this.plarea.copy();
			chart.selection_style = this.selection_style;
			chart.series = this.series;
			chart.title = this.title.copy();
			chart.zoom = this.zoom.copy();
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

			evarea = area.copy();

			draw_title ();
			fix_evarea ();

			legend.draw ();
			fix_evarea ();

			rot_axes_titles ();

			cursors.eval_crossings();

			eval_plarea ();

			draw_axes ();
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
		 * @param area selection area.
		 */
		public virtual void draw_selection (Area area) {
			selection_style.apply(this);
			ctx.rectangle (area.x0, area.y0, area.width, area.height);
			ctx.stroke();
		}

		/**
		 * Zooms in the ``Chart``.
		 * @param area selected zoom area.
		 */
		public virtual void zoom_in (Area area) {
			foreach (var s in series) {
				if (!s.zoom_show) continue;
				var real_x0 = s.axis_x.axis_val (area.x0);
				var real_x1 = s.axis_x.axis_val (area.x1);
				var real_width = real_x1 - real_x0;
				var real_y0 = s.axis_y.axis_val (area.y0);
				var real_y1 = s.axis_y.axis_val (area.y1);
				var real_height = real_y0 - real_y1;
				// if selected square does not intersect with the series's square
				if (   real_x1 <= s.axis_x.range.zmin || real_x0 >= s.axis_x.range.zmax
				    || real_y0 <= s.axis_y.range.zmin || real_y1 >= s.axis_y.range.zmax) {
					s.zoom_show = false;
					continue;
				}
				if (real_x0 >= s.axis_x.range.zmin) {
					s.axis_x.range.zmin = real_x0;
					s.axis_x.place.zmin = 0;
				} else {
					s.axis_x.place.zmin = (s.axis_x.range.zmin - real_x0) / real_width;
				}
				if (real_x1 <= s.axis_x.range.zmax) {
					s.axis_x.range.zmax = real_x1;
					s.axis_x.place.zmax = 1;
				} else {
					s.axis_x.place.zmax = (s.axis_x.range.zmax - real_x0) / real_width;
				}
				if (real_y1 >= s.axis_y.range.zmin) {
					s.axis_y.range.zmin = real_y1;
					s.axis_y.place.zmin = 0;
				} else {
					s.axis_y.place.zmin = (s.axis_y.range.zmin - real_y1) / real_height;
				}
				if (real_y0 <= s.axis_y.range.zmax) {
					s.axis_y.range.zmax = real_y0;
					s.axis_y.place.zmax = 1;
				} else {
					s.axis_y.place.zmax = (s.axis_y.range.zmax - real_y1) / real_height;
				}
			}

			zoom_1st_idx = 0;
			for (var si = 0; si < series.length; ++si)
				if (series[si].zoom_show) {
					zoom_1st_idx = si;
					break;
				}
			var new_zoom = zoom.copy();
			var rmpx = area.x0 - plarea.x0;
			var zdpw = zoom.width / plarea.width;
			new_zoom.x0 += rmpx * zdpw;
			var x_max = zoom.x0 + (rmpx + area.width) * zdpw;
			new_zoom.width = x_max - new_zoom.x0;
			var rmpy = area.y0 - plarea.y0;
			var zdph = zoom.height / plarea.height;
			new_zoom.y0 += rmpy * zdph;
			var y_max = zoom.y0 + (rmpy + area.height) * zdph;
			new_zoom.height = y_max - new_zoom.y0;
			zoom = new_zoom.copy();
		}

		/**
		 * Zooms out the ``Chart``.
		 */
		public virtual void zoom_out () {
			foreach (var s in series) s.zoom_out();
			zoom = new Area.with_abs (0, 0, 1, 1);
			zoom_1st_idx = 0;
		}

		/**
		 * Moves the ``Chart``.
		 * @param delta delta Δ(x;y) value to move the ``Chart``.
		 */
		public virtual void move (Point delta) {
			var d = delta;

			if (plarea.width.abs() < 1 || plarea.height.abs() < 1) return;

			d.x /= -plarea.width; d.y /= -plarea.height;

			var z = zoom.copy();

			zoom_out();

			d.x *= plarea.width; d.y *= plarea.height;

			var x0 = plarea.x0 + plarea.width * z.x0;
			var x1 = plarea.x0 + plarea.width * z.x1;
			var y0 = plarea.y0 + plarea.height * z.y0;
			var y1 = plarea.y0 + plarea.height * z.y1;

			d.x *= z.width; d.y *= z.height;

			if (x0 + d.x < plarea.x0) d.x = plarea.x0 - x0;
			if (x1 + d.x > plarea.x1) d.x = plarea.x1 - x1;
			if (y0 + d.y < plarea.y0) d.y = plarea.y0 - y0;
			if (y1 + d.y > plarea.y1) d.y = plarea.y1 - y1;

			zoom_in(
				new Area.with_rel(
					x0 + d.x,
					y0 + d.y,
					plarea.width * z.width,
					plarea.height * z.height
				)
			);
		}

		/**
		 * Zooms in the ``Chart`` by event point (scrolling).
		 * @param p event position.
		 */
		public virtual void zoom_scroll_in (Point p) {
			var w = plarea.width, h = plarea.height;
			if (w < 8 || h < 8) return;
			zoom_in (
				new Area.with_abs(
					plarea.x0 + (p.x - plarea.x0) / w * zoom_scroll_speed,
					plarea.y0 + (p.y - plarea.y0) / h * zoom_scroll_speed,
					plarea.x1 - (plarea.x1 - p.x) / w * zoom_scroll_speed,
					plarea.y1 - (plarea.y1 - p.y) / h * zoom_scroll_speed
				)
			);
		}

		/**
		 * Zooms out the ``Chart`` by event point (scrolling).
		 * @param p event position.
		 */
		public virtual void zoom_scroll_out (Point p) {
			var z = zoom.copy(), pa = plarea.copy();
			var w = plarea.width, h = plarea.height;
			if (w < 8 || h < 8) return;

			zoom_out();

			var x0 = plarea.x0 + plarea.width * z.x0;
			var x1 = plarea.x0 + plarea.width * z.x1;
			var y0 = plarea.y0 + plarea.height * z.y0;
			var y1 = plarea.y0 + plarea.height * z.y1;

			var dx0 = (p.x - pa.x0) / w * zoom_scroll_speed;
			var dx1 = (pa.x1 - p.x) / w * zoom_scroll_speed;
			var dy0 = (p.y - pa.y0) / h * zoom_scroll_speed;
			var dy1 = (pa.y1 - p.y) / h * zoom_scroll_speed;

			if (x0 - dx0 < plarea.x0) x0 = plarea.x0; else x0 -= dx0;
			if (x1 + dx1 > plarea.x1) x1 = plarea.x1; else x1 += dx1;
			if (y0 - dy0 < plarea.y0) y0 = plarea.y0; else y0 -= dy0;
			if (y1 + dy1 > plarea.y1) y1 = plarea.y1; else y1 += dy1;

			zoom_in (new Area.with_abs(x0, y0, x1, y1));
		}

		protected virtual void fix_evarea () {
			if (evarea.width < 0) evarea.width = 0;
			if (evarea.height < 0) evarea.height = 0;
		}
		protected virtual void rot_axes_titles () {
			foreach (var s in series)
				s.axis_y.title.font.orient = Gtk.Orientation.VERTICAL;
		}

		protected virtual bool equal_x_axis (Series s1, Series s2) {
			if (   s1.axis_x.position != s2.axis_x.position
			    || s1.axis_x.range.zmin != s2.axis_x.range.zmin
			    || s1.axis_x.range.zmax != s2.axis_x.range.zmax
			    || s1.axis_x.place.zmin != s2.axis_x.place.zmin
			    || s1.axis_x.place.zmax != s2.axis_x.place.zmax
			    || s1.axis_x.dtype != s2.axis_x.dtype
			)
				return false;
			return true;
		}

		protected virtual bool equal_y_axis (Series s1, Series s2) {
			if (   s1.axis_y.position != s2.axis_y.position
			    || s1.axis_y.range.zmin != s2.axis_y.range.zmin
			    || s1.axis_y.range.zmax != s2.axis_y.range.zmax
			    || s1.axis_y.place.zmin != s2.axis_y.place.zmin
			    || s1.axis_y.place.zmax != s2.axis_y.place.zmax
			    || s1.axis_y.dtype != s2.axis_y.dtype
			)
				return false;
			return true;
		}

		protected virtual void eval_plarea () {
			plarea = evarea.copy();

			// Check for joint axes
			joint_x = joint_y = true;
			int nshow = 0;
			foreach (var s in series) {
				if (!s.zoom_show) continue;
				if (!equal_x_axis(s, series[0])) joint_x = false;
				if (!equal_y_axis(s, series[0])) joint_y = false;
				++nshow;
			}
			if (nshow == 1) joint_x = joint_y = false;

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].axis_x.join_axes(ref nskip);

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].axis_y.join_axes(ref nskip);
		}

		protected virtual void draw_plarea_border () {
			LineStyle().apply(this);
			color = border_color;
			ctx.rectangle(plarea.x0, plarea.y0, plarea.width, plarea.height);
			ctx.stroke ();
		}
		protected virtual void draw_title () {
			var title_height = title.height + title.font.vspacing * 2;
			evarea.y0 += title_height;
			color = title.color;
			ctx.move_to (area.width/2 - title.width/2, title.height + title.font.vspacing);
			title.show();
		}
		protected virtual void draw_axes () {
			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].axis_x.draw(ref nskip);
			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].axis_y.draw(ref nskip);
		}
		protected virtual void draw_series () {
			foreach (var s in series)
				if (s.zoom_show && s.points.length != 0)
					s.draw();
		}
	}
}
