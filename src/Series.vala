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

		public Area place = new Area();
		public Text title = new Text ();
		public Marker marker = new Marker ();

		public Grid grid = new Grid ();

		public LineStyle line_style = LineStyle ();

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
					marker.draw_at_pos(chart, x, y);
			}
		}

		public virtual bool equal_x_axis (Series s) {
			if (   axis_x.position != s.axis_x.position
			    || axis_x.zoom_min != s.axis_x.zoom_min
			    || axis_x.zoom_max != s.axis_x.zoom_max
			    || place.zx0 != s.place.zx0
			    || place.zx1 != s.place.zx1
			    || axis_x.type != s.axis_x.type
			)
				return false;
			return true;
		}

		public virtual bool equal_y_axis (Series s) {
			if (   axis_y.position != s.axis_y.position
			    || axis_y.zoom_min != s.axis_y.zoom_min
			    || axis_y.zoom_max != s.axis_y.zoom_max
			    || place.zy0 != s.place.zy0
			    || place.zy1 != s.place.zy1
			    || axis_y.type != s.axis_y.type
			)
				return false;
			return true;
		}

		public virtual void join_axes (bool is_x, int si, ref int nskip) {
			var s = chart.series[si];
			Axis axis = s.axis_x;
			if (!is_x) axis = s.axis_y;
			if (!s.zoom_show) return;
			if (nskip != 0) {--nskip; return;}
			double max_rec_width = 0; double max_rec_height = 0;
			axis.calc_rec_sizes (chart, out max_rec_width, out max_rec_height, is_x);
			var max_font_spacing = axis.font_spacing;
			var max_axis_font_width = axis.title.text == "" ? 0 : axis.title.get_width(chart.ctx) + axis.font_spacing;
			var max_axis_font_height = axis.title.text == "" ? 0 : axis.title.get_height(chart.ctx) + axis.font_spacing;

			if (is_x)
				s.join_relative_x_axes (si, true, ref max_rec_width, ref max_rec_height, ref max_font_spacing, ref max_axis_font_height, ref nskip);
			else
				s.join_relative_y_axes (si, true, ref max_rec_width, ref max_rec_height, ref max_font_spacing, ref max_axis_font_width, ref nskip);

			// for 4.2. Cursor values for joint X axis
			if (si == chart.zoom_1st_idx && chart.cursors.cursors_crossings.length != 0) {
				switch (chart.cursors.cursor_style.orientation) {
				case Cursors.Orientation.VERTICAL:
					if (is_x && chart.joint_x) {
						var tmp = max_rec_height + axis.font_spacing;
						switch (axis.position) {
						case Axis.Position.LOW: chart.plarea.y1 -= tmp; break;
						case Axis.Position.HIGH: chart.plarea.y0 += tmp; break;
						}
					}
					break;
				case Cursors.Orientation.HORIZONTAL:
					if (!is_x && chart.joint_y) {
						var tmp = max_rec_width + s.axis_y.font_spacing;
						switch (s.axis_y.position) {
						case Axis.Position.LOW: chart.plarea.x0 += tmp; break;
						case Axis.Position.HIGH: chart.plarea.x1 -= tmp; break;
						}
					}
					break;
				}
			}
			if (is_x && (!chart.joint_x || si == chart.zoom_1st_idx)) {
				var tmp = max_rec_height + max_font_spacing + max_axis_font_height;
				switch (axis.position) {
				case Axis.Position.LOW: chart.plarea.y1 -= tmp; break;
				case Axis.Position.HIGH: chart.plarea.y0 += tmp; break;
				}
			}
			if (!is_x && (!chart.joint_y || si == chart.zoom_1st_idx)) {
				var tmp = max_rec_width + max_font_spacing + max_axis_font_width;
				switch (s.axis_y.position) {
				case Axis.Position.LOW: chart.plarea.x0 += tmp; break;
				case Axis.Position.HIGH: chart.plarea.x1 -= tmp; break;
				}
			}
		}

		public virtual void join_relative_x_axes (int si,
		                                          bool calc_max_values,
		                                          ref double max_rec_width,
		                                          ref double max_rec_height,
		                                          ref double max_font_spacing,
		                                          ref double max_axis_font_height,
		                                          ref int nskip) {
			for (int sj = si - 1; sj >= 0; --sj) {
				var s2 = chart.series[sj];
				if (!s2.zoom_show) continue;
				bool has_intersection = false;
				for (int sk = si; sk > sj; --sk) {
					var s3 = chart.series[sk];
					if (!s3.zoom_show) continue;
					if (Math.coord_cross(s2.place.zx0, s2.place.zx1, s3.place.zx0, s3.place.zx1)
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
						max_font_spacing = double.max (max_font_spacing, s2.axis_x.font_spacing);
						max_axis_font_height = double.max (max_axis_font_height, s2.axis_x.title.text == "" ? 0 :
						                                   s2.axis_x.title.get_height(chart.ctx) + this.axis_x.font_spacing);
					}
					++nskip;
				} else {
					break;
				}
			}
		}

		public virtual void join_relative_y_axes (int si,
		                                          bool calc_max_values,
		                                          ref double max_rec_width,
		                                          ref double max_rec_height,
		                                          ref double max_font_spacing,
		                                          ref double max_axis_font_width,
		                                          ref int nskip) {
			for (int sj = si - 1; sj >= 0; --sj) {
				var s2 = chart.series[sj];
				if (!s2.zoom_show) continue;
				bool has_intersection = false;
				for (int sk = si; sk > sj; --sk) {
					var s3 = chart.series[sk];
					if (!s3.zoom_show) continue;
					if (Math.coord_cross(s2.place.zy0, s2.place.zy1, s3.place.zy0, s3.place.zy1)
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
					max_font_spacing = double.max (max_font_spacing, s2.axis_y.font_spacing);
					max_axis_font_width = double.max (max_axis_font_width, s2.axis_y.title.text == "" ? 0
					                                   : s2.axis_y.title.get_width(chart.ctx) + this.axis_y.font_spacing);
					++nskip;
				} else {
					break;
				}
			}
		}

		protected virtual void draw_horizontal_records (Float128 step, double max_rec_height, Float128 x_min) {
			// 5. Draw records, update cur_{x,y}_{min,max}.
			var ctx = chart.ctx;
			var joint_x = chart.joint_x;

			for (Float128 x = x_min, x_max = axis_x.zoom_max; Math.point_belong (x, x_min, x_max); x += step) {
				if (joint_x) chart.color = chart.joint_color;
				else chart.color = axis_x.color;
				string text = "", time_text = "";
				switch (axis_x.type) {
				case Axis.Type.NUMBERS: text = axis_x.format.printf((LongDouble)x); break;
				case Axis.Type.DATE_TIME: axis_x.format_date_time(x, out text, out time_text); break;
				}
				var scr_x = get_scr_x (x);
				var text_t = new Text(text, axis_x.font_style, axis_x.color);
				var sz = axis_x.title.get_size(ctx);

				switch (axis_x.position) {
				case Axis.Position.LOW:
					var print_y = chart.evarea.y1 - axis_x.font_spacing - (axis_x.title.text == "" ? 0 : sz.height + axis_x.font_spacing);
					var print_x = compact_rec_x_pos (x, text_t);
					ctx.move_to (print_x, print_y);
					switch (axis_x.type) {
					case Axis.Type.NUMBERS:
						text_t.show(ctx);
						break;
					case Axis.Type.DATE_TIME:
						if (axis_x.date_format != "") text_t.show(ctx);
						var time_text_t = new Text(time_text, axis_x.font_style, axis_x.color);
						print_x = compact_rec_x_pos (x, time_text_t);
						ctx.move_to (print_x, print_y - (axis_x.date_format == "" ? 0 : text_t.get_height(ctx) + axis_x.font_spacing));
						if (axis_x.time_format != "") time_text_t.show(ctx);
						break;
					}
					// 6. Draw grid lines to the place.zy0.
					var line_style = grid.line_style;
					if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
					line_style.apply(chart);
					double y = chart.evarea.y1 - max_rec_height - axis_x.font_spacing - (axis_x.title.text == "" ? 0 : sz.height + axis_x.font_spacing);
					ctx.move_to (scr_x, y);
					if (joint_x)
						ctx.line_to (scr_x, chart.plarea.y0);
					else
						ctx.line_to (scr_x, double.min (y, chart.plarea.y0 + chart.plarea.height * (1.0 - place.zy1)));
					break;
				case Axis.Position.HIGH:
					var print_y = chart.evarea.y0 + max_rec_height + axis_x.font_spacing + (axis_x.title.text == "" ? 0 : sz.height + axis_x.font_spacing);
					var print_x = compact_rec_x_pos (x, text_t);
					ctx.move_to (print_x, print_y);

					switch (axis_x.type) {
					case Axis.Type.NUMBERS:
						text_t.show(ctx);
						break;
					case Axis.Type.DATE_TIME:
						if (axis_x.date_format != "") text_t.show(ctx);
						var time_text_t = new Text(time_text, axis_x.font_style, axis_x.color);
						print_x = compact_rec_x_pos (x, time_text_t);
						ctx.move_to (print_x, print_y - (axis_x.date_format == "" ? 0 : text_t.get_height(ctx) + axis_x.font_spacing));
						if (axis_x.time_format != "") time_text_t.show(ctx);
						break;
					}
					// 6. Draw grid lines to the place.zy1.
					var line_style = grid.line_style;
					if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
					line_style.apply(chart);
					double y = chart.evarea.y0 + max_rec_height + axis_x.font_spacing + (axis_x.title.text == "" ? 0 : sz.height + axis_x.font_spacing);
					ctx.move_to (scr_x, y);
					if (joint_x)
						ctx.line_to (scr_x, chart.plarea.y1);
					else
						ctx.line_to (scr_x, double.max (y, chart.plarea.y0 + chart.plarea.height * (1.0 - place.zy0)));
					break;
				}
			}
		}

		public virtual void draw_horizontal_axis (int si, ref int nskip) {
			var s = chart.series[si];
			if (!s.zoom_show) return;
			if (chart.joint_x && si != chart.zoom_1st_idx) return;

			// 1. Detect max record width/height by axis.nrecords equally selected points using format.
			double max_rec_width, max_rec_height;
			s.axis_x.calc_rec_sizes (chart, out max_rec_width, out max_rec_height, true);

			// 2. Calculate maximal available number of records, take into account the space width.
			long max_nrecs = (long) (chart.plarea.width * (s.place.zx1 - s.place.zx0) / max_rec_width);

			// 3. Calculate grid step.
			Float128 step = Math.calc_round_step ((s.axis_x.zoom_max - s.axis_x.zoom_min) / max_nrecs, s.axis_x.type == Axis.Type.DATE_TIME);
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
			if (chart.joint_x && chart.cursors.cursor_style.orientation == Cursors.Orientation.VERTICAL && chart.cursors.cursors_crossings.length != 0) {
				var tmp = max_rec_height + s.axis_x.font_spacing;
				switch (s.axis_x.position) {
				case Axis.Position.LOW: chart.evarea.y1 -= tmp; break;
				case Axis.Position.HIGH:  chart.evarea.y0 += tmp; break;
				}
			}

			var sz = s.axis_x.title.get_size(chart.ctx);

			// 4.5. Draw Axis title
			if (s.axis_x.title.text != "") {
				var scr_x = chart.plarea.x0 + chart.plarea.width * (s.place.zx0 + s.place.zx1) / 2.0;
				double scr_y = 0.0;
				switch (s.axis_x.position) {
				case Axis.Position.LOW: scr_y = chart.evarea.y1 - s.axis_x.font_spacing; break;
				case Axis.Position.HIGH: scr_y = chart.evarea.y0 + s.axis_x.font_spacing + sz.height; break;
				}
				chart.ctx.move_to(scr_x - sz.width / 2.0, scr_y);
				chart.color = s.axis_x.color;
				if (chart.joint_x) chart.color = chart.joint_color;
				s.axis_x.title.show(chart.ctx);
			}

			s.draw_horizontal_records (step, max_rec_height, x_min);

			chart.ctx.stroke ();

			double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
			s.join_relative_x_axes (si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

			if (nskip != 0) {--nskip; return;}

			var tmp = max_rec_height + s.axis_x.font_spacing + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_spacing);
			switch (s.axis_x.position) {
			case Axis.Position.LOW: chart.evarea.y1 -= tmp; break;
			case Axis.Position.HIGH: chart.evarea.y0 += tmp; break;
			}
		}

		protected virtual void draw_vertical_records (Float128 step, double max_rec_width, Float128 y_min) {
			// 5. Draw records, update cur_{x,y}_{min,max}.
			var ctx = chart.ctx;
			var joint_y = chart.joint_y;

			for (Float128 y = y_min, y_max = axis_y.zoom_max; Math.point_belong (y, y_min, y_max); y += step) {
				if (joint_y) chart.color = chart.joint_color;
				else chart.color = axis_y.color;
				var text = axis_y.format.printf((LongDouble)y);
				var scr_y = get_scr_y (y);
				var text_t = new Text(text, axis_y.font_style, axis_y.color);
				var text_sz = text_t.get_size(ctx);
				var sz = axis_y.title.get_size(ctx);

				switch (axis_y.position) {
				case Axis.Position.LOW:
					ctx.move_to (chart.evarea.x0 + max_rec_width - text_sz.width + axis_y.font_spacing
					                 + (axis_y.title.text == "" ? 0 : sz.width + axis_y.font_spacing),
					                 compact_rec_y_pos (y, text_t));
					text_t.show(ctx);
					// 6. Draw grid lines to the place.zx0.
					var line_style = grid.line_style;
					if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
					line_style.apply(chart);
					double x = chart.evarea.x0 + max_rec_width + axis_y.font_spacing + (axis_y.title.text == "" ? 0 : sz.width + axis_y.font_spacing);
					ctx.move_to (x, scr_y);
					if (joint_y)
						ctx.line_to (chart.plarea.x1, scr_y);
					else
						ctx.line_to (double.max (x, chart.plarea.x0 + chart.plarea.width * place.zx1), scr_y);
					break;
				case Axis.Position.HIGH:
					ctx.move_to (chart.evarea.x1 - text_sz.width - axis_y.font_spacing
					                 - (axis_y.title.text == "" ? 0 : sz.width + axis_y.font_spacing),
					                 compact_rec_y_pos (y, text_t));
					text_t.show(ctx);
					// 6. Draw grid lines to the place.zx1.
					var line_style = grid.line_style;
					if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
					line_style.apply(chart);
					double x = chart.evarea.x1 - max_rec_width - axis_y.font_spacing - (axis_y.title.text == "" ? 0 : sz.width + axis_y.font_spacing);
					ctx.move_to (x, scr_y);
					if (joint_y)
						ctx.line_to (chart.plarea.x0, scr_y);
					else
						ctx.line_to (double.min (x, chart.plarea.x0 + chart.plarea.width * place.zx0), scr_y);
					break;
				}
			}
		}

		public virtual void draw_vertical_axis (int si, ref int nskip) {
			var s = chart.series[si];
			if (!s.zoom_show) return;
			if (chart.joint_y && si != chart.zoom_1st_idx) return;
			// 1. Detect max record width/height by axis.nrecords equally selected points using format.
			double max_rec_width, max_rec_height;
			s.axis_y.calc_rec_sizes (chart, out max_rec_width, out max_rec_height, false);

			// 2. Calculate maximal available number of records, take into account the space width.
			long max_nrecs = (long) (chart.plarea.height * (s.place.zy1 - s.place.zy0) / max_rec_height);

			// 3. Calculate grid step.
			Float128 step = Math.calc_round_step ((s.axis_y.zoom_max - s.axis_y.zoom_min) / max_nrecs);
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
			if (chart.joint_y && chart.cursors.cursor_style.orientation == Cursors.Orientation.HORIZONTAL && chart.cursors.cursors_crossings.length != 0) {
				var tmp = max_rec_width + s.axis_y.font_spacing;
				switch (s.axis_y.position) {
				case Axis.Position.LOW: chart.evarea.x0 += tmp; break;
				case Axis.Position.HIGH: chart.evarea.x1 -= tmp; break;
				}
			}

			var sz = s.axis_y.title.get_size(chart.ctx);

			// 4.5. Draw Axis title
			if (s.axis_y.title.text != "") {
				var scr_y = chart.plarea.y0 + chart.plarea.height * (1.0 - (s.place.zy0 + s.place.zy1) / 2.0);
				switch (s.axis_y.position) {
				case Axis.Position.LOW:
					var scr_x = chart.evarea.x0 + s.axis_y.font_spacing + sz.width;
					chart.ctx.move_to(scr_x, scr_y + sz.height / 2.0);
					break;
				case Axis.Position.HIGH:
					var scr_x = chart.evarea.x1 - s.axis_y.font_spacing;
					chart.ctx.move_to(scr_x, scr_y + sz.height / 2.0);
					break;
				}
				chart.color = s.axis_y.color;
				if (chart.joint_y) chart.color = chart.joint_color;
				s.axis_y.title.show(chart.ctx);
			}

			s.draw_vertical_records (step, max_rec_width, y_min);

			chart.ctx.stroke ();

			double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
			s.join_relative_y_axes (si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

			if (nskip != 0) {--nskip; return;}

			var tmp = max_rec_width + s.axis_y.font_spacing + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_spacing);
			switch (s.axis_y.position) {
			case Axis.Position.LOW: chart.evarea.x0 += tmp; break;
			case Axis.Position.HIGH: chart.evarea.x1 -= tmp; break;
			}
		}

		public virtual double compact_rec_x_pos (Float128 x, Text text) {
			var sz = text.get_size(chart.ctx);
			return get_scr_x(x) - sz.width / 2.0
			       - sz.width * (x - (axis_x.zoom_min + axis_x.zoom_max) / 2.0) / (axis_x.zoom_max - axis_x.zoom_min);
		}

		public virtual double compact_rec_y_pos (Float128 y, Text text) {
			var sz = text.get_size(chart.ctx);
			return get_scr_y(y) + sz.height / 2.0
			       + sz.height * (y - (axis_y.zoom_min + axis_y.zoom_max) / 2.0) / (axis_y.zoom_max - axis_y.zoom_min);
		}

		public virtual double get_scr_x (Float128 x) {
			return chart.plarea.x0 + chart.plarea.width * (place.zx0 + (x - axis_x.zoom_min) / (axis_x.zoom_max - axis_x.zoom_min) * (place.zx1 - place.zx0));
		}

		public virtual double get_scr_y (Float128 y) {
			return chart.plarea.y0 + chart.plarea.height * (1.0 - (place.zy0 + (y - axis_y.zoom_min) / (axis_y.zoom_max - axis_y.zoom_min) * (place.zy1 - place.zy0)));
		}

		public virtual Point get_scr_point (Point128 p) {
			return Point (get_scr_x(p.x), get_scr_y(p.y));
		}

		public virtual Float128 get_real_x (double scr_x) {
			return axis_x.zoom_min + ((scr_x - chart.plarea.x0) / chart.plarea.width - place.zx0)
			       * (axis_x.zoom_max - axis_x.zoom_min) / (place.zx1 - place.zx0);
		}

		public virtual Float128 get_real_y (double scr_y) {
			return axis_y.zoom_min + ((chart.plarea.y1 - scr_y) / chart.plarea.height - place.zy0)
			       * (axis_y.zoom_max - axis_y.zoom_min) / (place.zy1 - place.zy0);
		}

		public virtual Point128 get_real_point (Point p) {
			return Point128 (get_real_x(p.x), get_real_y(p.y));
		}

		public virtual void unzoom () {
				zoom_show = true;
				axis_x.unzoom();
				axis_y.unzoom();
				place.unzoom();
		}
	}
}
