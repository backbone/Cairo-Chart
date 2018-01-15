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

		public Chart () {
			bg_color = Color (1, 1, 1);
		}

		public double cur_x_min = 0.0;
		public double cur_x_max = 1.0;
		public double cur_y_min = 0.0;
		public double cur_y_max = 1.0;

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

			get_cursors_crossings();

			calc_plot_area ();

			draw_horizontal_axes ();
			check_cur_values ();

			draw_vertical_axes ();
			check_cur_values ();

			draw_plot_area_border ();
			check_cur_values ();

			draw_series ();
			check_cur_values ();

			draw_cursors ();
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

		// relative zoom limits
		protected double rz_x_min = 0.0;
		protected double rz_x_max = 1.0;
		protected double rz_y_min = 0.0;
		protected double rz_y_max = 1.0;

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

			var new_rz_x_min = rz_x_min + (x0 - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
			var new_rz_x_max = rz_x_min + (x1 - plot_x_min) / (plot_x_max - plot_x_min) * (rz_x_max - rz_x_min);
			var new_rz_y_min = rz_y_min + (y0 - plot_y_min) / (plot_y_max - plot_y_min) * (rz_y_max - rz_y_min);
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

		public virtual void move (double delta_x, double delta_y) {
			delta_x /= plot_x_max - plot_x_min; delta_x *= - 1.0;
			delta_y /= plot_y_max - plot_y_min; delta_y *= - 1.0;
			var rzxmin = rz_x_min, rzxmax = rz_x_max, rzymin = rz_y_min, rzymax = rz_y_max;
			zoom_out();
			delta_x *= plot_x_max - plot_x_min;
			delta_y *= plot_y_max - plot_y_min;
			var xmin = plot_x_min + (plot_x_max - plot_x_min) * rzxmin;
			var xmax = plot_x_min + (plot_x_max - plot_x_min) * rzxmax;
			var ymin = plot_y_min + (plot_y_max - plot_y_min) * rzymin;
			var ymax = plot_y_min + (plot_y_max - plot_y_min) * rzymax;

			delta_x *= rzxmax - rzxmin; delta_y *= rzymax - rzymin;

			if (xmin + delta_x < plot_x_min) delta_x = plot_x_min - xmin;
			if (xmax + delta_x > plot_x_max) delta_x = plot_x_max - xmax;
			if (ymin + delta_y < plot_y_min) delta_y = plot_y_min - ymin;
			if (ymax + delta_y > plot_y_max) delta_y = plot_y_max - ymax;

			zoom_in (xmin + delta_x, ymin + delta_y, xmax + delta_x, ymax + delta_y);
		}

		public double title_width { get; protected set; default = 0.0; }
		public double title_height { get; protected set; default = 0.0; }

		public double title_indent = 4;

		protected virtual void draw_chart_title () {
			var sz = title.get_size(context);
			title_height = sz.height + (legend.position == Legend.Position.TOP ? title_indent * 2 : title_indent);
			cur_y_min += title_height;
			set_source_rgba(title.color);
			context.move_to (width/2 - sz.width/2, sz.height + title_indent);
			title.show(context);
		}

		public Line.Style selection_style = Line.Style ();

		public virtual void draw_selection (double x0, double y0, double x1, double y1) {
			selection_style.set(this);
			context.rectangle (x0, y0, x1 - x0, y1 - y0);
			context.stroke();
		}

		public double plot_x_min = 0;
		public double plot_x_max = 0;
		public double plot_y_min = 0;
		public double plot_y_max = 0;

		public bool joint_x { get; protected set; default = false; }
		public bool joint_y { get; protected set; default = false; }
		public Color joint_axis_color = Color (0, 0, 0, 1);

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
					case Cursor.Orientation.VERTICAL:
						if (is_x && joint_x)
							switch (axis.position) {
							case Axis.Position.LOW: plot_y_max -= max_rec_height + axis.font_indent; break;
							case Axis.Position.HIGH: plot_y_min += max_rec_height + axis.font_indent; break;
							}
						break;
					case Cursor.Orientation.HORIZONTAL:
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

		protected virtual double compact_rec_x_pos (Series s, Float128 x, Text text) {
			var sz = text.get_size(context);
			return get_scr_x(s, x) - sz.width / 2.0
			       - sz.width * (x - (s.axis_x.zoom_min + s.axis_x.zoom_max) / 2.0) / (s.axis_x.zoom_max - s.axis_x.zoom_min);
		}

		protected virtual double compact_rec_y_pos (Series s, Float128 y, Text text) {
			var sz = text.get_size(context);
			return get_scr_y(s, y) + sz.height / 2.0
			       + sz.height * (y - (s.axis_y.zoom_min + s.axis_y.zoom_max) / 2.0) / (s.axis_y.zoom_max - s.axis_y.zoom_min);
		}

		public CairoChart.Math math = new Math();

		protected virtual void draw_horizontal_axis (int si, ref int nskip) {
				var s = series[si];
				if (!s.zoom_show) return;
				if (joint_x && si != zoom_first_show) return;

				// 1. Detect max record width/height by axis.nrecords equally selected points using format.
				double max_rec_width, max_rec_height;
				s.axis_x.calc_rec_sizes (this, out max_rec_width, out max_rec_height, true);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_x_max - plot_x_min) * (s.place.zoom_x_max - s.place.zoom_x_min) / max_rec_width);

				// 3. Calculate grid step.
				Float128 step = math.calc_round_step ((s.axis_x.zoom_max - s.axis_x.zoom_min) / max_nrecs, s.axis_x.type == Axis.Type.DATE_TIME);
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
				if (joint_x && cursor_style.orientation == Cursor.Orientation.VERTICAL && cursors_crossings.length != 0) {
					switch (s.axis_x.position) {
					case Axis.Position.LOW: cur_y_max -= max_rec_height + s.axis_x.font_indent; break;
					case Axis.Position.HIGH: cur_y_min += max_rec_height + s.axis_x.font_indent; break;
					}
				}

				var sz = s.axis_x.title.get_size(context);

				// 4.5. Draw Axis title
				if (s.axis_x.title.text != "") {
					var scr_x = plot_x_min + (plot_x_max - plot_x_min) * (s.place.zoom_x_min + s.place.zoom_x_max) / 2.0;
					double scr_y = 0.0;
					switch (s.axis_x.position) {
					case Axis.Position.LOW: scr_y = cur_y_max - s.axis_x.font_indent; break;
					case Axis.Position.HIGH: scr_y = cur_y_min + s.axis_x.font_indent + sz.height; break;
					}
					context.move_to(scr_x - sz.width / 2.0, scr_y);
					set_source_rgba(s.axis_x.color);
					if (joint_x) set_source_rgba(joint_axis_color);
					s.axis_x.title.show(context);
				}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 x = x_min, x_max = s.axis_x.zoom_max; math.point_belong (x, x_min, x_max); x += step) {
					if (joint_x) set_source_rgba(joint_axis_color);
					else set_source_rgba(s.axis_x.color);
					string text = "", time_text = "";
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS:
						text = s.axis_x.format.printf((LongDouble)x);
						break;
					case Axis.Type.DATE_TIME:
						s.axis_x.format_date_time(x, out text, out time_text);
						break;
					}
					var scr_x = get_scr_x (s, x);
					var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
					switch (s.axis_x.position) {
					case Axis.Position.LOW:
						var print_y = cur_y_max - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
						var print_x = compact_rec_x_pos (s, x, text_t);
						context.move_to (print_x, print_y);
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							text_t.show(context);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") text_t.show(context);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") time_text_t.show(context);
							break;
						}
						// 6. Draw grid lines to the s.place.zoom_y_min.
						var line_style = s.grid.line_style;
						if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
						line_style.set(this);
						double y = cur_y_max - max_rec_height - s.axis_x.font_indent - (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (joint_x)
							context.line_to (scr_x, plot_y_min);
						else
							context.line_to (scr_x, double.min (y, plot_y_max - (plot_y_max - plot_y_min) * s.place.zoom_y_max));
						break;
					case Axis.Position.HIGH:
						var print_y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
						var print_x = compact_rec_x_pos (s, x, text_t);
						context.move_to (print_x, print_y);

						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							text_t.show(context);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") text_t.show(context);
							var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.get_height(context) + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") time_text_t.show(context);
							break;
						}
						// 6. Draw grid lines to the s.place.zoom_y_max.
						var line_style = s.grid.line_style;
						if (joint_x) line_style.color = Color(0, 0, 0, 0.5);
						line_style.set(this);
						double y = cur_y_min + max_rec_height + s.axis_x.font_indent + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
						context.move_to (scr_x, y);
						if (joint_x)
							context.line_to (scr_x, plot_y_max);
						else
							context.line_to (scr_x, double.max (y, plot_y_max - (plot_y_max - plot_y_min) * s.place.zoom_y_min));
						break;
					}
				}
				context.stroke ();

				double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
				s.join_relative_x_axes (this, si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

				if (nskip != 0) {--nskip; return;}

				switch (s.axis_x.position) {
				case Axis.Position.LOW:
					cur_y_max -= max_rec_height + s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					break;
				case Axis.Position.HIGH:
					cur_y_min += max_rec_height +  s.axis_x.font_indent
					             + (s.axis_x.title.text == "" ? 0 : sz.height + s.axis_x.font_indent);
					break;
				}

		}

		protected virtual void draw_horizontal_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				draw_horizontal_axis (si, ref nskip);
			}
		}

		protected virtual void draw_vertical_axes () {
			for (var si = series.length - 1, nskip = 0; si >=0; --si) {
				var s = series[si];
				if (!s.zoom_show) continue;
				if (joint_y && si != zoom_first_show) continue;
				// 1. Detect max record width/height by axis.nrecords equally selected points using format.
				double max_rec_width, max_rec_height;
				s.axis_y.calc_rec_sizes (this, out max_rec_width, out max_rec_height, false);

				// 2. Calculate maximal available number of records, take into account the space width.
				long max_nrecs = (long) ((plot_y_max - plot_y_min) * (s.place.zoom_y_max - s.place.zoom_y_min) / max_rec_height);

				// 3. Calculate grid step.
				Float128 step = math.calc_round_step ((s.axis_y.zoom_max - s.axis_y.zoom_min) / max_nrecs);
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
				if (joint_y && cursor_style.orientation == Cursor.Orientation.HORIZONTAL && cursors_crossings.length != 0) {
					switch (s.axis_y.position) {
					case Axis.Position.LOW: cur_x_min += max_rec_width + s.axis_y.font_indent; break;
					case Axis.Position.HIGH: cur_x_max -= max_rec_width + s.axis_y.font_indent; break;
					}
				}

				var sz = s.axis_y.title.get_size(context);

				// 4.5. Draw Axis title
				if (s.axis_y.title.text != "") {
					var scr_y = plot_y_max - (plot_y_max - plot_y_min) * (s.place.zoom_y_min + s.place.zoom_y_max) / 2.0;
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						var scr_x = cur_x_min + s.axis_y.font_indent + sz.width;
						context.move_to(scr_x, scr_y + sz.height / 2.0);
						break;
					case Axis.Position.HIGH:
						var scr_x = cur_x_max - s.axis_y.font_indent;
						context.move_to(scr_x, scr_y + sz.height / 2.0);
						break;
					}
					set_source_rgba(s.axis_y.color);
					if (joint_y) set_source_rgba(joint_axis_color);
					s.axis_y.title.show(context);
				}

				// 5. Draw records, update cur_{x,y}_{min,max}.
				for (Float128 y = y_min, y_max = s.axis_y.zoom_max; math.point_belong (y, y_min, y_max); y += step) {
					if (joint_y) set_source_rgba(joint_axis_color);
					else set_source_rgba(s.axis_y.color);
					var text = s.axis_y.format.printf((LongDouble)y);
					var scr_y = get_scr_y (s, y);
					var text_t = new Text(text, s.axis_y.font_style, s.axis_y.color);
					var text_sz = text_t.get_size(context);
					switch (s.axis_y.position) {
					case Axis.Position.LOW:
						context.move_to (cur_x_min + max_rec_width - text_sz.width + s.axis_y.font_indent
						                 + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent),
						                 compact_rec_y_pos (s, y, text_t));
						text_t.show(context);
						// 6. Draw grid lines to the s.place.zoom_x_min.
						var line_style = s.grid.line_style;
						if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
						line_style.set(this);
						double x = cur_x_min + max_rec_width + s.axis_y.font_indent + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (joint_y)
							context.line_to (plot_x_max, scr_y);
						else
							context.line_to (double.max (x, plot_x_min + (plot_x_max - plot_x_min) * s.place.zoom_x_max), scr_y);
						break;
					case Axis.Position.HIGH:
						context.move_to (cur_x_max - text_sz.width - s.axis_y.font_indent
						                 - (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent),
						                 compact_rec_y_pos (s, y, text_t));
						text_t.show(context);
						// 6. Draw grid lines to the s.place.zoom_x_max.
						var line_style = s.grid.line_style;
						if (joint_y) line_style.color = Color(0, 0, 0, 0.5);
						line_style.set(this);
						double x = cur_x_max - max_rec_width - s.axis_y.font_indent - (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent);
						context.move_to (x, scr_y);
						if (joint_y)
							context.line_to (plot_x_min, scr_y);
						else
							context.line_to (double.min (x, plot_x_min + (plot_x_max - plot_x_min) * s.place.zoom_x_min), scr_y);
						break;
					}
				}
				context.stroke ();

				double tmp1 = 0, tmp2 = 0, tmp3 = 0, tmp4 = 0;
				s.join_relative_y_axes (this, si, false, ref tmp1, ref tmp2, ref tmp3, ref tmp4, ref nskip);

				if (nskip != 0) {--nskip; continue;}

				switch (s.axis_y.position) {
				case Axis.Position.LOW:
					cur_x_min += max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent); break;
				case Axis.Position.HIGH:
					cur_x_max -= max_rec_width + s.axis_y.font_indent
					             + (s.axis_y.title.text == "" ? 0 : sz.width + s.axis_y.font_indent); break;
				}
			}
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

		public virtual Point get_scr_point (Series s, Point p) {
			return Point (get_scr_x(s, p.x), get_scr_y(s, p.y));
		}

		protected virtual Float128 get_real_x (Series s, double scr_x) {
			return s.axis_x.zoom_min + ((scr_x - plot_x_min) / (plot_x_max - plot_x_min) - s.place.zoom_x_min)
			       * (s.axis_x.zoom_max - s.axis_x.zoom_min) / (s.place.zoom_x_max - s.place.zoom_x_min);
		}

		protected virtual Float128 get_real_y (Series s, double scr_y) {
			return s.axis_y.zoom_min + ((plot_y_max - scr_y) / (plot_y_max - plot_y_min) - s.place.zoom_y_min)
			       * (s.axis_y.zoom_max - s.axis_y.zoom_min) / (s.place.zoom_y_max - s.place.zoom_y_min);
		}

		protected virtual Point get_real_point (Series s, Point p) {
			return Point (get_real_x(s, p.x), get_real_y(s, p.y));
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

		protected virtual void draw_series () {
			for (var si = 0; si < series.length; ++si) {
				var s = series[si];
				if (s.zoom_show && s.points.length != 0)
					s.draw(this);
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

		public Cursor.Style cursor_style = Cursor.Style();

		public virtual void remove_active_cursor () {
			if (cursors.length() == 0) return;
			var distance = width * width;
			uint rm_indx = 0;
			uint i = 0;
			foreach (var c in cursors) {
				double d = distance;
				switch (cursor_style.orientation) {
				case Cursor.Orientation.VERTICAL:
					d = (rel2scr_x(c.x) - rel2scr_x(active_cursor.x)).abs();
					break;
				case Cursor.Orientation.HORIZONTAL:
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

		protected virtual Float128 rel2scr_x(Float128 x) {
			return plot_x_min + (plot_x_max - plot_x_min) * (x - rz_x_min) / (rz_x_max - rz_x_min);
		}

		protected virtual Float128 rel2scr_y(Float128 y) {
			return plot_y_min + (plot_y_max - plot_y_min) * (y - rz_y_min) / (rz_y_max - rz_y_min);
		}

		protected virtual Point rel2scr_point (Point p) {
			return Point (rel2scr_x(p.x), rel2scr_y(p.y));
		}

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
				switch (cursor_style.orientation) {
				case Cursor.Orientation.VERTICAL:
					if (c.x <= rz_x_min || c.x >= rz_x_max) continue; break;
				case Cursor.Orientation.HORIZONTAL:
					if (c.y <= rz_y_min || c.y >= rz_y_max) continue; break;
				}

				CursorCross[] crossings = {};
				for (var si = 0, max_si = series.length; si < max_si; ++si) {
					var s = series[si];
					if (!s.zoom_show) continue;

					Point[] points = {};
					switch (cursor_style.orientation) {
					case Cursor.Orientation.VERTICAL:
						points = math.sort_points (s, s.sort);
						break;
					case Cursor.Orientation.HORIZONTAL:
						points = math.sort_points (s, s.sort);
						break;
					}

					for (var i = 0; i + 1 < points.length; ++i) {
						switch (cursor_style.orientation) {
						case Cursor.Orientation.VERTICAL:
							Float128 y = 0.0;
							if (math.vcross(get_scr_point(s, points[i]), get_scr_point(s, points[i+1]), rel2scr_x(c.x),
							                plot_y_min, plot_y_max, out y)) {
								var point = Point(get_real_x(s, rel2scr_x(c.x)), get_real_y(s, y));
								Point size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (s, point, out size, show_x, show_time, show_date, show_y);
								CursorCross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						case Cursor.Orientation.HORIZONTAL:
							Float128 x = 0.0;
							if (math.hcross(get_scr_point(s, points[i]), get_scr_point(s, points[i+1]),
							                plot_x_min, plot_x_max, rel2scr_y(c.y), out x)) {
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
			switch (cursor_style.orientation) {
			case Cursor.Orientation.VERTICAL:
				show_y = true;
				if (!joint_x)
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS: show_x = true; break;
					case Axis.Type.DATE_TIME:
						if (s.axis_x.date_format != "") show_date = true;
						if (s.axis_x.time_format != "") show_time = true;
						break;
					}
				break;
			case Cursor.Orientation.HORIZONTAL:
				if (!joint_y) show_y = true;
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
			string date, time;
			s.axis_x.format_date_time(p.x, out date, out time);
			var date_t = new Text (date, s.axis_x.font_style, s.axis_x.color);
			var time_t = new Text (time, s.axis_x.font_style, s.axis_x.color);
			var x_t = new Text (s.axis_x.format.printf((LongDouble)p.x), s.axis_x.font_style, s.axis_x.color);
			var y_t = new Text (s.axis_y.format.printf((LongDouble)p.y), s.axis_y.font_style, s.axis_y.color);
			double h_x = 0.0, h_y = 0.0;
			if (show_x) { var sz = x_t.get_size(context); size.x = sz.width; h_x = sz.height; }
			if (show_date) { var sz = date_t.get_size(context); size.x = sz.width; h_x = sz.height; }
			if (show_time) { var sz = time_t.get_size(context); size.x = double.max(size.x, sz.width); h_x += sz.height; }
			if (show_y) { var sz = y_t.get_size(context); size.x += sz.width; h_y = sz.height; }
			if ((show_x || show_date || show_time) && show_y) size.x += double.max(s.axis_x.font_indent, s.axis_y.font_indent);
			if (show_date && show_time) h_x += s.axis_x.font_indent;
			size.y = double.max (h_x, h_y);
		}

		protected virtual void draw_cursors () {
			if (series.length == 0) return;

			var all_cursors = get_all_cursors();
			calc_cursors_value_positions();

			for (var cci = 0, max_cci = cursors_crossings.length; cci < max_cci; ++cci) {
				var low = Point(plot_x_max, plot_y_max);  // low and high
				var high = Point(plot_x_min, plot_y_min); //              points of the cursor
				unowned CursorCross[] ccs = cursors_crossings[cci].crossings;
				cursor_style.line_style.set(this);
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

					if (joint_x) {
						switch (s.axis_x.position) {
						case Axis.Position.LOW: high.y = plot_y_max + s.axis_x.font_indent; break;
						case Axis.Position.HIGH: low.y = plot_y_min - s.axis_x.font_indent; break;
						case Axis.Position.BOTH:
							high.y = plot_y_max + s.axis_x.font_indent;
							low.y = plot_y_min - s.axis_x.font_indent;
							break;
						}
					}
					if (joint_y) {
						switch (s.axis_y.position) {
						case Axis.Position.LOW: low.x = plot_x_min - s.axis_y.font_indent; break;
						case Axis.Position.HIGH: high.x = plot_x_max + s.axis_y.font_indent; break;
						case Axis.Position.BOTH:
							low.x = plot_x_min - s.axis_y.font_indent;
							high.x = plot_x_max + s.axis_y.font_indent;
							break;
						}
					}

					context.move_to (ccs[ci].scr_point.x, ccs[ci].scr_point.y);
					context.line_to (ccs[ci].scr_value_point.x, ccs[ci].scr_value_point.y);
				}

				var c = all_cursors.nth_data(cursors_crossings[cci].cursor_index);

				switch (cursor_style.orientation) {
				case Cursor.Orientation.VERTICAL:
					if (low.y > high.y) continue;
					context.move_to (rel2scr_x(c.x), low.y);
					context.line_to (rel2scr_x(c.x), high.y);

					// show joint X value
					if (joint_x) {
						var s = series[zoom_first_show];
						var x = get_real_x(s, rel2scr_x(c.x));
						string text = "", time_text = "";
						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							text = s.axis_x.format.printf((LongDouble)x);
							break;
						case Axis.Type.DATE_TIME:
							s.axis_x.format_date_time(x, out text, out time_text);
							break;
						default:
							break;
						}
						var text_t = new Text(text, s.axis_x.font_style, s.axis_x.color);
						var sz = text_t.get_size(context);
						var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
						var print_y = 0.0;
						switch (s.axis_x.position) {
							case Axis.Position.LOW: print_y = y_min + height - s.axis_x.font_indent
								                    - (legend.position == Legend.Position.BOTTOM ? legend.height : 0);
								break;
							case Axis.Position.HIGH: print_y = y_min + title_height + s.axis_x.font_indent
								                     + (legend.position == Legend.Position.TOP ? legend.height : 0);
								switch (s.axis_x.type) {
								case Axis.Type.NUMBERS:
									print_y += sz.height;
									break;
								case Axis.Type.DATE_TIME:
									print_y += (s.axis_x.date_format == "" ? 0 : sz.height)
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
							text_t.show(context);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") text_t.show(context);
							print_x = compact_rec_x_pos (s, x, time_text_t);
							context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : sz.height + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") time_text_t.show(context);
							break;
						}
					}
					break;
				case Cursor.Orientation.HORIZONTAL:
					if (low.x > high.x) continue;
					context.move_to (low.x, rel2scr_y(c.y));
					context.line_to (high.x, rel2scr_y(c.y));

					// show joint Y value
					if (joint_y) {
						var s = series[zoom_first_show];
						var y = get_real_y(s, rel2scr_y(c.y));
						var text_t = new Text(s.axis_y.format.printf((LongDouble)y, s.axis_y.font_style));
						var print_y = compact_rec_y_pos (s, y, text_t);
						var print_x = 0.0;
						switch (s.axis_y.position) {
						case Axis.Position.LOW:
							print_x = x_min + s.axis_y.font_indent
							          + (legend.position == Legend.Position.LEFT ? legend.width : 0);
							break;
						case Axis.Position.HIGH:
							print_x = x_min + width - text_t.get_width(context) - s.axis_y.font_indent
							          - (legend.position == Legend.Position.RIGHT ? legend.width : 0);
							break;
						}
						context.move_to (print_x, print_y);
						text_t.show(context);
					}
					break;
				}
				context.stroke ();

				// show value (X, Y or [X;Y])
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = series[si];
					var point = ccs[ci].point;
					var size = ccs[ci].size;
					var svp = ccs[ci].scr_value_point;
					var show_x = ccs[ci].show_x;
					var show_date = ccs[ci].show_date;
					var show_time = ccs[ci].show_time;
					var show_y = ccs[ci].show_y;

					set_source_rgba(bg_color);
					context.rectangle (svp.x - size.x / 2, svp.y - size.y / 2, size.x, size.y);
					context.fill();

					if (show_x) {
						set_source_rgba(s.axis_x.color);
						var text_t = new Text(s.axis_x.format.printf((LongDouble)point.x), s.axis_x.font_style);
						context.move_to (svp.x - size.x / 2, svp.y + text_t.get_height(context) / 2);
						if (joint_x) set_source_rgba (joint_axis_color);
						text_t.show(context);
					}

					if (show_time) {
						set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						s.axis_x.format_date_time(point.x, out date, out time);
						var text_t = new Text(time, s.axis_x.font_style);
						var sz = text_t.get_size(context);
						var y = svp.y + sz.height / 2;
						if (show_date) y -= sz.height / 2 + s.axis_x.font_indent / 2;
						context.move_to (svp.x - size.x / 2, y);
						if (joint_x) set_source_rgba (joint_axis_color);
						text_t.show(context);
					}

					if (show_date) {
						set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						s.axis_x.format_date_time(point.x, out date, out time);
						var text_t = new Text(date, s.axis_x.font_style);
						var sz = text_t.get_size(context);
						var y = svp.y + sz.height / 2;
						if (show_time) y += sz.height / 2 + s.axis_x.font_indent / 2;
						context.move_to (svp.x - size.x / 2, y);
						if (joint_x) set_source_rgba (joint_axis_color);
						text_t.show(context);
					}

					if (show_y) {
						set_source_rgba(s.axis_y.color);
						var text_t = new Text(s.axis_y.format.printf((LongDouble)point.y), s.axis_y.font_style);
						var sz = text_t.get_size(context);
						context.move_to (svp.x + size.x / 2 - sz.width, svp.y + sz.height / 2);
						if (joint_y) set_source_rgba (joint_axis_color);
						text_t.show(context);
					}
				}
			}
		}

		public bool get_cursors_delta (out Float128 delta) {
			delta = 0.0;
			if (series.length == 0) return false;
			if (cursors.length() + (is_cursor_active ? 1 : 0) != 2) return false;
			if (joint_x && cursor_style.orientation == Cursor.Orientation.VERTICAL) {
				Float128 val1 = get_real_x (series[zoom_first_show], rel2scr_x(cursors.nth_data(0).x));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = get_real_x (series[zoom_first_show], rel2scr_x(active_cursor.x));
				else
					val2 = get_real_x (series[zoom_first_show], rel2scr_x(cursors.nth_data(1).x));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			if (joint_y && cursor_style.orientation == Cursor.Orientation.HORIZONTAL) {
				Float128 val1 = get_real_y (series[zoom_first_show], rel2scr_y(cursors.nth_data(0).y));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = get_real_y (series[zoom_first_show], rel2scr_y(active_cursor.y));
				else
					val2 = get_real_y (series[zoom_first_show], rel2scr_y(cursors.nth_data(1).y));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			return false;
		}

		public string get_cursors_delta_str () {
			Float128 delta = 0.0;
			if (!get_cursors_delta(out delta)) return "";
			var str = "";
			var s = series[zoom_first_show];
			if (joint_x)
				switch (s.axis_x.type) {
				case Axis.Type.NUMBERS:
					str = s.axis_x.format.printf((LongDouble)delta);
					break;
				case Axis.Type.DATE_TIME:
					var date = "", time = "";
					int64 days = (int64)(delta / 24 / 3600);
					s.axis_x.format_date_time(delta, out date, out time);
					str = days.to_string() + " + " + time;
					break;
				}
			if (joint_y) {
				str = s.axis_y.format.printf((LongDouble)delta);
			}
			return str;
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
	}
}
