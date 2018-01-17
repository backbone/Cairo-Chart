namespace CairoChart {

	public class Chart {

		/**
		 * Chart Position.
		 */
		public Cairo.Rectangle pos = Cairo.Rectangle();

		public Cairo.Context context = null;

		public Color bg_color = Color(1, 1, 1);
		public Text title = new Text ("Cairo Chart");
		public Color border_color = Color(0, 0, 0, 0.3);

		public Legend legend = new Legend ();

		public Series[] series = {};

		public double cur_x_min = 0.0;
		public double cur_x_max = 1.0;
		public double cur_y_min = 0.0;
		public double cur_y_max = 1.0;

		// relative zoom limits
		public double rz_x_min { get; protected set; default = 0.0; }
		public double rz_x_max { get; protected set; default = 1.0; }
		public double rz_y_min { get; protected set; default = 0.0; }
		public double rz_y_max { get; protected set; default = 1.0; }

		public int zoom_first_show { get; protected set; default = 0; }

		public double title_width { get; protected set; default = 0.0; }
		public double title_height { get; protected set; default = 0.0; }

		public double title_indent = 4;

		public Line.Style selection_style = Line.Style ();

		public double plot_x_min = 0;
		public double plot_x_max = 0;
		public double plot_y_min = 0;
		public double plot_y_max = 0;

		public bool joint_x { get; protected set; default = false; }
		public bool joint_y { get; protected set; default = false; }
		public Color joint_axis_color = Color (0, 0, 0, 1);

		public CairoChart.Math math { get; protected set; default = new Math(); }
		public Cursors cursors { get; protected set; default = new Cursors (); }

		public Color color {
			private get { return Color(); }
			set { context.set_source_rgba (value.red, value.green, value.blue, value.alpha); }
			default = Color();
		}

		public Chart () { }

		public Chart copy () {
			var chart = new Chart ();
			chart.bg_color = this.bg_color;
			chart.border_color = this.border_color;
			chart.joint_x = this.joint_x;
			chart.joint_y = this.joint_y;
			chart.context = this.context;
			chart.cur_x_max = this.cur_x_max;
			chart.cur_x_min = this.cur_x_min;
			chart.cur_y_max = this.cur_y_max;
			chart.cur_y_min = this.cur_y_min;
			chart.cursors = this.cursors.copy();
			chart.legend = this.legend.copy();
			chart.plot_x_max = this.plot_x_max;
			chart.plot_x_min = this.plot_x_min;
			chart.plot_y_max = this.plot_y_max;
			chart.plot_y_min = this.plot_y_min;
			chart.rz_x_min = this.rz_x_min;
			chart.rz_x_max = this.rz_x_max;
			chart.rz_y_min = this.rz_y_min;
			chart.rz_y_max = this.rz_y_max;
			chart.selection_style = this.selection_style;
			chart.series = this.series;
			chart.title = this.title.copy();
			chart.title_height = this.title_height;
			chart.title_indent = this.title_indent;
			chart.title_width = this.title_width;
			chart.pos = this.pos;
			chart.zoom_first_show = this.zoom_first_show;
			return chart;
		}

		protected virtual void check_cur_values () {
			if (cur_x_min > cur_x_max)
				cur_x_max = cur_x_min;
			if (cur_y_min > cur_y_max)
				cur_y_max = cur_y_min;
		}
		protected virtual void set_vertical_axes_titles () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				s.axis_y.title.style.orientation = Font.Orientation.VERTICAL;
			}
		}

		public virtual void clear () {
			if (context != null) {
				color = bg_color;
				context.paint();
				color = Color (0, 0, 0, 1);
			}
		}

		public virtual bool draw () {

			cur_x_min = pos.x;
			cur_y_min = pos.y;
			cur_x_max = pos.x + pos.width;
			cur_y_max = pos.y + pos.height;

			draw_chart_title ();
			check_cur_values ();

			legend.draw (this);
			check_cur_values ();

			set_vertical_axes_titles ();

			cursors.get_cursors_crossings(this);

			calc_plot_area ();

			draw_horizontal_axes ();
			check_cur_values ();

			draw_vertical_axes ();
			check_cur_values ();

			draw_plot_area_border ();
			check_cur_values ();

			draw_series ();
			check_cur_values ();

			cursors.draw_cursors (this);
			check_cur_values ();

			return true;
		}
		protected virtual void draw_chart_title () {
			var sz = title.get_size(context);
			title_height = sz.height + (legend.position == Legend.Position.TOP ? title_indent * 2 : title_indent);
			cur_y_min += title_height;
			color = title.color;
			context.move_to (pos.width/2 - sz.width/2, sz.height + title_indent);
			title.show(context);
		}
		public virtual void draw_selection (Cairo.Rectangle rect) {
			selection_style.set(this);
			context.rectangle (rect.x, rect.y, rect.width, rect.height);
			context.stroke();
		}
		protected virtual void draw_horizontal_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_horizontal_axis (si, ref nskip);
		}
		protected virtual void draw_vertical_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_vertical_axis (si, ref nskip);
		}
		protected virtual void draw_plot_area_border () {
			color = border_color;
			context.set_dash(null, 0);
			context.move_to (plot_x_min, plot_y_min);
			context.line_to (plot_x_min, plot_y_max);
			context.line_to (plot_x_max, plot_y_max);
			context.line_to (plot_x_max, plot_y_min);
			context.line_to (plot_x_min, plot_y_min);
			context.stroke ();
		}
		protected virtual void draw_series () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				if (s.zoom_show && s.points.length != 0)
					s.draw();
			}
		}

		public virtual void zoom_in (Cairo.Rectangle rect) {
			var x1 = rect.x + rect.width;
			var y1 = rect.y + rect.height;
			for (var si = 0, max_i = series.length; si < max_i; ++si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				var real_x0 = s.get_real_x (rect.x);
				var real_x1 = s.get_real_x (x1);
				var real_y0 = s.get_real_y (rect.y);
				var real_y1 = s.get_real_y (y1);
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
					s.place.zoom_x_min = (s.axis_x.zoom_min - real_x0) / (real_x1 - real_x0);
				}
				if (real_x1 <= s.axis_x.zoom_max) {
					s.axis_x.zoom_max = real_x1;
					s.place.zoom_x_max = 1.0;
				} else {
					s.place.zoom_x_max = (s.axis_x.zoom_max - real_x0) / (real_x1 - real_x0);
				}
				if (real_y1 >= s.axis_y.zoom_min) {
					s.axis_y.zoom_min = real_y1;
					s.place.zoom_y_min = 0.0;
				} else {
					s.place.zoom_y_min = (s.axis_y.zoom_min - real_y1) / (real_y0 - real_y1);
				}
				if (real_y0 <= s.axis_y.zoom_max) {
					s.axis_y.zoom_max = real_y0;
					s.place.zoom_y_max = 1.0;
				} else {
					s.place.zoom_y_max = (s.axis_y.zoom_max - real_y1) / (real_y0 - real_y1);
				}
			}

			zoom_first_show = 0;
			for (var si = 0, max_i = series.length; si < max_i; ++si)
				if (series[si].zoom_show) {
					zoom_first_show = si;
					break;
				}

			var new_rz_x_min = rz_x_min + (rect.x - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
			var new_rz_x_max = rz_x_min + (x1 - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
			var new_rz_y_min = rz_y_min + (rect.y - plot_y_min) / (plot_y_max - plot_y_min) * (rz_y_max - rz_y_min);
			var new_rz_y_max = rz_y_min + (y1 - plot_y_min) / (plot_y_max - plot_y_min) * (rz_y_max - rz_y_min);
			rz_x_min = new_rz_x_min;
			rz_x_max = new_rz_x_max;
			rz_y_min = new_rz_y_min;
			rz_y_max = new_rz_y_max;
		}
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
			rz_x_min = 0;
			rz_x_max = 1;
			rz_y_min = 0;
			rz_y_max = 1;

			zoom_first_show = 0;
		}
		public virtual void move (Point delta) {
			var d = delta;
			d.x /= plot_x_max - plot_x_min; d.x *= - 1.0;
			d.y /= plot_y_max - plot_y_min; d.y *= - 1.0;
			var rzxmin = rz_x_min, rzxmax = rz_x_max, rzymin = rz_y_min, rzymax = rz_y_max;
			zoom_out();
			d.x *= plot_x_max - plot_x_min;
			d.y *= plot_y_max - plot_y_min;
			var xmin = plot_x_min + (plot_x_max - plot_x_min) * rzxmin;
			var xmax = plot_x_min + (plot_x_max - plot_x_min) * rzxmax;
			var ymin = plot_y_min + (plot_y_max - plot_y_min) * rzymin;
			var ymax = plot_y_min + (plot_y_max - plot_y_min) * rzymax;

			d.x *= rzxmax - rzxmin; d.y *= rzymax - rzymin;

			if (xmin + d.x < plot_x_min) d.x = plot_x_min - xmin;
			if (xmax + d.x > plot_x_max) d.x = plot_x_max - xmax;
			if (ymin + d.y < plot_y_min) d.y = plot_y_min - ymin;
			if (ymax + d.y > plot_y_max) d.y = plot_y_max - ymax;

			zoom_in (Cairo.Rectangle(){x = xmin + d.x, y = ymin + d.y, width = xmax - xmin, height = ymax - ymin});
		}

		protected virtual void join_calc (bool is_x) {
			for (var si = series.length - 1, nskip = 0; si >= 0; --si)
				series[si].join_calc(is_x, si, ref nskip);
		}
		protected virtual void calc_plot_area () {
			plot_x_min = cur_x_min + legend.indent;
			plot_x_max = cur_x_max - legend.indent;
			plot_y_min = cur_y_min + legend.indent;
			plot_y_max = cur_y_max - legend.indent;

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

			join_calc (true);
			join_calc (false);
		}

		protected virtual bool x_in_plot_area (double x) {
			if (math.x_in_range(x, plot_x_min, plot_x_max))
				return true;
			return false;
		}
		protected virtual bool y_in_plot_area (double y) {
			if (math.y_in_range(y, plot_y_min, plot_y_max))
				return true;
			return false;
		}
		public virtual bool point_in_plot_area (Point p) {
			if (math.point_in_rect (p, plot_x_min, plot_x_max, plot_y_min, plot_y_max))
				return true;
			return false;
		}

		public virtual Float128 scr2rel_x (Float128 x) {
			return rz_x_min + (x - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
		}
		public virtual Float128 scr2rel_y (Float128 y) {
			return rz_y_max - (plot_y_max - y) / (plot_y_max - plot_y_min) * (rz_y_max - rz_y_min);
		}
		public virtual Point scr2rel_point (Point p) {
			return Point (scr2rel_x(p.x), scr2rel_y(p.y));
		}
		public virtual Float128 rel2scr_x(Float128 x) {
			return plot_x_min + (plot_x_max - plot_x_min) * (x - rz_x_min) / (rz_x_max - rz_x_min);
		}
		public virtual Float128 rel2scr_y(Float128 y) {
			return plot_y_min + (plot_y_max - plot_y_min) * (y - rz_y_min) / (rz_y_max - rz_y_min);
		}
		public virtual Point128 rel2scr_point (Point128 p) {
			return Point128 (rel2scr_x(p.x), rel2scr_y(p.y));
		}
	}
}
