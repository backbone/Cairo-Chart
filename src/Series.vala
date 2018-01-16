using Cairo;

namespace CairoChart {

	public class Series {

		public Point128[] points = {};
		public enum Sort {
			BY_X = 0,
			BY_Y = 1,
			UNSORTED
		}
		public Sort sort = Sort.BY_X;

		public Axis axis_x = new Axis();
		public Axis axis_y = new Axis();

		public Place place = new Place();
		public Text title = new Text ();
		public Marker marker = new Marker ();

		public Grid grid = new Grid ();

		public Line.Style line_style = Line.Style ();

		protected Color _color = Color (0.0, 0.0, 0.0, 1.0);
		public Color color {
			get { return _color; }
			set {
				_color = value;
				line_style.color = _color;
				axis_x.color = _color;
				axis_y.color = _color;
				grid.color = _color;
				grid.color.alpha = 0.5;
				grid.line_style.color = _color;
				grid.line_style.color.alpha = 0.5;
			}
			default = Color (0.0, 0.0, 0.0, 1.0);
		}

		public bool zoom_show = true;

		protected Chart chart { get; protected set; default = null; }

		public Series (Chart chart) {
			this.chart = chart;
		}

		public virtual Series copy () {
			var series = new Series (chart);
			series._color = this._color;
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

		public virtual void draw (Chart chart) {
			var points = chart.math.sort_points(this, sort);
			line_style.set(chart);
			// draw series line
			for (int i = 1; i < points.length; ++i) {
				Point128 c, d;
				if (chart.math.cut_line (
				        Point128(chart.plot_x_min, chart.plot_y_min),
				        Point128(chart.plot_x_max, chart.plot_y_max),
				        Point128(chart.get_scr_x(this, points[i - 1].x), chart.get_scr_y(this, points[i - 1].y)),
				        Point128(chart.get_scr_x(this, points[i].x), chart.get_scr_y(this, points[i].y)),
				        out c, out d)
				) {
					chart.context.move_to (c.x, c.y);
					chart.context.line_to (d.x, d.y);
				}
			}
			chart.context.stroke();
			for (int i = 0; i < points.length; ++i) {
				var x = chart.get_scr_x(this, points[i].x);
				var y = chart.get_scr_y(this, points[i].y);
				if (chart.point_in_plot_area (Point128 (x, y)))
					marker.draw_at_pos(chart, x, y);
			}
		}

		public virtual bool equal_x_axis (Series s) {
			if (   axis_x.position != s.axis_x.position
			    || axis_x.zoom_min != s.axis_x.zoom_min
			    || axis_x.zoom_max != s.axis_x.zoom_max
			    || place.zoom_x_min != s.place.zoom_x_min
			    || place.zoom_x_max != s.place.zoom_x_max
			    || axis_x.type != s.axis_x.type
			)
				return false;
			return true;
		}

		public virtual bool equal_y_axis (Series s) {
			if (   axis_y.position != s.axis_y.position
			    || axis_y.zoom_min != s.axis_y.zoom_min
			    || axis_y.zoom_max != s.axis_y.zoom_max
			    || place.zoom_y_min != s.place.zoom_y_min
			    || place.zoom_y_max != s.place.zoom_y_max
			    || axis_y.type != s.axis_y.type
			)
				return false;
			return true;
		}

		public virtual void join_relative_x_axes (Chart chart,
		                                          int si,
		                                          bool calc_max_values,
		                                          ref double max_rec_width,
		                                          ref double max_rec_height,
		                                          ref double max_font_indent,
		                                          ref double max_axis_font_height,
		                                          ref int nskip) {
			for (int sj = si - 1; sj >= 0; --sj) {
				var s2 = chart.series[sj];
				if (!s2.zoom_show) continue;
				bool has_intersection = false;
				for (int sk = si; sk > sj; --sk) {
					var s3 = chart.series[sk];
					if (!s3.zoom_show) continue;
					if (chart.math.are_intersect(s2.place.zoom_x_min, s2.place.zoom_x_max, s3.place.zoom_x_min, s3.place.zoom_x_max)
					    || s2.axis_x.position != s3.axis_x.position
					    || s2.axis_x.type != s3.axis_x.type) {
						has_intersection = true;
						break;
					}
				}
				if (!has_intersection) {
					if (calc_max_values) {
						double tmp_max_rec_width = 0; double tmp_max_rec_height = 0;
						s2.axis_x.calc_rec_sizes (chart, out tmp_max_rec_width, out tmp_max_rec_height, true);
						max_rec_width = double.max (max_rec_width, tmp_max_rec_width);
						max_rec_height = double.max (max_rec_height, tmp_max_rec_height);
						max_font_indent = double.max (max_font_indent, s2.axis_x.font_indent);
						max_axis_font_height = double.max (max_axis_font_height, s2.axis_x.title.text == "" ? 0 :
						                                   s2.axis_x.title.get_height(chart.context) + this.axis_x.font_indent);
					}
					++nskip;
				} else {
					break;
				}
			}
		}

		public virtual void join_relative_y_axes (Chart chart,
		                                          int si,
		                                          bool calc_max_values,
		                                          ref double max_rec_width,
		                                          ref double max_rec_height,
		                                          ref double max_font_indent,
		                                          ref double max_axis_font_width,
		                                          ref int nskip) {
			for (int sj = si - 1; sj >= 0; --sj) {
				var s2 = chart.series[sj];
				if (!s2.zoom_show) continue;
				bool has_intersection = false;
				for (int sk = si; sk > sj; --sk) {
					var s3 = chart.series[sk];
					if (!s3.zoom_show) continue;
					if (chart.math.are_intersect(s2.place.zoom_y_min, s2.place.zoom_y_max, s3.place.zoom_y_min, s3.place.zoom_y_max)
					    || s2.axis_y.position != s3.axis_y.position
					    || s2.axis_y.type != s3.axis_y.type) {
						has_intersection = true;
						break;
					}
				}
				if (!has_intersection) {
					double tmp_max_rec_width = 0; double tmp_max_rec_height = 0;
					s2.axis_y.calc_rec_sizes (chart, out tmp_max_rec_width, out tmp_max_rec_height, false);
					max_rec_width = double.max (max_rec_width, tmp_max_rec_width);
					max_rec_height = double.max (max_rec_height, tmp_max_rec_height);
					max_font_indent = double.max (max_font_indent, s2.axis_y.font_indent);
					max_axis_font_width = double.max (max_axis_font_width, s2.axis_y.title.text == "" ? 0
					                                   : s2.axis_y.title.get_width(chart.context) + this.axis_y.font_indent);
					++nskip;
				} else {
					break;
				}
			}
		}

		protected virtual void draw_horizontal_records (Chart chart, Series s, Float128 step, double max_rec_height, Float128 x_min) {
			// 5. Draw records, update cur_{x,y}_{min,max}.
			var context = chart.context;
			var joint_x = chart.joint_x;

			for (Float128 x = x_min, x_max = s.axis_x.zoom_max; chart.math.point_belong (x, x_min, x_max); x += step) {
				if (joint_x) chart.set_source_rgba(chart.joint_axis_color);
				else chart.set_source_rgba(s.axis_x.color);
				string text = "", time_text = "";
				switch (s.axis_x.type) {
				case Axis.Type.NUMBERS:
					text = s.axis_x.format.printf((LongDouble)x);
					break;
				case Axis.Type.DATE_TIME:
					s.axis_x.format_date_time(x, out text, out time_text);
					break;
				}
				var scr_x = chart.get_scr_x (s, x);
				var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
				var sz = s.axis_x.title.get_size(context);

				switch (s.axis_x.position) {
				case Axis.Position.LOW:
					var print_y = chart.cur_y_max - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					var print_x = chart.compact_rec_x_pos (s, x, text_t);
					context.move_to (print_x, print_y);
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS:
						text_t.show(context);
						break;
					case Axis.Type.DATE_TIME:
						if (s.axis_x.date_format != "") text_t.show(context);
						var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
						print_x = chart.compact_rec_x_pos (s, x, time_text_t);
						context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
						if (s.axis_x.time_format != "") time_text_t.show(context);
						break;
					}
					// 6. Draw grid lines to the s.place.zoom_y_min.
					var line_style = s.grid.line_style;
					if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
					line_style.set(chart);
					double y = chart.cur_y_max - max_rec_height - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					context.move_to (scr_x, y);
					if (joint_x)
						context.line_to (scr_x, chart.plot_y_min);
					else
						context.line_to (scr_x, double.min (y, chart.plot_y_max - (chart.plot_y_max - chart.plot_y_min) * s.place.zoom_y_max));
					break;
				case Axis.Position.HIGH:
					var print_y = chart.cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					var print_x = chart.compact_rec_x_pos (s, x, text_t);
					context.move_to (print_x, print_y);

					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS:
						text_t.show(context);
						break;
					case Axis.Type.DATE_TIME:
						if (s.axis_x.date_format != "") text_t.show(context);
						var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
						print_x = chart.compact_rec_x_pos (s, x, time_text_t);
						context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
						if (s.axis_x.time_format != "") time_text_t.show(context);
						break;
					}
					// 6. Draw grid lines to the s.place.zoom_y_max.
					var line_style = s.grid.line_style;
					if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
					line_style.set(chart);
					double y = chart.cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					context.move_to (scr_x, y);
					if (joint_x)
						context.line_to (scr_x, chart.plot_y_max);
					else
						context.line_to (scr_x, double.max (y, chart.plot_y_max - (chart.plot_y_max - chart.plot_y_min) * s.place.zoom_y_min));
					break;
				}
			}
		}

		public virtual void draw_horizontal_axis (Chart chart, int si, ref int nskip) {
			var s = chart.series[si];
			if (!s.zoom_show) return;
			if (chart.joint_x && si != chart.zoom_first_show) return;

			// 1. Detect max record width/height by axis.nrecords equally selected points using format.
			double max_rec_width, max_rec_height;
			s.axis_x.calc_rec_sizes (chart, out max_rec_width, out max_rec_height, true);

			// 2. Calculate maximal available number of records, take into account the space width.
			long max_nrecs = (long) ((chart.plot_x_max - chart.plot_x_min) * (s.place.zoom_x_max - s.place.zoom_x_min) / max_rec_width);

			// 3. Calculate grid step.
			Float128 step = chart.math.calc_round_step ((s.axis_x.zoom_max - s.axis_x.zoom_min) / max_nrecs, s.axis_x.type == Axis.Type.DATE_TIME);
			if (step > s.axis_x.zoom_max - s.axis_x.zoom_min)
				step = s.axis_x.zoom_max - s.axis_x.zoom_min;

			// 4. Calculate x_min (s.axis_x.zoom_min / step, round, multiply on step, add step if < s.axis_x.zoom_min).
			Float128 x_min = 0.0;
			if (step >= 1) {
				int64 x_min_nsteps = (int64) (s.axis_x.zoom_min / step);
				x_min = x_min_nsteps * step;
			} else {
				int64 round_axis_x_min = (int64)s.axis_x.zoom_min;
				int64 x_min_nsteps = (int64) ((s.axis_x.zoom_min - round_axis_x_min) / step);
				x_min = round_axis_x_min + x_min_nsteps * step;
			}
			if (x_min < s.axis_x.zoom_min) x_min += step;

			// 4.2. Cursor values for joint X axis
			if (chart.joint_x && chart.cursor_style.orientation == Cursors.Orientation.VERTICAL && chart.cursors_crossings.length != 0) {
				switch (s.axis_x.position) {
				case Axis.Position.LOW: chart.cur_y_max -= max_rec_height + s.axis_x.font_indent; break;
				case Axis.Position.HIGH: chart.cur_y_min += max_rec_height + s.axis_x.font_indent; break;
				}
			}

			var sz = s.axis_x.title.get_size(chart.context);

			// 4.5. Draw Axis title
			if (s.axis_x.title.text != "") {
				var scr_x = chart.plot_x_min + (chart.plot_x_max - chart.plot_x_min) * (s.place.zoom_x_min + s.place.zoom_x_max) / 2.0;
				double scr_y = 0.0;
				switch (s.axis_x.position) {
				case Axis.Position.LOW: scr_y = chart.cur_y_max - s.axis_x.font_indent; break;
				case Axis.Position.HIGH: scr_y = chart.cur_y_min + s.axis_x.font_indent + sz.height; break;
				}
				chart.context.move_to(scr_x - sz.width / 2.0, scr_y);
				chart.set_source_rgba(s.axis_x.color);
				if (chart.joint_x) chart.set_source_rgba(chart.joint_axis_color);
				s.axis_x.title.show(chart.context);
			}

			draw_horizontal_records (chart, s, step, max_rec_height, x_min);

			chart.context.stroke ();

			double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
			s.join_relative_x_axes (chart, si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

			if (nskip != 0) {--nskip; return;}

			switch (s.axis_x.position) {
			case Axis.Position.LOW:
				chart.cur_y_max -= max_rec_height + s.axis_x.font_indent
				             + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
				break;
			case Axis.Position.HIGH:
				chart.cur_y_min += max_rec_height +  s.axis_x.font_indent
				             + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
				break;
			}
		}

		protected virtual void draw_vertical_records (Chart chart, Series s, Float128 step, double max_rec_width, Float128 y_min) {
			// 5. Draw records, update cur_{x,y}_{min,max}.
			var context = chart.context;
			var joint_y = chart.joint_y;

			for (Float128 y = y_min, y_max = s.axis_y.zoom_max; chart.math.point_belong (y, y_min, y_max); y += step) {
				if (joint_y) chart.set_source_rgba(chart.joint_axis_color);
				else chart.set_source_rgba(s.axis_y.color);
				var text = s.axis_y.format.printf((LongDouble)y);
				var scr_y = chart.get_scr_y (s, y);
				var text_t = new Text(text, s.axis_y.font_style, s.axis_y.color);
				var text_sz = text_t.get_size(context);
				var sz = s.axis_y.title.get_size(context);

				switch (s.axis_y.position) {
				case Axis.Position.LOW:
					context.move_to (chart.cur_x_min + max_rec_width - text_sz.width + s.axis_y.font_indent
					                 + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent),
					                 chart.compact_rec_y_pos (s, y, text_t));
					text_t.show(context);
					// 6. Draw grid lines to the s.place.zoom_x_min.
					var line_style = s.grid.line_style;
					if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
					line_style.set(chart);
					double x = chart.cur_x_min + max_rec_width + s.axis_y.font_indent + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent);
					context.move_to (x, scr_y);
					if (joint_y)
						context.line_to (chart.plot_x_max, scr_y);
					else
						context.line_to (double.max (x, chart.plot_x_min + (chart.plot_x_max - chart.plot_x_min) * s.place.zoom_x_max), scr_y);
					break;
				case Axis.Position.HIGH:
					context.move_to (chart.cur_x_max - text_sz.width - s.axis_y.font_indent
					                 - (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent),
					                 chart.compact_rec_y_pos (s, y, text_t));
					text_t.show(context);
					// 6. Draw grid lines to the s.place.zoom_x_max.
					var line_style = s.grid.line_style;
					if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
					line_style.set(chart);
					double x = chart.cur_x_max - max_rec_width - s.axis_y.font_indent - (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent);
					context.move_to (x, scr_y);
					if (joint_y)
						context.line_to (chart.plot_x_min, scr_y);
					else
						context.line_to (double.min (x, chart.plot_x_min + (chart.plot_x_max - chart.plot_x_min) * s.place.zoom_x_min), scr_y);
					break;
				}
			}
		}

		public virtual void draw_vertical_axis (Chart chart, int si, ref int nskip) {
			var s = chart.series[si];
			if (!s.zoom_show) return;
			if (chart.joint_y && si != chart.zoom_first_show) return;
			// 1. Detect max record width/height by axis.nrecords equally selected points using format.
			double max_rec_width, max_rec_height;
			s.axis_y.calc_rec_sizes (chart, out max_rec_width, out max_rec_height, false);

			// 2. Calculate maximal available number of records, take into account the space width.
			long max_nrecs = (long) ((chart.plot_y_max - chart.plot_y_min) * (s.place.zoom_y_max - s.place.zoom_y_min) / max_rec_height);

			// 3. Calculate grid step.
			Float128 step = chart.math.calc_round_step ((s.axis_y.zoom_max - s.axis_y.zoom_min) / max_nrecs);
			if (step > s.axis_y.zoom_max - s.axis_y.zoom_min)
				step = s.axis_y.zoom_max - s.axis_y.zoom_min;

			// 4. Calculate y_min (s.axis_y.zoom_min / step, round, multiply on step, add step if < s.axis_y.zoom_min).
			Float128 y_min = 0.0;
			if (step >= 1) {
				int64 y_min_nsteps = (int64) (s.axis_y.zoom_min / step);
				y_min = y_min_nsteps * step;
			} else {
				int64 round_axis_y_min = (int64)s.axis_y.zoom_min;
				int64 y_min_nsteps = (int64) ((s.axis_y.zoom_min - round_axis_y_min) / step);
				y_min = round_axis_y_min + y_min_nsteps * step;
			}
			if (y_min < s.axis_y.zoom_min) y_min += step;

			// 4.2. Cursor values for joint Y axis
			if (chart.joint_y && chart.cursor_style.orientation == Cursors.Orientation.HORIZONTAL && chart.cursors_crossings.length != 0) {
				switch (s.axis_y.position) {
				case Axis.Position.LOW: chart.cur_x_min += max_rec_width + s.axis_y.font_indent; break;
				case Axis.Position.HIGH: chart.cur_x_max -= max_rec_width + s.axis_y.font_indent; break;
				}
			}

			var sz = s.axis_y.title.get_size(chart.context);

			// 4.5. Draw Axis title
			if (s.axis_y.title.text != "") {
				var scr_y = chart.plot_y_max - (chart.plot_y_max - chart.plot_y_min) * (s.place.zoom_y_min + s.place.zoom_y_max) / 2.0;
				switch (s.axis_y.position) {
				case Axis.Position.LOW:
					var scr_x = chart.cur_x_min + s.axis_y.font_indent + sz.width;
					chart.context.move_to(scr_x, scr_y + sz.height / 2.0);
					break;
				case Axis.Position.HIGH:
					var scr_x = chart.cur_x_max - s.axis_y.font_indent;
					chart.context.move_to(scr_x, scr_y + sz.height / 2.0);
					break;
				}
				chart.set_source_rgba(s.axis_y.color);
				if (chart.joint_y) chart.set_source_rgba(chart.joint_axis_color);
				s.axis_y.title.show(chart.context);
			}

			draw_vertical_records (chart, s, step, max_rec_width, y_min);

			chart.context.stroke ();

			double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
			s.join_relative_y_axes (chart, si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

			if (nskip != 0) {--nskip; return;}

			switch (s.axis_y.position) {
			case Axis.Position.LOW:
				chart.cur_x_min += max_rec_width + s.axis_y.font_indent
				             + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent); break;
			case Axis.Position.HIGH:
				chart.cur_x_max -= max_rec_width + s.axis_y.font_indent
				             + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent); break;
			}
		}

		public virtual double compact_rec_x_pos (Series s, Float128 x, Text text) {
			var sz = text.get_size(chart.context);
			return chart.get_scr_x(s, x) - sz.width / 2.0
			       - sz.width * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
		}

		public virtual double compact_rec_y_pos (Series s, Float128 y, Text text) {
			var sz = text.get_size(chart.context);
			return chart.get_scr_y(s, y) + sz.height / 2.0
			       + sz.height * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min);
		}
	}
}
