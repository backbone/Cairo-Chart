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

		Series[] _series = {};
		public Series[] series {
			get { return _series; }
			set {
				_series = value.copy();
				zoom_series = value.copy();
				for (var i = 0; i < value.length; ++i) {
					_series[i] = value[i].copy();
					zoom_series[i] = value[i].copy();
				}
			}
		}
		public Series[] zoom_series = {};

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

		Series[] rm_series_by_idx (Series[] series, int idx) {
			Series[] new_series = series.copy();
			for (var i = idx + 1; i < series.length; ++i)
				new_series[i - 1] = series[i];
			new_series.length--;
			return new_series;
		}

		double rel_zoom_x_min = 0.0;
		double rel_zoom_x_max = 1.0;
		double rel_zoom_y_min = 0.0;
		double rel_zoom_y_max = 1.0;

		public virtual void zoom_in (double x0, double y0, double x1, double y1) {
			for (var i = 0, max_i = zoom_series.length; i < max_i; ++i) {
				var s = zoom_series[i];
				var real_x0 = get_real_x (s, x0);
				var real_x1 = get_real_x (s, x1);
				var real_y0 = get_real_y (s, y0);
				var real_y1 = get_real_y (s, y1);
				// if selected square does not intersect with the zoom_series's square
				if (   real_x1 <= s.axis_x.zoom_min || real_x0 >= s.axis_x.zoom_max
					|| real_y0 <= s.axis_y.zoom_min || real_y1 >= s.axis_y.zoom_max) {
					zoom_series = rm_series_by_idx (zoom_series, i);
					--i;
					--max_i;
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

			var new_rel_zoom_x_min = rel_zoom_x_min + (x0 - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) * (rel_zoom_x_max - rel_zoom_x_min);
			var new_rel_zoom_x_max = rel_zoom_x_min + (x1 - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) * (rel_zoom_x_max - rel_zoom_x_min);
			var new_rel_zoom_y_min = rel_zoom_y_min + (y0 - plot_area_y_min) / (plot_area_y_max - plot_area_y_min) * (rel_zoom_y_max - rel_zoom_y_min);
			var new_rel_zoom_y_max = rel_zoom_y_min + (y1 - plot_area_y_min) / (plot_area_y_max - plot_area_y_min) * (rel_zoom_y_max - rel_zoom_y_min);
			rel_zoom_x_min = new_rel_zoom_x_min;
			rel_zoom_x_max = new_rel_zoom_x_max;
			rel_zoom_y_min = new_rel_zoom_y_min;
			rel_zoom_y_max = new_rel_zoom_y_max;
		}

		public virtual void zoom_out () {
			zoom_series = _series.copy();
			for (var i = 0; i < _series.length; ++i) {
				_series[i] = _series[i].copy();
				zoom_series[i] = _series[i].copy();
			}
			foreach (var s in zoom_series) {
				s.axis_x.zoom_min = s.axis_x.min;
				s.axis_x.zoom_max = s.axis_x.max;
				s.axis_y.zoom_min = s.axis_y.min;
				s.axis_y.zoom_max = s.axis_y.max;
				s.place.zoom_x_low = s.place.x_low;
				s.place.zoom_x_high = s.place.x_high;
				s.place.zoom_y_low = s.place.y_low;
				s.place.zoom_y_high = s.place.y_high;
			}
			rel_zoom_x_min = 0;
			rel_zoom_x_max = 1;
			rel_zoom_y_min = 0;
			rel_zoom_y_max = 1;
		}

		public virtual void move (double delta_x, double delta_y) {
			delta_x /= plot_area_x_max - plot_area_x_min; delta_x *= - 1.0;
			delta_y /= plot_area_y_max - plot_area_y_min; delta_y *= - 1.0;
			var rzxmin = rel_zoom_x_min, rzxmax = rel_zoom_x_max, rzymin = rel_zoom_y_min, rzymax = rel_zoom_y_max;
			zoom_out();
			draw(); // TODO: optimize here
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
			draw(); // TODO: optimize here
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

				default:
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

				case Series.MarkerType.NONE:
				default:
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

			foreach (var s in zoom_series) {

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

						// zoom_series title
						context.move_to (x + legend_line_length - s.title.get_x_bearing(context), y);
						set_source_rgba (s.title.color);
						show_text(s.title);

						// zoom_series line style
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

		int axis_rec_npoints = 128;

		protected virtual void calc_axis_rec_sizes (Axis axis, out double max_rec_width, out double max_rec_height, bool is_horizontal = true) {
			max_rec_width = max_rec_height = 0;
			for (var i = 0; i < axis_rec_npoints; ++i) {
				Float128 x = axis.zoom_min + (axis.zoom_max - axis.zoom_min) / axis_rec_npoints * i;
				switch (axis.type) {
				case Axis.Type.NUMBERS:
					var text = new Text (axis.format.printf((LongDouble)x) + (is_horizontal ? "_" : ""));
					text.style = axis.font_style;
					max_rec_width = double.max (max_rec_width, text.get_width(context));
					max_rec_height = double.max (max_rec_height, text.get_height(context));
					break;
				case Axis.Type.DATE_TIME:
					var dt = new DateTime.from_unix_utc((int64)x);
					var text = new Text("");
					var h = 0.0;
					if (axis.date_format != "") {
						text = new Text (dt.format(axis.date_format) + (is_horizontal ? "_" : ""));
						text.style = axis.font_style;
						max_rec_width = double.max (max_rec_width, text.get_width(context));
						h = text.get_height(context);
					}
					if (axis.time_format != "") {
						var dsec_str = ("%."+(axis.dsec_signs.to_string())+"f").printf(1.0/3.0).offset(1);
						text = new Text (dt.format(axis.time_format) + (is_horizontal ? "_" : "") + dsec_str);
						text.style = axis.font_style;
						max_rec_width = double.max (max_rec_width, text.get_width(context));
						h += text.get_height(context);
					}
					max_rec_height = double.max (max_rec_height, h);
					break;
				default:
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
			for (var i = 0; i < zoom_series.length; ++i) {
				var s = zoom_series[i];
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
			for (int si = zoom_series.length - 1; si >=0; --si) {
				var s = zoom_series[si];
				if (   s.axis_x.position != zoom_series[0].axis_x.position
				    || s.axis_x.zoom_min != zoom_series[0].axis_x.zoom_min
				    || s.axis_x.zoom_max != zoom_series[0].axis_x.zoom_max
				    || s.place.zoom_x_low != zoom_series[0].place.zoom_x_low
				    || s.place.zoom_x_high != zoom_series[0].place.zoom_x_high
				    || s.axis_x.type != zoom_series[0].axis_x.type)
					common_x_axes = false;
				if (   s.axis_y.position != zoom_series[0].axis_y.position
				    || s.axis_y.zoom_min != zoom_series[0].axis_y.zoom_min
				    || s.axis_y.zoom_max != zoom_series[0].axis_y.zoom_max
				    || s.place.zoom_y_low != zoom_series[0].place.zoom_y_low
				    || s.place.zoom_y_high != zoom_series[0].place.zoom_y_high)
					common_y_axes = false;
			}
			if (zoom_series.length == 1) common_x_axes = common_y_axes = false;

			// Join and calc X-axes
			for (int si = zoom_series.length - 1, nskip = 0; si >=0; --si) {
				if (nskip != 0) {--nskip; continue;}
				var s = zoom_series[si];
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_x, out max_rec_width, out max_rec_height, true);
				var max_font_indent = s.axis_x.font_indent;
				var max_axis_font_height = s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = zoom_series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = zoom_series[sk];
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

				if (!common_x_axes || si == 0)
					switch (s.axis_x.position) {
					case Axis.Position.LOW: plot_area_y_max -= max_rec_height + max_font_indent + max_axis_font_height; break;
					case Axis.Position.HIGH: plot_area_y_min += max_rec_height + max_font_indent + max_axis_font_height; break;
					case Axis.Position.BOTH: break;
					default: break;
					}
			}

			// Join and calc Y-axes
			for (int si = zoom_series.length - 1, nskip = 0; si >=0; --si) {
				if (nskip != 0) {--nskip; continue;}
				var s = zoom_series[si];
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_y, out max_rec_width, out max_rec_height, false);
				var max_font_indent = s.axis_y.font_indent;
				var max_axis_font_width = s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = zoom_series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = zoom_series[sk];
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

				if (!common_y_axes || si == 0)
					switch (s.axis_y.position) {
					case Axis.Position.LOW: plot_area_x_min += max_rec_width + max_font_indent + max_axis_font_width; break;
					case Axis.Position.HIGH: plot_area_x_max -= max_rec_width + max_font_indent + max_axis_font_width; break;
					case Axis.Position.BOTH: break;
					default: break;
					}
			}
		}

		bool point_belong (Float128 p, Float128 a, Float128 b) {
			if (a > b) { Float128 tmp = a; a = b; b = tmp; }
			if (a <= p <= b) return true;
			return false;
		}

		protected virtual void draw_horizontal_axis () {
			for (int si = zoom_series.length - 1, nskip = 0; si >=0; --si) {
				if (common_x_axes && si != 0) continue;
				var s = zoom_series[si];
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

				// 4.5. Draw Axis title
				if (s.axis_x.title.text != "")
					switch (s.axis_x.position) {
					case Axis.Position.LOW:
						var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.zoom_x_low + s.place.zoom_x_high) / 2.0;
						var scr_y = cur_y_max - s.axis_x.font_indent;
						context.move_to(scr_x - s.axis_x.title.get_width(context) / 2.0, scr_y);
						set_source_rgba(s.axis_x.color);
						if (common_x_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_x.title);
						break;
					case Axis.Position.HIGH:
						var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.zoom_x_low + s.place.zoom_x_high) / 2.0;
						var scr_y = cur_y_min + s.axis_x.font_indent + s.axis_x.title.get_height(context);
						context.move_to(scr_x - s.axis_x.title.get_width(context) / 2.0, scr_y);
						set_source_rgba(s.axis_x.color);
						if (common_x_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_x.title);
						break;
					case Axis.Position.BOTH:
						break;
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
						var dt = new DateTime.from_unix_utc((int64)x);
						text = dt.format(s.axis_x.date_format);
						var dsec_str =
							("%."+(s.axis_x.dsec_signs.to_string())+"Lf").printf((LongDouble)(x - (int64)x)).offset(1);
						time_text = dt.format(s.axis_x.time_format) + dsec_str;
						break;
					default:
						break;
					}
					var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min)
					            * (s.place.zoom_x_low + (s.place.zoom_x_high - s.place.zoom_x_low) / (s.axis_x.zoom_max - s.axis_x.zoom_min) * (x - s.axis_x.zoom_min));
					var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
					switch (s.axis_x.position) {
					case Axis.Position.LOW:
						var print_y = cur_y_max - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y);
							show_text(text_t);
							break;
						case Axis.Type.DATE_TIME:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y);
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = scr_x - time_text_t.get_width(context) / 2.0 - time_text_t.get_x_bearing(context)
							          - time_text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						default:
							break;
						}
						// 6. Draw grid lines to the s.place.zoom_y_high.
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
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y);
							show_text(text_t);
							break;
						case Axis.Type.DATE_TIME:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y);
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = scr_x - time_text_t.get_width(context) / 2.0 - time_text_t.get_x_bearing(context)
							          - time_text_t.get_width(context) * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						default:
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
					case Axis.Position.BOTH:
						break;
					default:
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = zoom_series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = zoom_series[sk];
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
				case Axis.Position.BOTH:
					break;
				default: break;
				}
			}
		}

		protected virtual void draw_vertical_axis () {
			for (int si = zoom_series.length - 1, nskip = 0; si >=0; --si) {
				if (common_y_axes && si != 0) continue;
				var s = zoom_series[si];
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

				// 4.5. Draw Axis title
				if (s.axis_y.title.text != "")
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.zoom_y_low + s.place.zoom_y_high) / 2.0;
						var scr_x = cur_x_min + s.axis_y.font_indent + s.axis_y.title.get_width(context);
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						set_source_rgba(s.axis_y.color);
						if (common_y_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_y.title);
						break;
					case Axis.Position.HIGH:
						var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.zoom_y_low + s.place.zoom_y_high) / 2.0;
						var scr_x = cur_x_max - s.axis_y.font_indent;
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						set_source_rgba(s.axis_y.color);
						if (common_y_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_y.title);
						break;
					case Axis.Position.BOTH:
						break;
					}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 y = y_min, y_max = s.axis_y.zoom_max; point_belong (y, y_min, y_max); y += step) {
					if (common_y_axes) set_source_rgba(Color(0,0,0,1));
					else set_source_rgba(s.axis_y.color);
					var text = s.axis_y.format.printf((LongDouble)y);
					var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min)
					            * (s.place.zoom_y_low + (s.place.zoom_y_high - s.place.zoom_y_low) / (s.axis_y.zoom_max - s.axis_y.zoom_min) * (y - s.axis_y.zoom_min));
					var text_t = new Text(text, s.axis_y.font_style, s.axis_y.color);
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						context.move_to (cur_x_min + max_rec_width - (new Text(text)).get_width(context) + s.axis_y.font_indent - text_t.get_x_bearing(context)
						                 + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent),
						                 scr_y + (new Text(text)).get_height(context) / 2.0
						                 + text_t.get_height(context) * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.zoom_y_high.
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
						                 scr_y + (new Text(text)).get_height(context) / 2.0
						                 + text_t.get_height(context) * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.zoom_y_high.
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
					case Axis.Position.BOTH:
						break;
					default:
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = zoom_series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = zoom_series[sk];
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
				case Axis.Position.BOTH:
					break;
				default: break;
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

		protected virtual Float128 get_real_x (Series s, double scr_x) {
			return s.axis_x.zoom_min + ((scr_x - plot_area_x_min) / (plot_area_x_max - plot_area_x_min) - s.place.zoom_x_low)
			       * (s.axis_x.zoom_max - s.axis_x.zoom_min) / (s.place.zoom_x_high - s.place.zoom_x_low);
		}

		protected virtual Float128 get_real_y (Series s, double scr_y) {
			return s.axis_y.zoom_min + ((plot_area_y_max - scr_y) / (plot_area_y_max - plot_area_y_min) - s.place.zoom_y_low)
			       * (s.axis_y.zoom_max - s.axis_y.zoom_min) / (s.place.zoom_y_high - s.place.zoom_y_low);
		}

		protected virtual bool point_in_rect (Point p, double x0, double x1, double y0, double y1) {
			if (   (x0 <= p.x <= x1 || x1 <= p.x <= x0)
			    && (y0 <= p.y <= y1 || y1 <= p.y <= y0))
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
		void sort_points(Point[] points, PointComparator compare) {
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

		protected virtual void draw_series () {
			for (int si = 0; si < zoom_series.length; ++si) {
				var s = zoom_series[si];
				if (s.points.length == 0) continue;
				var points = s.points.copy();
				switch(s.sort) {
				case Series.Sort.BY_X:
					sort_points(points, (a, b) => {
					    if (a.x < b.x) return -1;
					    if (a.x > b.x) return 1;
					    return 0;
					});
					break;
				case Series.Sort.BY_Y:
					sort_points(points, (a, b) => {
					    if (a.y < b.y) return -1;
					    if (a.y > b.y) return 1;
					    return 0;
					});
					break;
				}
				set_line_style(s.line_style);
				// draw zoom_series line
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

		// TODO:
		protected virtual void draw_cursors () {
		}

		public Chart copy () {
			var chart = new Chart ();
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
			chart.height = this.height;
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
			chart.rel_zoom_x_min = this.rel_zoom_x_min;
			chart.rel_zoom_x_max = this.rel_zoom_x_max;
			chart.rel_zoom_y_min = this.rel_zoom_y_min;
			chart.rel_zoom_y_max = this.rel_zoom_y_max;
			chart.selection_style = this.selection_style;
			chart.zoom_series = this.zoom_series.copy();
			chart.show_legend = this.show_legend;
			chart.title = this.title.copy().copy();
			chart.title_height = this.title_height;
			chart.title_vindent = this.title_vindent;
			chart.title_width = this.title_width;
			chart.width = this.width;
			return chart;
		}
	}
}
