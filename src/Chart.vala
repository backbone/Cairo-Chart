namespace CairoChart {

	public class Chart {

		public double x_min = 0.0;
		public double y_min = 0.0;
		public double width = 0.0;
		public double height = 0.0;

		public Cairo.Context context = null;

		public Color bg_color;
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
		public Cursors cursors2 { get; protected set; default = new Cursors (); }
		public List<Point?> cursors = new List<Point?> ();
		public Point active_cursor = Point(); // { get; protected set; default = Point128 (); }
		public bool is_cursor_active { get; protected set; default = false; }
		public Cursors.Style cursor_style = Cursors.Style();

		public Cursors.CursorCrossings[] cursors_crossings = {};

		public Chart () {
			bg_color = Color (1, 1, 1);
		}

		public Chart copy () {
			var chart = new Chart ();
			chart.active_cursor = this.active_cursor;
			chart.bg_color = this.bg_color;
			chart.border_color = this.border_color;
			chart.joint_x = this.joint_x;
			chart.joint_y = this.joint_y;
			chart.context = this.context;
			chart.cur_x_max = this.cur_x_max;
			chart.cur_x_min = this.cur_x_min;
			chart.cur_y_max = this.cur_y_max;
			chart.cur_y_min = this.cur_y_min;
			chart.cursor_style = this.cursor_style;
			chart.cursors = this.cursors.copy();
			chart.cursors2 = this.cursors2.copy();
			chart.cursors_crossings = this.cursors_crossings;
			chart.height = this.height;
			chart.is_cursor_active = this.is_cursor_active;
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
			chart.width = this.width;
			chart.x_min = this.x_min;
			chart.y_min = this.y_min;
			chart.zoom_first_show = this.zoom_first_show;
			return chart;
		}

		protected virtual void check_cur_values () {
			if (cur_x_min > cur_x_max)
				cur_x_max = cur_x_min;
			if (cur_y_min > cur_y_max)
				cur_y_max = cur_y_min;
		}

		public virtual void clear () {
			draw_background ();
		}

		public virtual bool draw () {

			cur_x_min = x_min;
			cur_y_min = y_min;
			cur_x_max = x_min + width;
			cur_y_max = y_min + height;

			draw_chart_title ();
			check_cur_values ();

			legend.draw (this);
			check_cur_values ();

			set_vertical_axes_titles ();

			cursors2.get_cursors_crossings(this);

			calc_plot_area ();

			draw_horizontal_axes ();
			check_cur_values ();

			draw_vertical_axes ();
			check_cur_values ();

			draw_plot_area_border ();
			check_cur_values ();

			draw_series ();
			check_cur_values ();

			cursors2.draw_cursors (this);
			check_cur_values ();

			return true;
		}

		public virtual void set_source_rgba (Color color) {
				context.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		}

		protected virtual void draw_background () {
			if (context != null) {
				set_source_rgba (bg_color);
				context.paint();
				set_source_rgba (Color (0, 0, 0, 1));
			}
		}

		public virtual void zoom_in (Cairo.Rectangle rect) {
			var x1 = rect.x + rect.width;
			var y1 = rect.y + rect.height;
			for (var si = 0, max_i = series.length; si < max_i; ++si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				var real_x0 = get_real_x (s, rect.x);
				var real_x1 = get_real_x (s, x1);
				var real_y0 = get_real_y (s, rect.y);
				var real_y1 = get_real_y (s, y1);
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

		protected virtual void draw_chart_title () {
			var sz = title.get_size(context);
			title_height = sz.height + (legend.position == Legend.Position.TOP ? title_indent * 2 : title_indent);
			cur_y_min += title_height;
			set_source_rgba(title.color);
			context.move_to (width/2 - sz.width/2, sz.height + title_indent);
			title.show(context);
		}

		public virtual void draw_selection (Cairo.Rectangle rect) {
			selection_style.set(this);
			context.rectangle (rect.x, rect.y, rect.width, rect.height);
			context.stroke();
		}

		protected virtual void set_vertical_axes_titles () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				s.axis_y.title.style.orientation = Font.Orientation.VERTICAL;
			}
		}

		protected virtual void join_calc (bool is_x) {
			for (var si = series.length - 1, nskip = 0; si >= 0; --si) {
				var s = series[si];
				Axis axis = s.axis_x;
				if (!is_x) axis = s.axis_y;
				if (!s.zoom_show) continue;
				if (nskip != 0) {--nskip; continue;}
				double max_rec_width = 0; double max_rec_height = 0;
				axis.calc_rec_sizes (this, out max_rec_width, out max_rec_height, is_x);
				var max_font_indent = axis.font_indent;
				var max_axis_font_width = axis.title.text == "" ? 0 : axis.title.get_width(context) + axis.font_indent;
				var max_axis_font_height = axis.title.text == "" ? 0 : axis.title.get_height(context) + axis.font_indent;

				if (is_x)
					s.join_relative_x_axes (this, si, true, ref max_rec_width, ref max_rec_height, ref max_font_indent, ref max_axis_font_height, ref nskip);
				else
					s.join_relative_y_axes (this, si, true, ref max_rec_width, ref max_rec_height, ref max_font_indent, ref max_axis_font_width, ref nskip);

				// for 4.2. Cursor values for joint X axis
				if (si == zoom_first_show && cursors_crossings.length != 0) {
					switch (cursor_style.orientation) {
					case Cursors.Orientation.VERTICAL:
						if (is_x && joint_x)
							switch (axis.position) {
							case Axis.Position.LOW: plot_y_max -= max_rec_height + axis.font_indent; break;
							case Axis.Position.HIGH: plot_y_min += max_rec_height + axis.font_indent; break;
							}
						break;
					case Cursors.Orientation.HORIZONTAL:
						if (!is_x && joint_y)
							switch (s.axis_y.position) {
							case Axis.Position.LOW: plot_x_min += max_rec_width + s.axis_y.font_indent; break;
							case Axis.Position.HIGH: plot_x_max -= max_rec_width + s.axis_y.font_indent; break;
							}
						break;
					}
				}
				if (is_x && (!joint_x || si == zoom_first_show))
					switch (axis.position) {
					case Axis.Position.LOW: plot_y_max -= max_rec_height + max_font_indent + max_axis_font_height; break;
					case Axis.Position.HIGH: plot_y_min += max_rec_height + max_font_indent + max_axis_font_height; break;
					}
				if (!is_x && (!joint_y || si == zoom_first_show))
					switch (s.axis_y.position) {
					case Axis.Position.LOW: plot_x_min += max_rec_width + max_font_indent + max_axis_font_width; break;
					case Axis.Position.HIGH: plot_x_max -= max_rec_width + max_font_indent + max_axis_font_width; break;
					}
			}
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

		public virtual double compact_rec_x_pos (Series s, Float128 x, Text text) {
			var sz = text.get_size(context);
			return get_scr_x(s, x) - sz.width / 2.0
			       - sz.width * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
		}

		public virtual double compact_rec_y_pos (Series s, Float128 y, Text text) {
			var sz = text.get_size(context);
			return get_scr_y(s, y) + sz.height / 2.0
			       + sz.height * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min);
		}

		protected virtual void draw_horizontal_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_horizontal_axis (this, si, ref nskip);
		}

		protected virtual void draw_vertical_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si)
				series[si].draw_vertical_axis (this, si, ref nskip);
		}

		protected virtual void draw_plot_area_border () {
			set_source_rgba (border_color);
			context.set_dash(null, 0);
			context.move_to (plot_x_min, plot_y_min);
			context.line_to (plot_x_min, plot_y_max);
			context.line_to (plot_x_max, plot_y_max);
			context.line_to (plot_x_max, plot_y_min);
			context.line_to (plot_x_min, plot_y_min);
			context.stroke ();
		}

		public virtual double get_scr_x (Series s, Float128 x) {
			return plot_x_min + (plot_x_max - plot_x_min) * (s.place.zoom_x_min + (x - s.axis_x.zoom_min)
			                         / (s.axis_x.zoom_max - s.axis_x.zoom_min) * (s.place.zoom_x_max - s.place.zoom_x_min));
		}

		public virtual double get_scr_y (Series s, Float128 y) {
			return plot_y_max - (plot_y_max - plot_y_min) * (s.place.zoom_y_min + (y - s.axis_y.zoom_min)
			                         / (s.axis_y.zoom_max - s.axis_y.zoom_min) * (s.place.zoom_y_max - s.place.zoom_y_min));
		}

		public virtual Point128 get_scr_point (Series s, Point128 p) {
			return Point128 (get_scr_x(s, p.x), get_scr_y(s, p.y));
		}

		public virtual Float128 get_real_x (Series s, double scr_x) {
			return s.axis_x.zoom_min + ((scr_x - plot_x_min) / (plot_x_max - plot_x_min) - s.place.zoom_x_min)
			       * (s.axis_x.zoom_max - s.axis_x.zoom_min) / (s.place.zoom_x_max - s.place.zoom_x_min);
		}

		public virtual Float128 get_real_y (Series s, double scr_y) {
			return s.axis_y.zoom_min + ((plot_y_max - scr_y) / (plot_y_max - plot_y_min) - s.place.zoom_y_min)
			       * (s.axis_y.zoom_max - s.axis_y.zoom_min) / (s.place.zoom_y_max - s.place.zoom_y_min);
		}

		public virtual Point128 get_real_point (Series s, Point128 p) {
			return Point128 (get_real_x(s, p.x), get_real_y(s, p.y));
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

		public virtual bool point_in_plot_area (Point128 p) {
			if (math.point_in_rect (p, plot_x_min, plot_x_max, plot_y_min, plot_y_max))
				return true;
			return false;
		}

		protected virtual void draw_series () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				if (s.zoom_show && s.points.length != 0)
					s.draw(this);
			}
		}

		public virtual void set_active_cursor (Point p, bool remove = false) {
			active_cursor = scr2rel_point(p);
			is_cursor_active = ! remove;
		}

		public virtual void add_active_cursor () {
			cursors.append (active_cursor);
			is_cursor_active = false;
		}

		public virtual void remove_active_cursor () {
			if (cursors.length() == 0) return;
			var distance = width * width;
			uint rm_indx = 0;
			uint i = 0;
			foreach (var c in cursors) {
				double d = distance;
				switch (cursor_style.orientation) {
				case Cursors.Orientation.VERTICAL:
					d = (rel2scr_x(c.x) - rel2scr_x(active_cursor.x)).abs();
					break;
				case Cursors.Orientation.HORIZONTAL:
					d = (rel2scr_y(c.y) - rel2scr_y(active_cursor.y)).abs();
					break;
				}
				if (d < distance) {
					distance = d;
					rm_indx = i;
				}
				++i;
			}
			if (distance < cursor_style.select_distance)
				cursors.delete_link(cursors.nth(rm_indx));
			is_cursor_active = false;
		}

		protected virtual Float128 scr2rel_x (Float128 x) {
			return rz_x_min + (x - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
		}
		protected virtual Float128 scr2rel_y (Float128 y) {
			return rz_y_max - (plot_y_max - y) / (plot_y_max - plot_y_min) * (rz_y_max - rz_y_min);
		}
		protected virtual Point scr2rel_point (Point p) {
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
