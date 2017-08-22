// даты/время: сетка для малых интервалов (< нескольких секунд)
using Cairo;

namespace Gtk.CairoChart {

	public class Chart {

		protected double width = 0;
		protected double height = 0;

		public Cairo.Context context = null;

		public Color bg_color;
		public bool show_legend = true;
		public Text title = new Text ("Cairo Chart");
		public Color border_color = Color(0, 0, 0, 0.3);

		public class Legend {
			public enum Position {
				TOP = 0,	// default
				LEFT,
				RIGHT,
				BOTTOM
			}
			public Position position = Position.TOP;
			public FontStyle font_style = FontStyle();
			public Color bg_color = Color(1, 1, 1);
			public LineStyle border_style = new LineStyle ();
			public double indent = 5;

			public Legend () {
				border_style.color = Color (0, 0, 0, 0.3);
			}
		}

		public Legend legend = new Legend ();

		public Series[] series = {};

		protected LineStyle selection_style = new LineStyle ();

		public Chart () {
			bg_color = Color (1, 1, 1);
		}

		protected double cur_x_min = 0.0;
		protected double cur_x_max = 0.0;
		protected double cur_y_min = 0.0;
		protected double cur_y_max = 0.0;

		public virtual void check_cur_values () {
			if (cur_x_min > cur_x_max)
				cur_x_max = cur_x_min;
			if (cur_y_min > cur_y_max)
				cur_y_max = cur_y_min;
		}

		public virtual bool draw () {

			update_size ();

			draw_background ();

			cur_x_min = cur_y_min = 0.0;
			cur_x_max = width;
			cur_y_max = height;

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

		protected virtual void update_size () {
			if (context != null) {
				width = context.copy_clip_rectangle_list().rectangles[0].width;
				height = context.copy_clip_rectangle_list().rectangles[0].height;
			}
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

		// TODO:
		public virtual bool button_release_event (Gdk.EventButton event) {
			//stdout.puts ("button_release_event\n");
			return true;
		}

		// TODO:
		public virtual bool button_press_event (Gdk.EventButton event) {
			//stdout.puts ("button_press_event\n");
			return true;
		}

		// TODO:
		public virtual bool motion_notify_event (Gdk.EventMotion event) {
			//stdout.puts ("motion_notify_event\n");
			return true;
		}

		// TODO:
		public virtual bool scroll_notify_event (Gdk.EventScroll event) {
			//stdout.puts ("scroll_notify_event\n");
			return true;
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

			foreach (var s in series) {

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

		int axis_rec_npoints = 128;

		protected virtual void calc_axis_rec_sizes (Series.Axis axis, out double max_rec_width, out double max_rec_height, bool is_horizontal = true) {
			max_rec_width = max_rec_height = 0;
			for (var i = 0; i < axis_rec_npoints; ++i) {
				Float128 x = axis.min + (axis.max - axis.min) / axis_rec_npoints * i;
				switch (axis.type) {
				case Series.Axis.Type.NUMBERS:
					var text = new Text (axis.format.printf((LongDouble)x) + (is_horizontal ? "_" : ""));
					text.style = axis.font_style;
					max_rec_width = double.max (max_rec_width, text.get_width(context));
					max_rec_height = double.max (max_rec_height, text.get_height(context));
					break;
				case Series.Axis.Type.DATE_TIME:
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
				//stdout.printf("aver_step = %Lf\n", aver_step);
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
			for (var i = 0; i < series.length; ++i) {
				var s = series[i];
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
			for (int si = series.length - 1; si >=0; --si) {
				var s = series[si];
				if (   s.axis_x.position != series[0].axis_x.position
				    || s.axis_x.min != series[0].axis_x.min
				    || s.axis_x.max != series[0].axis_x.max
				    || s.place.x_low != series[0].place.x_low
				    || s.place.x_high != series[0].place.x_high
				    || s.axis_x.type != series[0].axis_x.type)
					common_x_axes = false;
				if (   s.axis_y.position != series[0].axis_y.position
				    || s.axis_y.min != series[0].axis_y.min
				    || s.axis_y.max != series[0].axis_y.max
				    || s.place.y_low != series[0].place.y_low
				    || s.place.y_high != series[0].place.y_high)
					common_y_axes = false;
			}
			if (series.length == 1) common_x_axes = common_y_axes = false;

			// Join and calc X-axes
			for (int si = series.length - 1, nskip = 0; si >=0; --si) {
				if (nskip != 0) {--nskip; continue;}
				var s = series[si];
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_x, out max_rec_width, out max_rec_height, true);
				var max_font_indent = s.axis_x.font_indent;
				var max_axis_font_height = s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (are_intersect(s2.place.x_low, s2.place.x_high, s3.place.x_low, s3.place.x_high)
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
					case Series.Axis.Position.LOW: plot_area_y_max -= max_rec_height + max_font_indent + max_axis_font_height; break;
					case Series.Axis.Position.HIGH: plot_area_y_min += max_rec_height + max_font_indent + max_axis_font_height; break;
					case Series.Axis.Position.BOTH: break;
					default: break;
					}
			}

			// Join and calc Y-axes
			for (int si = series.length - 1, nskip = 0; si >=0; --si) {
				if (nskip != 0) {--nskip; continue;}
				var s = series[si];
				double max_rec_width = 0; double max_rec_height = 0;
				calc_axis_rec_sizes (s.axis_y, out max_rec_width, out max_rec_height, false);
				var max_font_indent = s.axis_y.font_indent;
				var max_axis_font_width = s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent;

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (are_intersect(s2.place.y_low, s2.place.y_high, s3.place.y_low, s3.place.y_high)
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
					case Series.Axis.Position.LOW: plot_area_x_min += max_rec_width + max_font_indent + max_axis_font_width; break;
					case Series.Axis.Position.HIGH: plot_area_x_max -= max_rec_width + max_font_indent + max_axis_font_width; break;
					case Series.Axis.Position.BOTH: break;
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
			for (int si = series.length - 1, nskip = 0; si >=0; --si) {
				if (common_x_axes && si != 0) continue;
				var s = series[si];
				// 1. Detect max record width/height by axis_rec_npoints equally selected points using format.
				double max_rec_width, max_rec_height;
				calc_axis_rec_sizes (s.axis_x, out max_rec_width, out max_rec_height, true);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_area_x_max - plot_area_x_min) * (s.place.x_high - s.place.x_low) / max_rec_width);

				// 3. Calculate grid step.
				Float128 step = calc_round_step ((s.axis_x.max - s.axis_x.min) / max_nrecs, s.axis_x.type == Series.Axis.Type.DATE_TIME);
				if (step > s.axis_x.max - s.axis_x.min)
					step = s.axis_x.max - s.axis_x.min;

				// 4. Calculate x_min (s.axis_x.min / step, round, multiply on step, add step if < s.axis_x.min).
				Float128 x_min = 0.0;
				if (step >= 1) {
					int64 x_min_nsteps = (int64) (s.axis_x.min / step);
					x_min = x_min_nsteps * step;
				} else {
					int64 round_axis_x_min = (int64)s.axis_x.min;
					int64 x_min_nsteps = (int64) ((s.axis_x.min - round_axis_x_min) / step);
					x_min = round_axis_x_min + x_min_nsteps * step;
				}
				if (x_min < s.axis_x.min) x_min += step;

				// 4.5. Draw Axis title
				if (s.axis_x.title.text != "")
					switch (s.axis_x.position) {
					case Series.Axis.Position.LOW:
						var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.x_low + s.place.x_high) / 2.0;
						var scr_y = cur_y_max - s.axis_x.font_indent;
						context.move_to(scr_x - s.axis_x.title.get_width(context) / 2.0, scr_y);
						set_source_rgba(s.axis_x.color);
						if (common_x_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_x.title);
						break;
					case Series.Axis.Position.HIGH:
						var scr_x = plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.x_low + s.place.x_high) / 2.0;
						var scr_y = cur_y_min + s.axis_x.font_indent + s.axis_x.title.get_height(context);
						context.move_to(scr_x - s.axis_x.title.get_width(context) / 2.0, scr_y);
						set_source_rgba(s.axis_x.color);
						if (common_x_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_x.title);
						break;
					case Series.Axis.Position.BOTH:
						break;
					}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 x = x_min, x_max = s.axis_x.max; point_belong (x, x_min, x_max); x += step) {
					if (common_x_axes) set_source_rgba(Color(0,0,0,1));
					else set_source_rgba(s.axis_x.color);
					string text = "", time_text = "";
					switch (s.axis_x.type) {
					case Series.Axis.Type.NUMBERS:
						text = s.axis_x.format.printf((LongDouble)x);
						break;
					case Series.Axis.Type.DATE_TIME:
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
					            * (s.place.x_low + (s.place.x_high - s.place.x_low) / (s.axis_x.max - s.axis_x.min) * (x - s.axis_x.min));
					var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
					switch (s.axis_x.position) {
					case Series.Axis.Position.LOW:
						var print_y = cur_y_max - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						switch (s.axis_x.type) {
						case Series.Axis.Type.NUMBERS:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y);
							show_text(text_t);
							break;
						case Series.Axis.Type.DATE_TIME:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y);
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = scr_x - time_text_t.get_width(context) / 2.0 - time_text_t.get_x_bearing(context)
							          - time_text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						default:
							break;
						}
						// 6. Draw grid lines to the s.place.y_high.
						var line_style = s.grid.line_style;
						if (common_x_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double y = cur_y_max - max_rec_height - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (common_x_axes)
							context.line_to (scr_x, plot_area_y_min);
						else
							context.line_to (scr_x, double.min (y, plot_area_y_max - (plot_area_y_max - plot_area_y_min) * s.place.y_high));
						break;
					case Series.Axis.Position.HIGH:
						var print_y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						switch (s.axis_x.type) {
						case Series.Axis.Type.NUMBERS:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y);
							show_text(text_t);
							break;
						case Series.Axis.Type.DATE_TIME:
							var print_x = scr_x - text_t.get_width(context) / 2.0 - text_t.get_x_bearing(context)
							              - text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y);
							if (s.axis_x.date_format != "") show_text(text_t);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = scr_x - time_text_t.get_width(context) / 2.0 - time_text_t.get_x_bearing(context)
							          - time_text_t.get_width(context) * (x - (s.axis_x.min + s.axis_x.max) / 2.0) / (s.axis_x.max - s.axis_x.min);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") show_text(time_text_t);
							break;
						default:
							break;
						}
						// 6. Draw grid lines to the s.place.y_high.
						var line_style = s.grid.line_style;
						if (common_x_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (common_x_axes)
							context.line_to (scr_x, plot_area_y_max);
						else
							context.line_to (scr_x, double.max (y, plot_area_y_max - (plot_area_y_max - plot_area_y_min) * s.place.y_low));
						break;
					case Series.Axis.Position.BOTH:
						break;
					default:
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (are_intersect(s2.place.x_low, s2.place.x_high, s3.place.x_low, s3.place.x_high)
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
				case Series.Axis.Position.LOW:
					cur_y_max -= max_rec_height + s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
					break;
				case Series.Axis.Position.HIGH:
					cur_y_min += max_rec_height +  s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : s.axis_x.title.get_height(context) + s.axis_x.font_indent);
					break;
				case Series.Axis.Position.BOTH:
					break;
				default: break;
				}
			}
		}

		protected virtual void draw_vertical_axis () {
			for (int si = series.length - 1, nskip = 0; si >=0; --si) {
				if (common_y_axes && si != 0) continue;
				var s = series[si];
				// 1. Detect max record width/height by axis_rec_npoints equally selected points using format.
				double max_rec_width, max_rec_height;
				calc_axis_rec_sizes (s.axis_y, out max_rec_width, out max_rec_height, false);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_area_y_max - plot_area_y_min) * (s.place.y_high - s.place.y_low) / max_rec_height);

				// 3. Calculate grid step.
				Float128 step = calc_round_step ((s.axis_y.max - s.axis_y.min) / max_nrecs);
				if (step > s.axis_y.max - s.axis_y.min)
					step = s.axis_y.max - s.axis_y.min;

				// 4. Calculate y_min (s.axis_y.min / step, round, multiply on step, add step if < s.axis_y.min).
				Float128 y_min = 0.0;
				if (step >= 1) {
					int64 y_min_nsteps = (int64) (s.axis_y.min / step);
					y_min = y_min_nsteps * step;
				} else {
					int64 round_axis_y_min = (int64)s.axis_y.min;
					int64 y_min_nsteps = (int64) ((s.axis_y.min - round_axis_y_min) / step);
					y_min = round_axis_y_min + y_min_nsteps * step;
				}
				if (y_min < s.axis_y.min) y_min += step;

				// 4.5. Draw Axis title
				if (s.axis_y.title.text != "")
					switch (s.axis_y.position) {
					case Series.Axis.Position.LOW:
						var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.y_low + s.place.y_high) / 2.0;
						var scr_x = cur_x_min + s.axis_y.font_indent + s.axis_y.title.get_width(context);
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						set_source_rgba(s.axis_y.color);
						if (common_y_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_y.title);
						break;
					case Series.Axis.Position.HIGH:
						var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.y_low + s.place.y_high) / 2.0;
						var scr_x = cur_x_max - s.axis_y.font_indent;
						context.move_to(scr_x, scr_y + s.axis_y.title.get_height(context) / 2.0);
						set_source_rgba(s.axis_y.color);
						if (common_y_axes) set_source_rgba(Color(0,0,0,1));
						show_text(s.axis_y.title);
						break;
					case Series.Axis.Position.BOTH:
						break;
					}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 y = y_min, y_max = s.axis_y.max; point_belong (y, y_min, y_max); y += step) {
					if (common_y_axes) set_source_rgba(Color(0,0,0,1));
					else set_source_rgba(s.axis_y.color);
					var text = s.axis_y.format.printf((LongDouble)y);
					var scr_y = plot_area_y_max - (plot_area_y_max - plot_area_y_min)
					            * (s.place.y_low + (s.place.y_high - s.place.y_low) / (s.axis_y.max - s.axis_y.min) * (y - s.axis_y.min));
					var text_t = new Text(text, s.axis_y.font_style, s.axis_y.color);
					switch (s.axis_y.position) {
					case Series.Axis.Position.LOW:
						context.move_to (cur_x_min + max_rec_width - (new Text(text)).get_width(context) + s.axis_y.font_indent - text_t.get_x_bearing(context)
						                 + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent),
						                 scr_y + (new Text(text)).get_height(context) / 2.0
						                 + text_t.get_height(context) * (y - (s.axis_y.min + s.axis_y.max) / 2.0) / (s.axis_y.max - s.axis_y.min));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.y_high.
						var line_style = s.grid.line_style;
						if (common_y_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double x = cur_x_min + max_rec_width + s.axis_y.font_indent + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (common_y_axes)
							context.line_to (plot_area_x_max, scr_y);
						else
							context.line_to (double.max (x, plot_area_x_min + (plot_area_x_max - plot_area_x_min) * s.place.x_high), scr_y);
						break;
					case Series.Axis.Position.HIGH:
						context.move_to (cur_x_max - (new Text(text)).get_width(context) - s.axis_y.font_indent - text_t.get_x_bearing(context)
						                 - (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent),
						                 scr_y + (new Text(text)).get_height(context) / 2.0
						                 + text_t.get_height(context) * (y - (s.axis_y.min + s.axis_y.max) / 2.0) / (s.axis_y.max - s.axis_y.min));
						show_text(text_t);
						// 6. Draw grid lines to the s.place.y_high.
						var line_style = s.grid.line_style;
						if (common_y_axes) line_style.color = Color(0, 0, 0, 0.5);
						set_line_style(line_style);
						double x = cur_x_max - max_rec_width - s.axis_y.font_indent - (s.axis_y.title.text == "" ? 0 :s.axis_y.title.get_width(context) + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (common_y_axes)
							context.line_to (plot_area_x_min, scr_y);
						else
							context.line_to (double.min (x, plot_area_x_min + (plot_area_x_max - plot_area_x_min) * s.place.x_low), scr_y);
						break;
					case Series.Axis.Position.BOTH:
						break;
					default:
						break;
					}
					context.stroke ();
				}

				// join relative x-axes with non-intersect places
				for (int sj = si - 1; sj >= 0; --sj) {
					var s2 = series[sj];
					bool has_intersection = false;
					for (int sk = si; sk > sj; --sk) {
						var s3 = series[sk];
						if (are_intersect(s2.place.y_low, s2.place.y_high, s3.place.y_low, s3.place.y_high)
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
				case Series.Axis.Position.LOW:
					cur_x_min += max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent); break;
				case Series.Axis.Position.HIGH:
					cur_x_max -= max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : s.axis_y.title.get_width(context) + s.axis_y.font_indent); break;
				case Series.Axis.Position.BOTH:
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
				return plot_area_x_min + (plot_area_x_max - plot_area_x_min) * (s.place.x_low + (x - s.axis_x.min)
				                         / (s.axis_x.max - s.axis_x.min) * (s.place.x_high - s.place.x_low));
		}

		protected virtual double get_scr_y (Series s, Float128 y) {
				return plot_area_y_max - (plot_area_y_max - plot_area_y_min) * (s.place.y_low + (y - s.axis_y.min)
				                         / (s.axis_y.max - s.axis_y.min) * (s.place.y_high - s.place.y_low));
		}

		delegate int PointComparator(Series.Point a, Series.Point b);
		void sort_points(Series.Point[] points, PointComparator compare) {
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

		protected virtual void draw_series () {
			for (int si = 0; si < series.length; ++si) {
				var s = series[si];
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
				// move to s.points[0]
				context.move_to (get_scr_x(s, points[0].x), get_scr_y(s, points[0].y));
				// draw series line
				for (int i = 1; i < points.length; ++i)
					context.line_to (get_scr_x(s, points[i].x), get_scr_y(s, points[i].y));
				context.stroke();
				for (int i = 0; i < points.length; ++i)
					draw_marker_at_pos(s.marker_type, get_scr_x(s, points[i].x), get_scr_y(s, points[i].y));
			}
		}

		// TODO:
		protected virtual void draw_cursors () {
		}
	}
}
