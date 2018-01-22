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
		 * Plot area bounds.
		 */
		public Area plarea = new Area.with_abs(0, 0, 1, 1);

		/**
		 * Current evaluated plot area.
		 */
		public Area evarea = new Area.with_abs(0, 0, 1, 1);

		/**
		 * Zoom area limits (relative coordinates: 0-1).
		 */
		public Area zoom = new Area.with_abs(0, 0, 1, 1);

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
		public Text title;

		/**
		 * Legend.
		 */
		public Legend legend;

		/**
		 * ``Chart`` Series array.
		 */
		public Series[] series = {};

		/**
		 * Index of the 1'st shown series in a zoomed area.
		 */
		public virtual int zoom_1st_idx { get; protected set; default = 0; }

		/**
		 * Joint/common X axes or not.
		 */
		public virtual bool joint_x { get; protected set; default = false; }

		/**
		 * Joint/common Y axes or not.
		 */
		public virtual bool joint_y { get; protected set; default = false; }

		/**
		 * Joint/common {@link Axis} ``Color``.
		 */
		public Color joint_color = Color (0, 0, 0, 1);

		/**
		 * Selection line style.
		 */
		public LineStyle selection_style = LineStyle ();

		/**
		 * ``Chart`` cursors.
		 */
		public virtual Cursors cursors { get; protected set; default = null; }

		/**
		 * Set paint color for further drawing.
		 */
		public virtual Color color {
			protected get { return Color(); }
			set { ctx.set_source_rgba (value.red, value.green, value.blue, value.alpha); }
			default = Color();
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

			//cursors.get_crossings();

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
		 * @param area selection area.
		 */
		public virtual void draw_selection (Area area) {
			selection_style.apply(this);
			ctx.rectangle (area.x0, area.y0, area.width, area.height);
			ctx.stroke();
		}

		/**
		 * Zooms the ``Chart``.
		 * @param area selected zoom area.
		 */
		public virtual void zoom_in (Area area) {
			foreach (var s in series) {
				if (!s.zoom_show) continue;
				var real_x0 = s.get_real_x (area.x0);
				var real_x1 = s.get_real_x (area.x1);
				var real_width = real_x1 - real_x0;
				var real_y0 = s.get_real_y (area.y0);
				var real_y1 = s.get_real_y (area.y1);
				var real_height = real_y0 - real_y1;
				// if selected square does not intersect with the series's square
				if (   real_x1 <= s.axis_x.range.zmin || real_x0 >= s.axis_x.range.zmax
				    || real_y0 <= s.axis_y.range.zmin || real_y1 >= s.axis_y.range.zmax) {
					s.zoom_show = false;
					continue;
				}
				if (real_x0 >= s.axis_x.range.zmin) {
					s.axis_x.range.zmin = real_x0;
					s.place.zx0 = 0;
				} else {
					s.place.zx0 = (s.axis_x.range.zmin - real_x0) / real_width;
				}
				if (real_x1 <= s.axis_x.range.zmax) {
					s.axis_x.range.zmax = real_x1;
					s.place.zx1 = 1;
				} else {
					s.place.zx1 = (s.axis_x.range.zmax - real_x0) / real_width;
				}
				if (real_y1 >= s.axis_y.range.zmin) {
					s.axis_y.range.zmin = real_y1;
					s.place.zy0 = 0;
				} else {
					s.place.zy0 = (s.axis_y.range.zmin - real_y1) / real_height;
				}
				if (real_y0 <= s.axis_y.range.zmax) {
					s.axis_y.range.zmax = real_y0;
					s.place.zy1 = 1;
				} else {
					s.place.zy1 = (s.axis_y.range.zmax - real_y1) / real_height;
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

			d.x /= -plarea.width; d.y /= -plarea.height;

			var z = zoom.copy();

			zoom_out();

			d.x *= plarea.width; d.y *= plarea.height;

			var x0 = plarea.x0 + plarea.width * z.x0;
			var x1 = plarea.x0 + plarea.width * z.x1;
			var y0 = plarea.y0 + plarea.height * z.y0;
			var y1 = plarea.y0 + plarea.height * z.y1;

			d.x *= z.width; d.y *= z.height;

			var px1 = plarea.x1;
			var py1 = plarea.y1;

			if (x0 + d.x < plarea.x0) d.x = plarea.x0 - x0;
			if (x1 + d.x > px1) d.x = px1 - x1;
			if (y0 + d.y < plarea.y0) d.y = plarea.y0 - y0;
			if (y1 + d.y > py1) d.y = py1 - y1;

			zoom_in(
				new Area.with_rel(
					x0 + d.x,
					y0 + d.y,
					plarea.width * z.width,
					plarea.height * z.height
				)
			);
		}

		protected virtual void fix_evarea () {
			if (evarea.width < 0) evarea.width = 0;
			if (evarea.height < 0) evarea.height = 0;
		}
		protected virtual void rot_axes_titles () {
			foreach (var s in series)
				s.axis_y.title.font.orient = Gtk.Orientation.VERTICAL;
		}

		protected virtual void eval_plarea () {
			plarea = evarea.copy();
			if (legend.show)
				switch(legend.position) {
				case Legend.Position.TOP: plarea.y0 += legend.spacing; break;
				case Legend.Position.BOTTOM: plarea.y1 -= legend.spacing; break;
				case Legend.Position.LEFT: plarea.x0 += legend.spacing; break;
				case Legend.Position.RIGHT: plarea.x1 -= legend.spacing; break;
				}

			// Check for joint axes
			joint_x = joint_y = true;
			int nshow = 0;
			foreach (var s in series) {
				if (!s.zoom_show) continue;
				if (!s.equal_x_axis(series[0])) joint_x = false;
				if (!s.equal_y_axis(series[0])) joint_y = false;
				++nshow;
			}
			if (nshow == 1) joint_x = joint_y = false;

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].join_axes(true, si, ref nskip);

			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].join_axes(false, si, ref nskip);
		}

		protected virtual void draw_plarea_border () {
			color = border_color;
			ctx.set_dash(null, 0);
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
		protected virtual void draw_haxes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_horizontal_axis (si, ref nskip);
		}
		protected virtual void draw_vaxes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_vertical_axis (si, ref nskip);
		}
		protected virtual void draw_series () {
			foreach (var s in series)
				if (s.zoom_show && s.points.length != 0)
					s.draw();
		}
	}
}
