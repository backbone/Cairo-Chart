namespace Gtk.CairoChart {
	public class Chart {

		public double x_min = 0.0;
		public double y_min = 0.0;
		public double width = 0.0;
		public double height = 0.0;

		public Cairo.Context context = null;

		public Color bg_color;
		public bool show_legend = true;
		public Text title = new Text ("Cairo Chart");
		public Color border_color = Color(0, 0, 0, 0.3);


		public Legend legend = new Legend ();

		public Series[] series = {};

		protected LineStyle selection_style = LineStyle ();

		public Chart () {
			bg_color = Color (1, 1, 1);
		}

		protected double cur_x_min = 0.0;
		protected double cur_x_max = 1.0;
		protected double cur_y_min = 0.0;
		protected double cur_y_max = 1.0;

		public virtual void check_cur_values () {
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

			draw_legend ();
			check_cur_values ();

			set_vertical_axes_titles ();

			get_cursors_crossings();

			calc_plot_area (); // Calculate plot area

			draw_horizontal_axis ();
			check_cur_values ();

			draw_vertical_axis ();
			check_cur_values ();

			draw_plot_area_border ();
			check_cur_values ();

			draw_series ();
			check_cur_values ();

			draw_cursors ();
			check_cur_values ();

			return true;
		}

		protected virtual void set_source_rgba (Color color) {
				context.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		}

		protected virtual void draw_background () {
			if (context != null) {
				set_source_rgba (bg_color);
				context.paint();
				set_source_rgba (Color (0, 0, 0, 1));
			}
		}

		double _rel_zoom_x_min = 0.0;
		double _rel_zoom_x_max = 1.0;
		double _rel_zoom_y_min = 0.0;
		double _rel_zoom_y_max = 1.0;
		public double rel_zoom_x_min { get { return _rel_zoom_x_min; } default = 0.0; }
		public double rel_zoom_x_max { get { return _rel_zoom_x_max; } default = 1.0; }
		public double rel_zoom_y_min { get { return _rel_zoom_y_min; } default = 0.0; }
		public double rel_zoom_y_max { get { return _rel_zoom_y_max; } default = 1.0; }

		int zoom_first_show = 0;

		public virtual void zoom_in (double x0, double y0, double x1, double y1) {
			for (var si = 0, max_i = series.length; si < max_i; ++si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				var real_x0 = get_real_x (s, x0);
				var real_x1 = get_real_x (s, x1);
				var real_y0 = get_real_y (s, y0);
				var real_y1 = get_real_y (s, y1);
				// if selected square does not intersect with the series's square
				if (   real_x1 <= s.axis_x.zoom_min || real_x0 >= s.axis_x.zoom_max
					|| real_y0 <= s.axis_y.zoom_min || real_y1 >= s.axis_y.zoom_max) {
					s.zoom_show = false;
					continue;
				}
				if (real_x0 >= s.axis_x.zoom_min) {
					s.axis_x.zoom_min = real_x0;
					s.place.zoom_x_low = 0.0;
				} else {
					s.place.zoom_x_low = (s.axis_x.zoom_min - real_x0) / (real_x1 - real_x0);
				}
				if (real_x1 <= s.axis_x.zoom_max) {
					s.axis_x.zoom_max = real_x1;
					s.place.zoom_x_high = 1.0;
				} else {
					s.place.zoom_x_high = (s.axis_x.zoom_max - real_x0) / (real_x1 - real_x0);
				}
				if (real_y1 >= s.axis_y.zoom_min) {
					s.axis_y.zoom_min = real_y1;
					s.place.zoom_y_low = 0.0;
				} else {
					s.place.zoom_y_low = (s.axis_y.zoom_min - real_y1) / (real_y0 - real_y1);
				}
				if (real_y0 <= s.axis_y.zoom_max) {
					s.axis_y.zoom_max = real_y0;
					s.place.zoom_y_high = 1.0;
				} else {
					s.place.zoom_y_high = (s.axis_y.zoom_max - real_y1) / (real_y0 - real_y1);
				}
			}

			zoom_first_show = 0;
			for (var si = 0, max_i = series.length; si < max_i; ++si)
				if (series[si].zoom_show) {
					zoom_first_show = si;
					break;
				}

			var new_rel_zoom_x_min = _rel_zoom_x_min + (x0 - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) * (_rel_zoom_x_max - _rel_zoom_x_min);
			var new_rel_zoom_x_max = _rel_zoom_x_min + (x1 - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) * (_rel_zoom_x_max - _rel_zoom_x_min);
			var new_rel_zoom_y_min = _rel_zoom_y_min + (y0 - plot_area_y_min) / (plot_area_y_max - plot_area_y_min) * (_rel_zoom_y_max - _rel_zoom_y_min);
			var new_rel_zoom_y_max = _rel_zoom_y_min + (y1 - plot_area_y_min) / (plot_area_y_max - plot_area_y_min) * (_rel_zoom_y_max - _rel_zoom_y_min);
			_rel_zoom_x_min = new_rel_zoom_x_min;
			_rel_zoom_x_max = new_rel_zoom_x_max;
			_rel_zoom_y_min = new_rel_zoom_y_min;
			_rel_zoom_y_max = new_rel_zoom_y_max;
		}

		public virtual void zoom_out () {
			foreach (var s in series) {
				s.zoom_show = true;
				s.axis_x.zoom_min = s.axis_x.min;
				s.axis_x.zoom_max = s.axis_x.max;
				s.axis_y.zoom_min = s.axis_y.min;
				s.axis_y.zoom_max = s.axis_y.max;
				s.place.zoom_x_low = s.place.x_low;
				s.place.zoom_x_high = s.place.x_high;
				s.place.zoom_y_low = s.place.y_low;
				s.place.zoom_y_high = s.place.y_high;
			}
			_rel_zoom_x_min = 0;
			_rel_zoom_x_max = 1;
			_rel_zoom_y_min = 0;
			_rel_zoom_y_max = 1;

			zoom_first_show = 0;
		}

		public virtual void move (double delta_x, double delta_y) {
			delta_x /= plot_area_x_max - plot_area_x_min; delta_x *= - 1.0;
			delta_y /= plot_area_y_max - plot_area_y_min; delta_y *= - 1.0;
			var rzxmin = _rel_zoom_x_min, rzxmax = _rel_zoom_x_max, rzymin = _rel_zoom_y_min, rzymax = _rel_zoom_y_max;
			zoom_out();
			//draw(); // TODO: optimize here
			delta_x *= plot_area_x_max - plot_area_x_min;
			delta_y *= plot_area_y_max - plot_area_y_min;
			var xmin = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * rzxmin;
			var xmax = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * rzxmax;
			var ymin = plot_area_y_min + (plot_area_y_max - plot_area_y_min) * rzymin;
			var ymax = plot_area_y_min + (plot_area_y_max - plot_area_y_min) * rzymax;

			delta_x *= rzxmax - rzxmin; delta_y *= rzymax - rzymin;

			if (xmin + delta_x < plot_area_x_min) delta_x = plot_area_x_min - xmin;
			if (xmax + delta_x > plot_area_x_max) delta_x = plot_area_x_max - xmax;
			if (ymin + delta_y < plot_area_y_min) delta_y = plot_area_y_min - ymin;
			if (ymax + delta_y > plot_area_y_max) delta_y = plot_area_y_max - ymax;

			zoom_in (xmin + delta_x, ymin + delta_y, xmax + delta_x, ymax + delta_y);
			//draw(); // TODO: optimize here
		}

		protected double title_width = 0.0;
		protected double title_height = 0.0;

		public double title_vindent = 4;

		protected virtual void show_text(Text text) {
			context.select_font_face(text.style.family,
			                         text.style.slant,
			                         text.style.weight);
			context.set_font_size(text.style.size);
			if (text.style.orientation == FontOrient.VERTICAL) {
				context.rotate(- Math.PI / 2.0);
				context.show_text(text.text);
				context.rotate(Math.PI / 2.0);
			} else {
				context.show_text(text.text);
			}
		}

		protected virtual void draw_chart_title () {
			title_width = title.get_width (context);
			title_height = title.get_height (context) + (legend.position == Legend.Position.TOP ? title_vindent * 2 : title_vindent);
			cur_y_min += title_height;
			set_source_rgba(title.color);
			context.move_to (width/2 - title_width/2 - title.get_x_bearing(context), title.get_height(context) + title_vindent);
			show_text(title);
		}

		protected double legend_width = 0;
		protected double legend_height = 0;

		protected enum LegendProcessType {
			CALC = 0, // default
			DRAW
		}

		protected virtual void set_line_style (LineStyle style) {
			set_source_rgba(style.color);
			context.set_line_join(style.line_join);
			context.set_line_cap(style.line_cap);
			context.set_line_width(style.width);
			context.set_dash(style.dashes, style.dash_offset);
		}

		protected virtual void draw_legend_rect (out double x0, out double y0) {
			x0 = y0 = 0.0;
			if (context != null) {
				switch (legend.position) {
				case Legend.Position.TOP:
					x0 = (width - legend_width) / 2;
					y0 = title_height;
				break;

				case Legend.Position.BOTTOM:
					x0 = (width - legend_width) / 2;
					y0 = height - legend_height;
				break;

				case Legend.Position.LEFT:
					x0 = 0;
					y0 = (height - legend_height) / 2;
				break;

				case Legend.Position.RIGHT:
					x0 = width - legend_width;
					y0 = (height - legend_height) / 2;
				break;
				}
				set_source_rgba(legend.bg_color);
				context.rectangle (x0, y0, legend_width, legend_height);
				context.fill();
				set_line_style(legend.border_style);
				context.move_to (x0, y0);
				context.rel_line_to (legend_width, 0);
				context.rel_line_to (0, legend_height);
				context.rel_line_to (-legend_width, 0);
				context.rel_line_to (0, -legend_height);
				context.stroke ();
			}
		}

		public double legend_line_length = 30.0;
		public double legend_text_hspace = 10.0;
		public double legend_text_vspace = 2.0;
		public double marker_size = 8.0;

		protected virtual void draw_marker_at_pos (Series.MarkerType marker_type,
		                                           double x, double y) {
			context.move_to (x, y);
			switch (marker_type) {
			case Series.MarkerType.SQUARE:
				context.rectangle (x - marker_size / 2, y - marker_size / 2,
				                   marker_size, marker_size);
				context.fill();
				break;

			case Series.MarkerType.CIRCLE:
				context.arc (x, y, marker_size / 2, 0, 2*Math.PI);
				context.fill();
				break;

			case Series.MarkerType.TRIANGLE:
				context.move_to (x - marker_size / 2, y - marker_size / 2);
				context.line_to (x + marker_size / 2, y - marker_size / 2);
				context.line_to (x, y + marker_size / 2);
				context.line_to (x - marker_size / 2, y - marker_size / 2);
				context.fill();
				break;

			case Series.MarkerType.PRICLE_SQUARE:
				context.rectangle (x - marker_size / 2, y - marker_size / 2,
				                   marker_size, marker_size);
				context.stroke();
				break;

			case Series.MarkerType.PRICLE_CIRCLE:
				context.arc (x, y, marker_size / 2, 0, 2*Math.PI);
				context.stroke();
				break;

			case Series.MarkerType.PRICLE_TRIANGLE:
				context.move_to (x - marker_size / 2, y - marker_size / 2);
				context.line_to (x + marker_size / 2, y - marker_size / 2);
				context.line_to (x, y + marker_size / 2);
				context.line_to (x - marker_size / 2, y - marker_size / 2);
				context.stroke();
				break;
			}
		}

		double [] max_font_heights;
		protected virtual void process_legend (LegendProcessType process_type) {
			var legend_x0 = 0.0, legend_y0 = 0.0;
			var heights_idx = 0;
			var leg_width_sum = 0.0;
			var leg_height_sum = 0.0;
			double max_font_h = 0.0;

			// prepare
			switch (process_type) {
			case LegendProcessType.CALC:
				legend_width = 0.0;
				legend_height = 0.0;
				max_font_heights = {};
				heights_idx = 0;
				break;
			case LegendProcessType.DRAW:
				draw_legend_rect(out legend_x0, out legend_y0);
				break;
			}

			foreach (var s in series) {

				if (!s.zoom_show) continue;

				// carry
				switch (legend.position) {
				case Legend.Position.TOP:
				case Legend.Position.BOTTOM:
					var ser_title_width = s.title.get_width(context) + legend_line_length;
					if (leg_width_sum + (leg_width_sum == 0 ? 0 : legend_text_hspace) + ser_title_width > width) { // carry
						leg_height_sum += max_font_h;
						switch (process_type) {
						case LegendProcessType.CALC:
							max_font_heights += max_font_h;
							legend_width = double.max(legend_width, leg_width_sum);
							break;
						case LegendProcessType.DRAW:
							heights_idx++;
							break;
						}
						leg_width_sum = 0.0;
						max_font_h = 0;
					}
					break;
				}

				switch (process_type) {
				case LegendProcessType.DRAW:
					var x = legend_x0 + leg_width_sum + (leg_width_sum == 0.0 ? 0.0 : legend_text_hspace);
					var y = legend_y0 + leg_height_sum + max_font_heights[heights_idx];

					// series title
					context.move_to (x + legend_line_length - s.title.get_x_bearing(context), y);
					set_source_rgba (s.title.color);
					show_text(s.title);

					// series line style
					context.move_to (x, y - s.title.get_height(context) / 2);
					set_line_style(s.line_style);
					context.rel_line_to (legend_line_length, 0);
					context.stroke();
					draw_marker_at_pos (s.marker_type, x + legend_line_length / 2, y - s.title.get_height(context) / 2);
					break;
				}

				switch (legend.position) {
				case Legend.Position.TOP:
				case Legend.Position.BOTTOM:
					var ser_title_width = s.title.get_width(context) + legend_line_length;
					leg_width_sum += (leg_width_sum == 0 ? 0 : legend_text_hspace) + ser_title_width;
					max_font_h = double.max (max_font_h, s.title.get_height(context)) + (leg_height_sum != 0 ? legend_text_vspace : 0);
				break;

				case Legend.Position.LEFT:
				case Legend.Position.RIGHT:
					switch (process_type) {
					case LegendProcessType.CALC:
						max_font_heights += s.title.get_height(context) + (leg_height_sum != 0 ? legend_text_vspace : 0);
						legend_width = double.max (legend_width, s.title.get_width(context) + legend_line_length);
						break;
					case LegendProcessType.DRAW:
						heights_idx++;
						break;
					}
					leg_height_sum += s.title.get_height(context) + (leg_height_sum != 0 ? legend_text_vspace : 0);
				break;
				}
			}

			// TOP, BOTTOM
			switch (legend.position) {
			case Legend.Position.TOP:
			case Legend.Position.BOTTOM:
				if (leg_width_sum != 0) {
					leg_height_sum += max_font_h;
					switch (process_type) {
						case LegendProcessType.CALC:
							max_font_heights += max_font_h;
							legend_width = double.max(legend_width, leg_width_sum);
							break;
					}
				}
				break;
			}

			switch (process_type) {
			case LegendProcessType.CALC:
				legend_height = leg_height_sum;
				switch (legend.position) {
					case Legend.Position.TOP:
						cur_y_min += legend_height;
						break;
					case Legend.Position.BOTTOM:
						cur_y_max -= legend_height;
						break;
					case Legend.Position.LEFT:
						cur_x_min += legend_width;
						break;
					case Legend.Position.RIGHT:
						cur_x_max -= legend_width;
						break;
				}
				break;
			}
		}

		protected virtual void draw_legend () {
			process_legend (LegendProcessType.CALC);
			process_legend (LegendProcessType.DRAW);
		}

		protected int axis_rec_npoints = 128;

		protected virtual void calc_axis_rec_sizes (Axis axis, out double max_rec_width, out double max_rec_height, bool is_horizontal = true) {
			max_rec_width = max_rec_height = 0;
			for (var i = 0; i < axis_rec_npoints; ++i) {
				Float128 x = (int64)(axis.zoom_min + (axis.zoom_max - axis.zoom_min) / axis_rec_npoints * i) + 1.0/3.0;
				switch (axis.type) {
				case Axis.Type.NUMBERS:
					var text = new Text (axis.format.printf((LongDouble)x) + (is_horizontal ? "_" : ""));
					text.style = axis.font_style;
					max_rec_width = double.max (max_rec_width, text.get_width(context));
					max_rec_height = double.max (max_rec_height, text.get_height(context));
					break;
				case Axis.Type.DATE_TIME:
					string date, time;
					format_date_time(axis, x, out date, out time);

					var text = new Text("");
					var h = 0.0;
					if (axis.date_format != "") {
						text = new Text (date + (is_horizontal ? "_" : ""));
						text.style = axis.font_style;
						max_rec_width = double.max (max_rec_width, text.get_width(context));
						h = text.get_height(context);
					}
					if (axis.time_format != "") {
						text = new Text (time + (is_horizontal ? "_" : ""));
						text.style = axis.font_style;
						max_rec_width = double.max (max_rec_width, text.get_width(context));
						h += text.get_height(context);
					}
					max_rec_height = double.max (max_rec_height, h);
					break;
				}
			}
		}

		protected virtual Float128 calc_round_step (Float128 aver_step, bool date_time = false) {
			Float128 step = 1.0;

			if (aver_step > 1.0) {
				if (date_time) while (step < aver_step) step *= 60;
				if (date_time) while (step < aver_step) step *= 60;
				if (date_time) while (step < aver_step) step *= 24;
				while (step < aver_step) step *= 10;
				if (step / 5 > aver_step) step /= 5;
				while (step / 2 > aver_step) step /= 2;
			} else if (aver_step > 0) {
				while (step / 10 > aver_step) step /= 10;
				if (step / 5 > aver_step) step /= 5;
				while (step / 2 > aver_step) step /= 2;
			}

			return step;
		}

		public double plot_area_x_min = 0;
		public double plot_area_x_max = 0;
		public double plot_area_y_min = 0;
		public double plot_area_y_max = 0;

		bool common_x_axes = false;
		bool common_y_axes = false;

		bool are_intersect (double a_min, double a_max, double b_min, double b_max) {
			if (   a_min < a_max <= b_min < b_max
			    || b_min < b_max <= a_min < a_max)
				return false;
			return true;
		}

		protected virtual void set_vertical_axes_titles () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				s.axis_y.title.style.orientation = FontOrient.VERTICAL;
			}
		}

		protected virtual void calc_plot_area () {
			plot_area_x_min = cur_x_min + legend.indent;
			plot_area_x_max = cur_x_max - legend.indent;
			plot_area_y_min = cur_y_min + legend.indent;
			plot_area_y_max = cur_y_max - legend.indent;

			// Check for common axes
			common_x_axes = common_y_axes = true;
			int nzoom_series_show = 0;
			for (var si = series.length - 1; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				++nzoom_series_show;
				if (   s.axis_x.position != series[0].axis_x.position
				    || s.axis_x.zoom_min != series[0].axis_x.zoom_min
				    || s.axis_x.zoom_max != series[0].axis_x.zoom_max
				    || s.place.zoom_x_low != series[0].place.zoom_x_low
				    || s.place.zoom_x_high != series[0].place.zoom_x_high
				    || s.axis_x.type != series[0].axis_x.type)
					common_x_axes = false;
				if (   s.axis_y.position != series[0].axis_y.position
				    || s.axis_y.zoom_min != series[0].axis_y.zoom_min
				    || s.axis_y.zoom_max != series[0].axis_y.zoom_max
				    || s.place.zoom_y_low != series[0].place.zoom_y_low
				    || s.place.zoom_y_high != series[0].place.zoom_y_high)
					common_y_axes = false;
			}
			if (nzoom_series_show == 1) common_x_axes = common_y_axes = false;

			// Join and calc X-axes
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (nskip != 0) {--nskip; continue;}
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_x, out max_rec_width, out max_rec_height, true);
				var max_font_indent = s.axis_x.font_indent;
				var max_axis_font_height = s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					if (!s2.zoom_show) continue;
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (!s3.zoom_show) continue;
						if (are_intersect(s2.place.zoom_x_low, s2.place.zoom_x_high, s3.place.zoom_x_low, s3.place.zoom_x_high)
						    || s2.axis_x.position != s3.axis_x.position
						    || s2.axis_x.type != s3.axis_x.type) {
							has_intersection = true;
							break;
						}
					}
					if (!has_intersection) {
						double tmp_max_rec_width = 0; double tmp_max_rec_height = 0;
						calc_axis_rec_sizes (s2.axis_x, out tmp_max_rec_width, out tmp_max_rec_height, true);
						max_rec_width = double.max (max_rec_width, tmp_max_rec_width);
						max_rec_height = double.max (max_rec_height, tmp_max_rec_height);
						max_font_indent = double.max (max_font_indent, s2.axis_x.font_indent);
						max_axis_font_height = double.max (max_axis_font_height, s2.axis_x.title.text == "" ? 0 :
						                                   s2.axis_x.title.get_height(context) + s.axis_x.font_indent);
						++nskip;
					} else {
						break;
					}
				}

				// for 4.2. Cursor values for common X axis
				if (common_x_axes && si == zoom_first_show && cursors_orientation == CursorOrientation.VERTICAL && cursors_crossings.length != 0) {
					switch (s.axis_x.position) {
					case Axis.Position.LOW: plot_area_y_max -= max_rec_height + s.axis_x.font_indent; break;
					case Axis.Position.HIGH: plot_area_y_min += max_rec_height + s.axis_x.font_indent; break;
					}
				}

				if (!common_x_axes || si == zoom_first_show)
					switch (s.axis_x.position) {
					case Axis.Position.LOW: plot_area_y_max -= max_rec_height + max_font_indent + max_axis_font_height; break;
					case Axis.Position.HIGH: plot_area_y_min += max_rec_height + max_font_indent + max_axis_font_height; break;
					}
			}

			// Join and calc Y-axes
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (nskip != 0) {--nskip; continue;}
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_y, out max_rec_width, out max_rec_height, false);
				var max_font_indent = s.axis_y.font_indent;
				var max_axis_font_width = s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					if (!s2.zoom_show) continue;
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (!s3.zoom_show) continue;
						if (are_intersect(s2.place.zoom_y_low, s2.place.zoom_y_high, s3.place.zoom_y_low, s3.place.zoom_y_high)
						    || s2.axis_y.position != s3.axis_y.position
						    || s2.axis_x.type != s3.axis_x.type) {
							has_intersection = true;
							break;
						}
					}
					if (!has_intersection) {
						double tmp_max_rec_width = 0; double tmp_max_rec_height = 0;
						calc_axis_rec_sizes (s2.axis_y, out tmp_max_rec_width, out tmp_max_rec_height, false);
						max_rec_width = double.max (max_rec_width, tmp_max_rec_width);
						max_rec_height = double.max (max_rec_height, tmp_max_rec_height);
						max_font_indent = double.max (max_font_indent, s2.axis_y.font_indent);
						max_axis_font_width = double.max (max_axis_font_width, s2.axis_y.title.text == "" ? 0
						                                   : s2.axis_y.title.get_width(context) + s.axis_y.font_indent);
						++nskip;
					} else {
						break;
					}
				}

				// for 4.2. Cursor values for common Y axis
				if (common_y_axes && si == zoom_first_show && cursors_orientation == CursorOrientation.HORIZONTAL && cursors_crossings.length != 0) {
					switch (s.axis_y.position) {
					case Axis.Position.LOW: plot_area_x_min += max_rec_width + s.axis_y.font_indent; break;
					case Axis.Position.HIGH: plot_area_x_max -= max_rec_width + s.axis_y.font_indent; break;
					}
				}

				if (!common_y_axes || si == zoom_first_show)
					switch (s.axis_y.position) {
					case Axis.Position.LOW: plot_area_x_min += max_rec_width + max_font_indent + max_axis_font_width; break;
					case Axis.Position.HIGH: plot_area_x_max -= max_rec_width + max_font_indent + max_axis_font_width; break;
					}
			}
		}

		bool point_belong (Float128 p, Float128 a, Float128 b) {
			if (a > b) { Float128 tmp = a; a = b; b = tmp; }
			if (a <= p <= b) return true;
			return false;
		}

		protected virtual double compact_rec_x_pos (Series s, Float128 x, Text text) {
			return get_scr_x(s, x) - text.get_width(context) / 2.0 - text.get_x_bearing(context)
			       - text.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
		}

		protected virtual double compact_rec_y_pos (Series s, Float128 y, Text text) {
			return get_scr_y(s, y) + text.get_height(context) / 2.0
			       + text.get_height(context) * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min);
		}

		protected virtual void format_date_time (Axis axis, Float128 x, out string date, out string time) {
			date = time = "";
			var dt = new DateTime.from_unix_utc((int64)x);
			date = dt.format(axis.date_format);
			var dsec_str =
				("%."+(axis.dsec_signs.to_string())+"Lf").printf((LongDouble)(x - (int64)x)).offset(1);
			time = dt.format(axis.time_format) + dsec_str;
		}

		protected virtual void draw_horizontal_axis () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (common_x_axes && si != zoom_first_show) continue;

				// 1. Detect max record width/height by axis_rec_npoints equally selected points using format.
				double max_rec_width, max_rec_height;
				calc_axis_rec_sizes (s.axis_x, out max_rec_width, out max_rec_height, true);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_area_x_max - plot_area_x_min) * (s.place.zoom_x_high - s.place.zoom_x_low) / max_rec_width);

				// 3. Calculate grid step.
				Float128 step = calc_round_step ((s.axis_x.zoom_max - s.axis_x.zoom_min) / max_nrecs, s.axis_x.type == Axis.Type.DATE_TIME);
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

				// 4.2. Cursor values for common X axis
				if (common_x_axes && cursors_orientation == CursorOrientation.VERTICAL && cursors_crossings.length != 0) {
					switch (s.axis_x.position) {
					case Axis.Position.LOW: cur_y_max -= max_rec_height + s.axis_x.font_indent; break;
					case Axis.Position.HIGH: cur_y_min += max_rec_height + s.axis_x.font_indent; break;
					}
				}

				// 4.5. Draw Axis title
				if (s.axis_x.title.text != "") {
					var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.zoom_x_low + s.place.zoom_x_high) / 2.0;
					double scr_y = 0.0;
					switch (s.axis_x.position) {
					case Axis.Position.LOW: scr_y = cur_y_max - s.axis_x.font_indent; break;
					case Axis.Position.HIGH: scr_y = cur_y_min + s.axis_x.font_indent + s.axis_x.title.get_height(context); break;
					}
					context.move_to(scr_x - s.axis_x.title.get_width(context) / 2.0, scr_y);
					set_source_rgba(s.axis_x.color);
					if (common_x_axes) set_source_rgba(Color(0,0,0,1));
					show_text(s.axis_x.title);
				}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 x = x_min, x_max = s.axis_x.zoom_max; point_belong (x, x_min, x_max); x += step) {
					if (common_x_axes) set_source_rgba(Color(0,0,0,1));
					else set_source_rgba(s.axis_x.color);
					string text = "", time_text = "";
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS:
						text = s.axis_x.format.printf((LongDouble)x);
						break;
					case Axis.Type.DATE_TIME:
						format_date_time(s.axis_x, x, out text, out time_text);
						break;
					}
					var scr_x = get_scr_x (s, x);
					var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
					switch (s.axis_x.position) {
					case Axis.Position.LOW:
						var print_y = cur_y_max - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						var print_x = compact_rec_x_pos (s, x, text_t);
						context.move_to (print_x, print_y);
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							show_text(text_t);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						}
						// 6. Draw grid lines to the s.place.zoom_y_low.
						var line_style = s.grid.line_style;
						if (common_x_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double y = cur_y_max - max_rec_height - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (common_x_axes)
							context.line_to (scr_x, plot_area_y_min);
						else
							context.line_to (scr_x, double.min (y, plot_area_y_max - (plot_area_y_max - plot_area_y_min) * s.place.zoom_y_high));
						break;
					case Axis.Position.HIGH:
						var print_y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						var print_x = compact_rec_x_pos (s, x, text_t);
						context.move_to (print_x, print_y);

						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							show_text(text_t);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						}
						// 6. Draw grid lines to the s.place.zoom_y_high.
						var line_style = s.grid.line_style;
						if (common_x_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (common_x_axes)
							context.line_to (scr_x, plot_area_y_max);
						else
							context.line_to (scr_x, double.max (y, plot_area_y_max - (plot_area_y_max - plot_area_y_min) * s.place.zoom_y_low));
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					if (!s2.zoom_show) continue;
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (!s3.zoom_show) continue;
						if (are_intersect(s2.place.zoom_x_low, s2.place.zoom_x_high, s3.place.zoom_x_low, s3.place.zoom_x_high)
						    || s2.axis_x.position != s3.axis_x.position
						    || s2.axis_x.type != s3.axis_x.type) {
							has_intersection = true;
							break;
						}
					}
					if (!has_intersection) {
						++nskip;
					} else {
						break;
					}
				}

				if (nskip != 0) {--nskip; continue;}

				switch (s.axis_x.position) {
				case Axis.Position.LOW:
					cur_y_max -= max_rec_height + s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
					break;
				case Axis.Position.HIGH:
					cur_y_min += max_rec_height +  s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
					break;
				}
			}
		}

		protected virtual void draw_vertical_axis () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (common_y_axes && si != zoom_first_show) continue;
				// 1. Detect max record width/height by axis_rec_npoints equally selected points using format.
				double max_rec_width, max_rec_height;
				calc_axis_rec_sizes (s.axis_y, out max_rec_width, out max_rec_height, false);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_area_y_max - plot_area_y_min) * (s.place.zoom_y_high - s.place.zoom_y_low) / max_rec_height);

				// 3. Calculate grid step.
				Float128 step = calc_round_step ((s.axis_y.zoom_max - s.axis_y.zoom_min) / max_nrecs);
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

				// 4.2. Cursor values for common Y axis
				if (common_y_axes && cursors_orientation == CursorOrientation.HORIZONTAL && cursors_crossings.length != 0) {
					switch (s.axis_y.position) {
					case Axis.Position.LOW: cur_x_min += max_rec_width + s.axis_y.font_indent; break;
					case Axis.Position.HIGH: cur_x_max -= max_rec_width + s.axis_y.font_indent; break;
					}
				}

				// 4.5. Draw Axis title
				if (s.axis_y.title.text != "") {
					var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.zoom_y_low + s.place.zoom_y_high) / 2.0;
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						var scr_x = cur_x_min + s.axis_y.font_indent + s.axis_y.title.get_width(context);
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						break;
					case Axis.Position.HIGH:
						var scr_x = cur_x_max - s.axis_y.font_indent;
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						break;
					}
					set_source_rgba(s.axis_y.color);
					if (common_y_axes) set_source_rgba(Color(0,0,0,1));
					show_text(s.axis_y.title);
				}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 y = y_min, y_max = s.axis_y.zoom_max; point_belong (y, y_min, y_max); y += step) {
					if (common_y_axes) set_source_rgba(Color(0,0,0,1));
					else set_source_rgba(s.axis_y.color);
					var text = s.axis_y.format.printf((LongDouble)y);
					var scr_y = get_scr_y (s, y);
					var text_t = new Text(text, s.axis_y.font_style, s.axis_y.color);
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						context.move_to (cur_x_min + max_rec_width - (new Text(text)).get_width(context) + s.axis_y.font_indent - text_t.get_x_bearing(context)
						                 + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent),
						                 compact_rec_y_pos (s, y, new Text(text)));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.zoom_x_low.
						var line_style = s.grid.line_style;
						if (common_y_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double x = cur_x_min + max_rec_width + s.axis_y.font_indent + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (common_y_axes)
							context.line_to (plot_area_x_max, scr_y);
						else
							context.line_to (double.max (x, plot_area_x_min + (plot_area_x_max - plot_area_x_min) * s.place.zoom_x_high), scr_y);
						break;
					case Axis.Position.HIGH:
						context.move_to (cur_x_max - (new Text(text)).get_width(context) - s.axis_y.font_indent - text_t.get_x_bearing(context)
						                 - (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent),
						                 compact_rec_y_pos (s, y, new Text(text)));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.zoom_x_high.
						var line_style = s.grid.line_style;
						if (common_y_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double x = cur_x_max - max_rec_width - s.axis_y.font_indent - (s.axis_y.title.text == "" ? 0 :s.axis_y.title.get_width(context) + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (common_y_axes)
							context.line_to (plot_area_x_min, scr_y);
						else
							context.line_to (double.min (x, plot_area_x_min + (plot_area_x_max - plot_area_x_min) * s.place.zoom_x_low), scr_y);
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					if (!s2.zoom_show) continue;
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (!s3.zoom_show) continue;
						if (are_intersect(s2.place.zoom_y_low, s2.place.zoom_y_high, s3.place.zoom_y_low, s3.place.zoom_y_high)
						    || s2.axis_y.position != s3.axis_y.position) {
							has_intersection = true;
							break;
						}
					}
					if (!has_intersection) {
						++nskip;
					} else {
						break;
					}
				}

				if (nskip != 0) {--nskip; continue;}

				switch (s.axis_y.position) {
				case Axis.Position.LOW:
					cur_x_min += max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent); break;
				case Axis.Position.HIGH:
					cur_x_max -= max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent); break;
				}
			}
		}

		protected virtual void draw_plot_area_border () {
			set_source_rgba (border_color);
			context.set_dash(null, 0);
			context.move_to (plot_area_x_min, plot_area_y_min);
			context.line_to (plot_area_x_min, plot_area_y_max);
			context.line_to (plot_area_x_max, plot_area_y_max);
			context.line_to (plot_area_x_max, plot_area_y_min);
			context.line_to (plot_area_x_min, plot_area_y_min);
			context.stroke ();
		}

		protected virtual double get_scr_x (Series s, Float128 x) {
			return plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.zoom_x_low + (x - s.axis_x.zoom_min)
			                         / (s.axis_x.zoom_max - s.axis_x.zoom_min) * (s.place.zoom_x_high - s.place.zoom_x_low));
		}

		protected virtual double get_scr_y (Series s, Float128 y) {
			return plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.zoom_y_low + (y - s.axis_y.zoom_min)
			                         / (s.axis_y.zoom_max - s.axis_y.zoom_min) * (s.place.zoom_y_high - s.place.zoom_y_low));
		}
		protected virtual Point get_scr_point (Series s, Point p) {
			return Point (get_scr_x(s, p.x), get_scr_y(s, p.y));
		}

		protected virtual Float128 get_real_x (Series s, double scr_x) {
			return s.axis_x.zoom_min + ((scr_x - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) - s.place.zoom_x_low)
			       * (s.axis_x.zoom_max - s.axis_x.zoom_min) / (s.place.zoom_x_high - s.place.zoom_x_low);
		}
		protected virtual Float128 get_real_y (Series s, double scr_y) {
			return s.axis_y.zoom_min + ((plot_area_y_max - scr_y) / (plot_area_y_max - plot_area_y_min) - s.place.zoom_y_low)
			       * (s.axis_y.zoom_max - s.axis_y.zoom_min) / (s.place.zoom_y_high - s.place.zoom_y_low);
		}
		protected virtual Point get_real_point (Series s, Point p) {
			return Point (get_real_x(s, p.x), get_real_y(s, p.y));
		}

		protected virtual bool x_in_range (double x, double x0, double x1) {
			if (x0 <= x <= x1 || x1 <= x <= x0)
				return true;
			return false;
		}

		protected virtual bool y_in_range (double y, double y0, double y1) {
			if (y0 <= y <= y1 || y1 <= y <= y0)
				return true;
			return false;
		}

		protected virtual bool x_in_plot_area (double x) {
			if (x_in_range(x, plot_area_x_min, plot_area_x_max))
				return true;
			return false;
		}

		protected virtual bool y_in_plot_area (double y) {
			if (y_in_range(y, plot_area_y_min, plot_area_y_max))
				return true;
			return false;
		}

		protected virtual bool point_in_rect (Point p, double x0, double x1, double y0, double y1) {
			if (x_in_range(p.x, x0, x1) && y_in_range(p.y, y0, y1))
				return true;
			return false;
		}

		protected virtual bool point_in_plot_area (Point p) {
			if (point_in_rect (p, plot_area_x_min, plot_area_x_max, plot_area_y_min, plot_area_y_max))
				return true;
			return false;
		}

		protected virtual bool hcross (Point a1, Point a2, Float128 h_x1, Float128 h_x2, Float128 h_y, out Float128 x) {
			x = 0;
			if (a1.y == a2.y) return false;
			if (a1.y >= h_y && a2.y >= h_y || a1.y <= h_y && a2.y <= h_y) return false;
			x = a1.x + (a2.x - a1.x) * (h_y - a1.y) / (a2.y - a1.y);
			if (h_x1 <= x <= h_x2 || h_x2 <= x <= h_x1)
				return true;
			return false;
		}

		protected virtual bool vcross (Point a1, Point a2, Float128 v_x, Float128 v_y1, Float128 v_y2, out Float128 y) {
			y = 0;
			if (a1.x == a2.x) return false;
			if (a1.x >= v_x && a2.x >= v_x || a1.x <= v_x && a2.x <= v_x) return false;
			y = a1.y + (a2.y - a1.y) * (v_x - a1.x) / (a2.x - a1.x);
			if (v_y1 <= y <= v_y2 || v_y2 <= y <= v_y1)
				return true;
			return false;
		}

		delegate int PointComparator(Point a, Point b);
		void sort_points_delegate(Point[] points, PointComparator compare) {
			for(var i = 0; i < points.length; ++i) {
				for(var j = i + 1; j < points.length; ++j) {
					if(compare(points[i], points[j]) > 0) {
						var tmp = points[i];
						points[i] = points[j];
						points[j] = tmp;
					}
				}
			}
		}

		protected virtual bool cut_line (Point a, Point b, out Point c, out Point d) {
			int ncross = 0;
			Float128 x = 0, y = 0;
			Point pc[4];
			if (hcross(a, b, plot_area_x_min, plot_area_x_max, plot_area_y_min, out x))
				pc[ncross++] = Point(x, plot_area_y_min);
			if (hcross(a, b, plot_area_x_min, plot_area_x_max, plot_area_y_max, out x))
				pc[ncross++] = Point(x, plot_area_y_max);
			if (vcross(a, b, plot_area_x_min, plot_area_y_min, plot_area_y_max, out y))
				pc[ncross++] = Point(plot_area_x_min, y);
			if (vcross(a, b, plot_area_x_max, plot_area_y_min, plot_area_y_max, out y))
				pc[ncross++] = Point(plot_area_x_max, y);
			c = a;
			d = b;
			if (ncross == 0) {
				if (point_in_plot_area (a) && point_in_plot_area (b))
					return true;
				return false;
			}
			if (ncross >= 2) {
				c = pc[0]; d = pc[1];
				return true;
			}
			if (ncross == 1) {
				if (point_in_plot_area (a)) {
					c = a;
					d = pc[0];
					return true;
				} else if (point_in_plot_area (b)) {
					c = b;
					d = pc[0];
					return true;
				}
			}
			return false;
		}

		protected virtual Point[] sort_points (Series s, Series.Sort sort) {
			var points = s.points.copy();
			switch(sort) {
			case Series.Sort.BY_X:
				sort_points_delegate(points, (a, b) => {
				    if (a.x < b.x) return -1;
				    if (a.x > b.x) return 1;
				    return 0;
				});
				break;
			case Series.Sort.BY_Y:
				sort_points_delegate(points, (a, b) => {
				    if (a.y < b.y) return -1;
				    if (a.y > b.y) return 1;
				    return 0;
				});
				break;
			}
			return points;
		}

		protected virtual void draw_series () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (s.points.length == 0) continue;
				var points = sort_points(s, s.sort);
				set_line_style(s.line_style);
				// draw series line
				for (int i = 1; i < points.length; ++i) {
					Point c, d;
					if (cut_line (Point(get_scr_x(s, points[i - 1].x), get_scr_y(s, points[i - 1].y)),
					              Point(get_scr_x(s, points[i].x), get_scr_y(s, points[i].y)),
					              out c, out d)) {
						context.move_to (c.x, c.y);
						context.line_to (d.x, d.y);
					}
				}
				context.stroke();
				for (int i = 0; i < points.length; ++i) {
					var x = get_scr_x(s, points[i].x);
					var y = get_scr_y(s, points[i].y);
					if (point_in_plot_area (Point (x, y)))
						draw_marker_at_pos(s.marker_type, x, y);
				}
			}
		}

		protected List<Point?> cursors = new List<Point?> ();
		protected Point active_cursor = Point ();
		protected bool is_cursor_active = false;

		public virtual void set_active_cursor (double x, double y, bool remove = false) {
			active_cursor = Point (scr2rel_x(x), scr2rel_y(y));
			is_cursor_active = ! remove;
		}

		public virtual void add_active_cursor () {
			cursors.append (active_cursor);
			is_cursor_active = false;
		}

		public enum CursorOrientation {
			VERTICAL = 0,  // default
			HORIZONTAL
		}

		public CursorOrientation cursors_orientation = CursorOrientation.VERTICAL;

		public double cursor_max_rm_distance = 32;

		public virtual void remove_active_cursor () {
			if (cursors.length() == 0) return;
			var distance = width * width;
			uint rm_indx = 0;
			uint i = 0;
			foreach (var c in cursors) {
				double d = distance;
				switch (cursors_orientation) {
				case CursorOrientation.VERTICAL:
					d = (rel2scr_x(c.x) - rel2scr_x(active_cursor.x)).abs();
					break;
				case CursorOrientation.HORIZONTAL:
					d = (rel2scr_y(c.y) - rel2scr_y(active_cursor.y)).abs();
					break;
				}
				if (d < distance) {
					distance = d;
					rm_indx = i;
				}
				++i;
			}
			if (distance < cursor_max_rm_distance)
				cursors.delete_link(cursors.nth(rm_indx));
			is_cursor_active = false;
		}

		protected virtual Float128 scr2rel_x (Float128 x) {
			return _rel_zoom_x_min + (x - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) * (_rel_zoom_x_max - _rel_zoom_x_min);
		}
		protected virtual Float128 scr2rel_y (Float128 y) {
			return _rel_zoom_y_max - (plot_area_y_max - y) / (plot_area_y_max - plot_area_y_min) * (_rel_zoom_y_max - _rel_zoom_y_min);
		}
		protected virtual Point scr2rel_point (Point p) {
			return Point (scr2rel_x(p.x), scr2rel_y(p.y));
		}

		protected virtual Float128 rel2scr_x(Float128 x) {
			return plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (x - _rel_zoom_x_min) / (_rel_zoom_x_max - _rel_zoom_x_min);
		}

		protected virtual Float128 rel2scr_y(Float128 y) {
			return plot_area_y_min + (plot_area_y_max - plot_area_y_min) * (y - _rel_zoom_y_min) / (_rel_zoom_y_max - _rel_zoom_y_min);
		}

		protected virtual Point rel2scr_point (Point p) {
			return Point (rel2scr_x(p.x), rel2scr_y(p.y));
		}

		public LineStyle cursor_line_style = LineStyle(Color(0.2, 0.2, 0.2, 0.8));

		protected struct CursorCross {
			uint series_index;
			Point point;
			Point size;
			bool show_x;
			bool show_date;
			bool show_time;
			bool show_y;
			Point scr_point;
			Point scr_value_point;
		}
		protected struct CursorCrossings {
			uint cursor_index;
			CursorCross[] crossings;
		}

		protected CursorCrossings[] cursors_crossings = {};

		protected List<Point?> get_all_cursors () {
			var all_cursors = cursors.copy_deep ((src) => { return src; });
			if (is_cursor_active)
				all_cursors.append(active_cursor);
			return all_cursors;
		}

		protected void get_cursors_crossings () {
			var all_cursors = get_all_cursors();

			CursorCrossings[] local_cursor_crossings = {};

			for (var ci = 0, max_ci = all_cursors.length(); ci < max_ci; ++ci) {
				var c = all_cursors.nth_data(ci);
				switch (cursors_orientation) {
				case CursorOrientation.VERTICAL:
					if (c.x <= _rel_zoom_x_min || c.x >= _rel_zoom_x_max) continue; break;
				case CursorOrientation.HORIZONTAL:
					if (c.y <= _rel_zoom_y_min || c.y >= _rel_zoom_y_max) continue; break;
				}

				CursorCross[] crossings = {};
				for (var si = 0, max_si = series.length; si < max_si; ++si) {
					var s = series[si];
					if (!s.zoom_show) continue;

					Point[] points = {};
					switch (cursors_orientation) {
					case CursorOrientation.VERTICAL:
						points = sort_points (s, s.sort);
						break;
					case CursorOrientation.HORIZONTAL:
						points = sort_points (s, s.sort);
						break;
					}

					for (var i = 0; i + 1 < points.length; ++i) {
						switch (cursors_orientation) {
						case CursorOrientation.VERTICAL:
							Float128 y = 0.0;
							if (vcross(get_scr_point(s, points[i]), get_scr_point(s, points[i+1]), rel2scr_x(c.x),
							           plot_area_y_min, plot_area_y_max, out y)) {
								var point = Point(get_real_x(s, rel2scr_x(c.x)), get_real_y(s, y));
								Point size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (s, point, out size, show_x, show_time, show_date, show_y);
								CursorCross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						case CursorOrientation.HORIZONTAL:
							Float128 x = 0.0;
							if (hcross(get_scr_point(s, points[i]), get_scr_point(s, points[i+1]),
							           plot_area_x_min, plot_area_x_max, rel2scr_y(c.y), out x)) {
								var point = Point(get_real_x(s, x), get_real_y(s, rel2scr_y(c.y)));
								Point size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (s, point, out size, show_x, show_time, show_date, show_y);
								CursorCross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						}
					}
				}
				if (crossings.length != 0) {
					CursorCrossings ccs = {ci, crossings};
					local_cursor_crossings += ccs;
				}
			}
			cursors_crossings = local_cursor_crossings;
		}

		protected virtual void calc_cursors_value_positions () {
			for (var ccsi = 0, max_ccsi = cursors_crossings.length; ccsi < max_ccsi; ++ccsi) {
				for (var cci = 0, max_cci = cursors_crossings[ccsi].crossings.length; cci < max_cci; ++cci) {
					// TODO: Ticket #142: find smart algorithm of cursors values placements
					unowned CursorCross[] cr = cursors_crossings[ccsi].crossings;
					cr[cci].scr_point = get_scr_point (series[cr[cci].series_index], cr[cci].point);
					var d_max = double.max (cr[cci].size.x / 1.5, cr[cci].size.y / 1.5);
					cr[cci].scr_value_point = Point (cr[cci].scr_point.x + d_max, cr[cci].scr_point.y - d_max);
				}
			}
		}

		protected virtual void cross_what_to_show (Series s, out bool show_x, out bool show_time,
		                                                     out bool show_date, out bool show_y) {
			show_x = show_time = show_date = show_y = false;
			switch (cursors_orientation) {
			case CursorOrientation.VERTICAL:
				show_y = true;
				if (!common_x_axes)
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS: show_x = true; break;
					case Axis.Type.DATE_TIME:
						if (s.axis_x.date_format != "") show_date = true;
						if (s.axis_x.time_format != "") show_time = true;
						break;
					}
				break;
			case CursorOrientation.HORIZONTAL:
				if (!common_y_axes) show_y = true;
				switch (s.axis_x.type) {
				case Axis.Type.NUMBERS: show_x = true; break;
				case Axis.Type.DATE_TIME:
					if (s.axis_x.date_format != "") show_date = true;
					if (s.axis_x.time_format != "") show_time = true;
					break;
				}
				break;
			}
		}

		protected virtual void calc_cross_sizes (Series s, Point p, out Point size,
		                                         bool show_x = false, bool show_time = false,
		                                         bool show_date = false, bool show_y = false) {
			if (show_x == show_time == show_date == show_y == false)
				cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
			size = Point ();
			double x_w = 0.0, x_h = 0.0, y_w = 0.0, y_h = 0.0;
			string date, time;
			format_date_time(s.axis_x, p.x, out date, out time);
			var date_t = new Text (date, s.axis_x.font_style, s.axis_x.color);
			var time_t = new Text (time, s.axis_x.font_style, s.axis_x.color);
			var x_t = new Text (s.axis_x.format.printf((LongDouble)p.x), s.axis_x.font_style, s.axis_x.color);
			var y_t = new Text (s.axis_y.format.printf((LongDouble)p.y), s.axis_y.font_style, s.axis_y.color);
			double h_x = 0.0, h_y = 0.0;
			if (show_x) { size.x = x_t.get_width(context); h_x = x_t.get_height(context); }
			if (show_date) { size.x = date_t.get_width(context); h_x = date_t.get_height(context); }
			if (show_time) { size.x = double.max(size.x, time_t.get_width(context)); h_x += time_t.get_height(context); }
			if (show_y) { size.x += y_t.get_width(context); h_y = y_t.get_height(context); }
			if ((show_x || show_date || show_time) && show_y) size.x += double.max(s.axis_x.font_indent, s.axis_y.font_indent);
			if (show_date && show_time) h_x += s.axis_x.font_indent;
			size.y = double.max (h_x, h_y);
		}

		protected virtual void draw_cursors () {
			if (series.length == 0) return;

			var all_cursors = get_all_cursors();
			calc_cursors_value_positions();

			for (var cci = 0, max_cci = cursors_crossings.length; cci < max_cci; ++cci) {
				var low = Point(plot_area_x_max, plot_area_y_max);  // low and high
				var high = Point(plot_area_x_min, plot_area_y_min); //              points of the cursor
				unowned CursorCross[] ccs = cursors_crossings[cci].crossings;
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = series[si];
					var p = ccs[ci].point;
					var scrx = get_scr_x(s, p.x);
					var scry = get_scr_y(s, p.y);
					if (scrx < low.x) low.x = scrx;
					if (scry < low.y) low.y = scry;
					if (scrx > high.x) high.x = scrx;
					if (scry > high.y) high.y = scry;

					if (common_x_axes) {
						switch (s.axis_x.position) {
						case Axis.Position.LOW: high.y = plot_area_y_max + s.axis_x.font_indent; break;
						case Axis.Position.HIGH: low.y = plot_area_y_min - s.axis_x.font_indent; break;
						case Axis.Position.BOTH:
							high.y = plot_area_y_max + s.axis_x.font_indent;
							low.y = plot_area_y_min - s.axis_x.font_indent;
							break;
						}
					}
					if (common_y_axes) {
						switch (s.axis_y.position) {
						case Axis.Position.LOW: low.x = plot_area_x_min - s.axis_y.font_indent; break;
						case Axis.Position.HIGH: high.x = plot_area_x_max + s.axis_y.font_indent; break;
						case Axis.Position.BOTH:
							low.x = plot_area_x_min - s.axis_y.font_indent;
							high.x = plot_area_x_max + s.axis_y.font_indent;
							break;
						}
					}

					set_line_style(cursor_line_style);
					context.move_to (ccs[ci].scr_point.x, ccs[ci].scr_point.y);
					context.line_to (ccs[ci].scr_value_point.x, ccs[ci].scr_value_point.y);
					context.stroke ();
				}

				var c = all_cursors.nth_data(cursors_crossings[cci].cursor_index);

				switch (cursors_orientation) {
				case CursorOrientation.VERTICAL:
					if (low.y > high.y) continue;
					set_line_style(cursor_line_style);
					context.move_to (rel2scr_x(c.x), low.y);
					context.line_to (rel2scr_x(c.x), high.y);
					context.stroke();

					// show common X value
					if (common_x_axes) {
						var s = series[zoom_first_show];
						var x = get_real_x(s, rel2scr_x(c.x));
						string text = "", time_text = "";
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							text = s.axis_x.format.printf((LongDouble)x);
							break;
						case Axis.Type.DATE_TIME:
							format_date_time(s.axis_x, x, out text, out time_text);
							break;
						default:
							break;
						}
						var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
						var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
						var print_y = 0.0;
						switch (s.axis_x.position) {
							case Axis.Position.LOW: print_y = y_min + height - s.axis_x.font_indent
								                    - (legend.position == Legend.Position.BOTTOM ? legend_height : 0);
								break;
							case Axis.Position.HIGH: print_y = y_min + title_height + s.axis_x.font_indent
								                     + (legend.position == Legend.Position.TOP ? legend_height : 0);
								switch (s.axis_x.type) {
								case Axis.Type.NUMBERS:
									print_y += text_t.get_height(context);
									break;
								case Axis.Type.DATE_TIME:
									print_y += (s.axis_x.date_format == "" ? 0 : text_t.get_height(context))
									           + (s.axis_x.time_format == "" ? 0 : time_text_t.get_height(context))
									           + (s.axis_x.date_format == "" || s.axis_x.time_format == "" ? 0 : s.axis_x.font_indent);
									break;
								}
								break;
						}
						var print_x = compact_rec_x_pos (s, x, text_t);
						context.move_to (print_x, print_y);

						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							show_text(text_t);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") show_text(text_t);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						}

						context.stroke ();
					}
					break;
				case CursorOrientation.HORIZONTAL:
					if (low.x > high.x) continue;
					set_line_style(cursor_line_style);
					context.move_to (low.x, rel2scr_y(c.y));
					context.line_to (high.x, rel2scr_y(c.y));
					context.stroke();

					// show common Y value
					if (common_y_axes) {
						var s = series[zoom_first_show];
						var y = get_real_y(s, rel2scr_y(c.y));
						var text_t = new Text(s.axis_y.format.printf((LongDouble)y));
						var print_y = compact_rec_y_pos (s, y, text_t);
						var print_x = 0.0;
						switch (s.axis_y.position) {
						case Axis.Position.LOW:
							print_x = x_min + s.axis_y.font_indent
							          + (legend.position == Legend.Position.LEFT ? legend_width : 0);
							break;
						case Axis.Position.HIGH:
							print_x = x_min + width - text_t.get_width(context) - s.axis_y.font_indent
							          - (legend.position == Legend.Position.RIGHT ? legend_width : 0);
							break;
						}
						context.move_to (print_x, print_y);
						show_text(text_t);

						context.stroke ();
					}
					break;
				}

				// show value (X, Y or [X;Y])
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = series[si];
					var point = ccs[ci].point;
					var size = ccs[ci].size;
					var svp = ccs[ci].scr_value_point;
					var rp = get_real_point(s, rel2scr_point(point));
					var show_x = ccs[ci].show_x;
					var show_date = ccs[ci].show_date;
					var show_time = ccs[ci].show_time;
					var show_y = ccs[ci].show_y;

					set_source_rgba(bg_color);
					context.rectangle (svp.x - size.x / 2, svp.y - size.y / 2, size.x, size.y);
					context.fill();

					if (show_x) {
						set_source_rgba(s.axis_x.color);
						var text_t = new Text(s.axis_x.format.printf((LongDouble)point.x));
						context.move_to (svp.x - size.x / 2, svp.y + text_t.get_height(context) / 2);
						show_text(text_t);
						context.stroke();
					}

					if (show_time) {
						set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						format_date_time(s.axis_x, point.x, out date, out time);
						var text_t = new Text(time);
						var y = svp.y + text_t.get_height(context) / 2;
						if (show_date) y -= text_t.get_height(context) / 2 + s.axis_x.font_indent / 2;
						context.move_to (svp.x - size.x / 2, y);
						show_text(text_t);
						context.stroke();
					}

					if (show_date) {
						set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						format_date_time(s.axis_x, point.x, out date, out time);
						var text_t = new Text(date);
						var y = svp.y + text_t.get_height(context) / 2;
						if (show_time) y += text_t.get_height(context) / 2 + s.axis_x.font_indent / 2;
						context.move_to (svp.x - size.x / 2, y);
						show_text(text_t);
						context.stroke();
					}

					if (show_y) {
						set_source_rgba(s.axis_y.color);
						var text_t = new Text(s.axis_y.format.printf((LongDouble)point.y));
						context.move_to (svp.x + size.x / 2 - text_t.get_width(context), svp.y + text_t.get_height(context) / 2);
						show_text(text_t);
						context.stroke();
					}
				}
			}
		}

		public Chart copy () {
			var chart = new Chart ();
			chart.active_cursor = this.active_cursor;
			chart.axis_rec_npoints = this.axis_rec_npoints;
			chart.bg_color = this.bg_color;
			chart.border_color = this.border_color;
			chart.common_x_axes = this.common_x_axes;
			chart.common_y_axes = this.common_y_axes;
			chart.context = this.context;
			chart.cur_x_max = this.cur_x_max;
			chart.cur_x_min = this.cur_x_min;
			chart.cur_y_max = this.cur_y_max;
			chart.cur_y_min = this.cur_y_min;
			chart.cursor_line_style = this.cursor_line_style;
			chart.cursor_max_rm_distance = this.cursor_max_rm_distance;
			chart.cursors = this.cursors.copy();
			chart.cursors_crossings = this.cursors_crossings.copy(); // no deep copying for .crossings
			chart.cursors_orientation = this.cursors_orientation;
			chart.height = this.height;
			chart.is_cursor_active = this.is_cursor_active;
			chart.legend = this.legend.copy();
			chart.legend_height = this.legend_height;
			chart.legend_line_length = this.legend_line_length;
			chart.legend_text_hspace = this.legend_text_hspace;
			chart.legend_text_vspace = this.legend_text_vspace;
			chart.legend_width = this.legend_width;
			chart.marker_size = this.marker_size;
			chart.max_font_heights = this.max_font_heights.copy();
			chart.plot_area_x_max = this.plot_area_x_max;
			chart.plot_area_x_min = this.plot_area_x_min;
			chart.plot_area_y_max = this.plot_area_y_max;
			chart.plot_area_y_min = this.plot_area_y_min;
			chart._rel_zoom_x_min = this._rel_zoom_x_min;
			chart._rel_zoom_x_max = this._rel_zoom_x_max;
			chart._rel_zoom_y_min = this._rel_zoom_y_min;
			chart._rel_zoom_y_max = this._rel_zoom_y_max;
			chart.selection_style = this.selection_style;
			chart.series = this.series.copy();
			chart.show_legend = this.show_legend;
			chart.title = this.title.copy();
			chart.title_height = this.title_height;
			chart.title_vindent = this.title_vindent;
			chart.title_width = this.title_width;
			chart.width = this.width;
			chart.x_min = this.x_min;
			chart.y_min = this.y_min;
			chart.zoom_first_show = this.zoom_first_show;
			return chart;
		}
	}
}
