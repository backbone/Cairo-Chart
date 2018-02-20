namespace CairoChart {

	/**
	 * ``Chart`` axis.
	 */
	public class Axis {

		protected unowned Chart chart;
		protected unowned Series ser;
		protected string _format = "%.2Lf";
		protected string _date_format = "%Y.%m.%d";
		protected string _time_format = "%H:%M:%S";
		protected int _dsec_signs = 2; // 2 signs = centiseconds
		protected bool is_x;

		/**
		 * ``Axis`` title.
		 */
		public Text title;

		/**
		 * ``Axis`` range/limits.
		 */
		public Range range = new Range();

		/**
		 * ``Axis`` relative range/limits.
		 */
		public Range place = new Range();

		/**
		 * ``Axis`` position.
		 */
		public enum Position {
			/**
			 * Bottom/Left ``Axis``.
			 */
			LOW = 0,

			/**
			 * Top/Right ``Axis``.
			 */
			HIGH = 1,

			/**
			 * 2 ``Axes``.
			 */
			BOTH = 2
		}

		/**
		 * Position.
		 */
		public Position position = Position.LOW;

		/**
		 * Data type.
		 */
		public enum DType {
			/**
			 * Float128 numbers.
			 */
			NUMBERS = 0,

			/**
			 * Date/Time.
			 */
			DATE_TIME
		}

		/**
		 * Data type.
		 */
		public DType dtype;

		/**
		 * ``Axis`` scale type.
		 */
		public enum Scale {
			/**
			 * Linear scale.
			 */
			LINEAR = 0,

			/**
			 * Logarithmic scale.
			 */
			// LOGARITHMIC,
		}

		/**
		 * Scale type.
		 */
		public Scale scale;

		/**
		 * Float128 numbers print string format.
		 */
		public virtual string format {
			get { return _format; }
			set {
				// TODO: check format
				_format = value;
			}
			default = "%.2Lf";
		}

		/**
		 * Date print string format.
		 */
		public virtual string date_format {
			get { return _date_format; }
			set {
				// TODO: check format
				_date_format = value;
			}
			default = "%Y.%m.%d";
		}

		/**
		 * Time print string format.
		 */
		public virtual string time_format {
			get { return _time_format; }
			set {
				// TODO: check format
				_time_format = value;
			}
			default = "%H:%M:%S";
		}

		/**
		 * Number of second's signs after point.
		 *
		 * 2 signs means centiseconds, 3 signs means milliseconds, etc...
		 */
		public virtual int dsec_signs {
			get { return _dsec_signs; }
			set {
				// TODO: check format
				_dsec_signs = value;
			}
			default = 2;
		}

		/**
		 * ``Axis`` Font style.
		 */
		public Font font = new Font ();

		/**
		 * ``Axis`` color.
		 */
		public Color color = Color ();

		/**
		 * ``Axis`` line style.
		 */
		public LineStyle grid_style = LineStyle (Color(), 1, {2, 3});

		/**
		 * Number of equally placed points to evaluate records sizes.
		 */
		public int nrecords = 128;

		/**
		 * Constructs a new ``Axis``.
		 * @param chart ``Chart`` instance.
		 * @param ser ``Series`` instance.
		 * @param is_x is X-axis or not (Y-axis otherwise).
		 */
		public Axis (Chart chart, Series ser, bool is_x) {
			this.chart = chart;
			this.ser = ser;
			this.is_x = is_x;
			title = new Text (chart, "");
		}

		/**
		 * Gets a copy of the ``Axis``.
		 */
		public virtual Axis copy () {
			var axis = new Axis (chart, ser, is_x);
			axis._date_format = this._date_format;
			axis._dsec_signs = this._dsec_signs;
			axis._format = this._format;
			axis._time_format = this._time_format;
			axis.color = this.color;
			axis.font = this.font.copy();
			axis.grid_style = this.grid_style;
			axis.range = this.range.copy();
			axis.place = this.place.copy();
			axis.position = this.position;
			axis.scale = this.scale;
			axis.title = this.title.copy();
			axis.dtype = this.dtype;
			axis.nrecords = this.nrecords;
			return axis;
		}

		/**
		 * Gets screen position by real ``Axis`` value.
		 * @param axis_value real ``Axis`` value.
		 */
		public virtual double scr_pos (Float128 axis_value) {
			return is_x ? chart.plarea.x0 + chart.plarea.width * (place.zmin + (axis_value - range.zmin) / range.zrange * place.zrange)
			            : chart.plarea.y0 + chart.plarea.height * (1 - (place.zmin + (axis_value - range.zmin) / range.zrange * place.zrange));
		}

		/**
		 * Gets real ``Axis`` value by screen position.
		 * @param scr_pos screen position.
		 */
		public virtual Float128 axis_val (double scr_pos) {
			return is_x ? range.zmin + ((scr_pos - chart.plarea.x0) / chart.plarea.width - place.zmin) * range.zrange / place.zrange
			            : range.zmin + ((chart.plarea.y1 - scr_pos) / chart.plarea.height - place.zmin) * range.zrange / place.zrange;
		}

		/**
		 * Prints date/time to strings with a current formats.
		 * @param date returns formatted date string.
		 * @param time returns formatted time string.
		 */
		public virtual void print_dt (Float128 x, out string date, out string time) {
			date = time = "";
			var dt = new DateTime.from_unix_utc((int64)x);
			date = dt.format(date_format);
			var dsec_str =
				("%."+(dsec_signs.to_string())+"Lf").printf((LongDouble)(x - (int64)x)).offset(1);
			if (time_format != "")
				time = dt.format(time_format) + dsec_str;
		}

		/**
		 * Gets compact placement position on the screen.
		 * @param axis_value real ``Axis`` value.
		 * @param text to place on the screen.
		 */
		public virtual double compact_rec_pos (Float128 axis_value, Text text) {
			return is_x ? scr_pos(axis_value) - text.width / 2 - text.width * (axis_value - (range.zmin + range.zmax) / 2) / range.zrange
			            : scr_pos(axis_value) + text.height / 2 + text.height * (axis_value - (range.zmin + range.zmax) / 2) / range.zrange;
		}

		/**
		 * Zooms out ``Axis``.
		 */
		public virtual void zoom_out () {
			range.zoom_out();
			place.zoom_out();
		}

		/**
		 * Draws axis.
		 * @param nskip number of series to skip printing.
		 */
		public virtual void draw (ref int nskip) {
			if (!ser.zoom_show) return;

			var si = Math.find_arr<Series>(chart.series, ser);
			if (si == -1) return;

			if ((is_x && chart.joint_x || !is_x && chart.joint_y) && si != chart.zoom_1st_idx) return;

			// 1. Detect max record width/height by axis.nrecords equally selected points using format.
			double max_rec_width, max_rec_height;
			calc_rec_sizes (this, out max_rec_width, out max_rec_height, is_x);

			// 2. Calculate maximal available number of records, take into account the space width.
			long max_nrecs = (long) (is_x ? chart.plarea.width * place.zrange / max_rec_width
			                              : chart.plarea.height * place.zrange / max_rec_height);

			// 3. Calculate grid step.
			Float128 step = Math.calc_round_step (range.zrange / max_nrecs, dtype == DType.DATE_TIME);
			if (step > range.zrange)
				step = range.zrange;

			// 4. Calculate min (range.zmin / step, round, multiply on step, add step if < range.zmin).
			Float128 min = 0;
			if (step >= 1) {
				int64 min_nsteps = (int64) (range.zmin / step);
				min = min_nsteps * step;
			} else {
				int64 round_axis_min = (int64)range.zmin;
				int64 min_nsteps = (int64) ((range.zmin - round_axis_min) / step);
				min = round_axis_min + min_nsteps * step;
			}
			if (min < range.zmin) min += step;

			// 4.2. Cursor values for joint axes
			if (chart.cursors.has_crossings)
				if (    is_x && chart.joint_x && chart.cursors.style.orientation == Cursors.Orientation.VERTICAL
					|| !is_x && chart.joint_y && chart.cursors.style.orientation == Cursors.Orientation.HORIZONTAL) {
					var tmp = 0.0;
					if (is_x) tmp = max_rec_height + font.vspacing;
					else      tmp = max_rec_width + font.hspacing;
					switch (position) {
					case Position.LOW:
						if (is_x) chart.evarea.y1 -= tmp;
						else      chart.evarea.x0 += tmp;
						break;
					case Position.HIGH:
						if (is_x) chart.evarea.y0 += tmp;
						else      chart.evarea.x1 -= tmp;
						break;
					}
				}

			var max_rec_spacing = 2 * (is_x ? font.vspacing : font.hspacing);
			var max_title_width = title.text == "" ? 0 : title.width + font.hspacing;
			var max_title_height = title.text == "" ? 0 : title.height + font.vspacing;

			var dx = max_rec_width + max_rec_spacing + max_title_width;
			var dy = max_rec_height + max_rec_spacing + max_title_height;
			chart.evarea.x0 -= dx; chart.evarea.x1 += dx; chart.evarea.y0 -= dy; chart.evarea.y1 += dy;

			if (nskip != 0)
				--nskip;
			else {
				var max_rec_height_all = max_rec_height;
				var max_rec_width_all = max_rec_width;
				if (is_x)
					join_rel_axes (si, true, ref max_rec_width_all, ref max_rec_height_all, ref max_rec_spacing, ref max_title_height, ref nskip);
				else
					join_rel_axes (si, true, ref max_rec_width_all, ref max_rec_height_all, ref max_rec_spacing, ref max_title_width, ref nskip);

				if (is_x && (!chart.joint_x || si == chart.zoom_1st_idx)) {
					var tmp = max_rec_height_all + max_rec_spacing + max_title_height;
					switch (position) {
					case Position.LOW: chart.evarea.y1 -= tmp; break;
					case Position.HIGH: chart.evarea.y0 += tmp; break;
					}
				}
				if (!is_x && (!chart.joint_y || si == chart.zoom_1st_idx)) {
					var tmp = max_rec_width_all + max_rec_spacing + max_title_width;
					switch (position) {
					case Position.LOW: chart.evarea.x0 += tmp; break;
					case Position.HIGH: chart.evarea.x1 -= tmp; break;
					}
				}
			}

			// 4.5. Draw Axis title
			if (title.text != "") {
				if (is_x) {
					var scr_x = chart.plarea.x0 + chart.plarea.width * (place.zmin + place.zmax) / 2;
					var scr_y = 0.0;
					switch (position) {
					case Position.LOW: scr_y = chart.evarea.y1 - font.vspacing; break;
					case Position.HIGH: scr_y = chart.evarea.y0 + font.vspacing + title.height; break;
					}
					chart.ctx.move_to(scr_x - title.width / 2, scr_y);
					chart.color = color;
				} else {
					var scr_y = chart.plarea.y0 + chart.plarea.height * (1 - (place.zmin + place.zmax) / 2);
					switch (position) {
					case Position.LOW:
						var scr_x = chart.evarea.x0 + font.hspacing + title.width;
						chart.ctx.move_to(scr_x, scr_y + title.height / 2);
						break;
					case Position.HIGH:
						var scr_x = chart.evarea.x1 - font.hspacing;
						chart.ctx.move_to(scr_x, scr_y + title.height / 2);
						break;
					}
				}
				if (is_x && chart.joint_x || !is_x && chart.joint_y)
					chart.color = chart.joint_color;
				else
					chart.color = color;
				title.show();
			}

			if (is_x) draw_recs (min, step, max_rec_height);
			else draw_recs (min, step, max_rec_width);

			chart.evarea.x0 += dx; chart.evarea.x1 -= dx; chart.evarea.y0 += dy; chart.evarea.y1 -= dy;

			chart.ctx.stroke ();
		}

		/**
		 * Joins equal axes.
		 * @param nskip returns number of series to skip printing.
		 */
		public virtual void join_axes (ref int nskip) {
			if (!ser.zoom_show) return;
			if (nskip != 0) {--nskip; return;}
			var max_rec_width = 0.0, max_rec_height = 0.0;
			calc_rec_sizes (this, out max_rec_width, out max_rec_height, is_x);
			var max_rec_spacing = 2 * (is_x ? font.vspacing : font.hspacing);
			var max_title_width = title.text == "" ? 0 : title.width + font.hspacing;
			var max_title_height = title.text == "" ? 0 : title.height + font.vspacing;

			var si = Math.find_arr<Series>(chart.series, ser);
			if (si == -1) return;

			if (is_x)
				join_rel_axes (si, true, ref max_rec_width, ref max_rec_height, ref max_rec_spacing, ref max_title_height, ref nskip);
			else
				join_rel_axes (si, true, ref max_rec_width, ref max_rec_height, ref max_rec_spacing, ref max_title_width, ref nskip);

			// for 4.2. Cursor values for joint X axis
			if (si == chart.zoom_1st_idx && chart.cursors.has_crossings) {
				switch (chart.cursors.style.orientation) {
				case Cursors.Orientation.VERTICAL:
					if (is_x && chart.joint_x) {
						var tmp = max_rec_height + font.vspacing;
						switch (position) {
						case Position.LOW: chart.plarea.y1 -= tmp; break;
						case Position.HIGH: chart.plarea.y0 += tmp; break;
						}
					}
					break;
				case Cursors.Orientation.HORIZONTAL:
					if (!is_x && chart.joint_y) {
						var tmp = max_rec_width + font.hspacing;
						switch (position) {
						case Position.LOW: chart.plarea.x0 += tmp; break;
						case Position.HIGH: chart.plarea.x1 -= tmp; break;
						}
					}
					break;
				}
			}
			if (is_x && (!chart.joint_x || si == chart.zoom_1st_idx)) {
				var tmp = max_rec_height + max_rec_spacing + max_title_height;
				switch (position) {
				case Position.LOW: chart.plarea.y1 -= tmp; break;
				case Position.HIGH: chart.plarea.y0 += tmp; break;
				}
			}
			if (!is_x && (!chart.joint_y || si == chart.zoom_1st_idx)) {
				var tmp = max_rec_width + max_rec_spacing + max_title_width;
				switch (position) {
				case Position.LOW: chart.plarea.x0 += tmp; break;
				case Position.HIGH: chart.plarea.x1 -= tmp; break;
				}
			}
		}

		protected virtual void calc_rec_sizes (Axis axis, out double max_rec_width, out double max_rec_height, bool horizontal = true) {
			max_rec_width = max_rec_height = 0;
			for (var i = 0; i < axis.nrecords; ++i) {
				Float128 x = (int64)(axis.range.zmin + axis.range.zrange / axis.nrecords * i) + 1/3.0;
				switch (axis.dtype) {
				case DType.NUMBERS:
					var text = new Text (chart, axis.format.printf((LongDouble)x) + (horizontal ? "_" : ""), axis.font);
					max_rec_width = double.max (max_rec_width, text.width + 2 * text.font.hspacing);
					max_rec_height = double.max (max_rec_height, text.height + 2 * text.font.vspacing);
					break;
				case DType.DATE_TIME:
					string date, time;
					axis.print_dt(x, out date, out time);

					var h = 0.0;
					if (axis.date_format != "") {
						var text = new Text (chart, date + (horizontal ? "_" : ""), axis.font);
						max_rec_width = double.max (max_rec_width, text.width + 2 * text.font.hspacing);
						h = text.height;
					}
					if (axis.time_format != "") {
						var text = new Text (chart, time + (horizontal ? "_" : ""), axis.font);
						max_rec_width = double.max (max_rec_width, text.width + 2 * text.font.hspacing);
						h += text.height;
					}
					max_rec_height = double.max (max_rec_height, h);
					break;
				}
			}
		}

		protected virtual void join_rel_axes (int si,
		                                      bool calc_max_values,
		                                      ref double max_rec_width,
		                                      ref double max_rec_height,
		                                      ref double max_rec_spacing,
		                                      ref double max_title_size,
		                                      ref int nskip) {
			for (int sj = si - 1; sj >= 0; --sj) {
				var s2 = chart.series[sj];
				if (!s2.zoom_show) continue;
				bool has_intersection = false;
				Axis a2 = s2.axis_x; if (!is_x) a2 = s2.axis_y;
				for (int sk = si; sk > sj; --sk) {
					var s3 = chart.series[sk];
					if (!s3.zoom_show) continue;
					Axis a3 = s3.axis_x; if (!is_x) a3 = s3.axis_y;
					if (Math.coord_cross(a2.place.zmin, a2.place.zmax, a3.place.zmin, a3.place.zmax)
					    || a2.position != a3.position || a2.dtype != a3.dtype) {
						has_intersection = true;
						break;
					}
				}
				if (!has_intersection) {
					if (calc_max_values) {
						var tmp_max_rec_width = 0.0, tmp_max_rec_height = 0.0;
						calc_rec_sizes (a2, out tmp_max_rec_width, out tmp_max_rec_height, is_x);
						max_rec_width = double.max (max_rec_width, tmp_max_rec_width);
						max_rec_height = double.max (max_rec_height, tmp_max_rec_height);
						max_rec_spacing = double.max (max_rec_spacing, 2 * (is_x ? a2.font.vspacing : a2.font.hspacing));
						max_title_size = double.max (
						    max_title_size,
						    a2.title.text == "" ? 0
						                        : is_x ? a2.title.height + font.vspacing
						                               : a2.title.width + font.hspacing
						);
					}
					++nskip;
				} else {
					break;
				}
			}
		}

		protected virtual void draw_recs (Float128 min, Float128 step, double max_rec_size) {
			for (Float128 v = min; Math.point_belong (v, min, range.zmax); v += step) {
				if (is_x && chart.joint_x || !is_x && chart.joint_y) {
					chart.color = chart.joint_color;
					ser.axis_x.grid_style.color = Color(0, 0, 0, 0.5);
					ser.axis_y.grid_style.color = Color(0, 0, 0, 0.5);
				} else
					chart.color = color;
				string text = "", time_text = ""; var time_text_t = new Text(chart); var crpt = 0.0;
				switch (dtype) {
				case DType.NUMBERS: text = format.printf((LongDouble)v); break;
				case DType.DATE_TIME:
					print_dt(v, out text, out time_text);
					time_text_t = new Text(chart, time_text, font, color);
					crpt = compact_rec_pos (v, time_text_t);
					break;
				}
				var scr_v = scr_pos (v);
				var text_t = new Text(chart, text, font, color);
				var tthv = title.text == "" ? font.vspacing : title.height + 2 * font.vspacing;
				var ttwh = title.text == "" ? font.hspacing : title.width + 2 * font.hspacing;
				var dtf = (date_format == "" ? 0 : text_t.height + font.vspacing);
				var py0 = chart.plarea.y0, ey0 = chart.evarea.y0 + max_rec_size + tthv, ey1 = chart.evarea.y1 - tthv;
				var px0 = chart.plarea.x0, ex0 = chart.evarea.x0 + max_rec_size + ttwh, ex1 = chart.evarea.x1 - ttwh;
				var ph = chart.plarea.height, pw = chart.plarea.width;
				if (is_x) {
					var crp = compact_rec_pos (v, text_t);
					switch (position) {
					case Position.LOW:
						chart.ctx.move_to (crp, ey1); text_t.show();
						chart.ctx.move_to (crpt, ey1 - dtf); time_text_t.show();
						ser.axis_x.grid_style.apply(chart);
						double y = ey1 - max_rec_size; chart.ctx.move_to (scr_v, y);
						if (chart.joint_x) chart.ctx.line_to (scr_v, py0);
						else chart.ctx.line_to (scr_v, double.min (y, py0 + ph * (1 - ser.axis_y.place.zmax)));
						break;
					case Position.HIGH:
						chart.ctx.move_to (crp, ey0); text_t.show();
						chart.ctx.move_to (crpt, ey0 - dtf); time_text_t.show();
						ser.axis_x.grid_style.apply(chart); chart.ctx.move_to (scr_v, ey0);
						if (chart.joint_x) chart.ctx.line_to (scr_v, chart.plarea.y1);
						else chart.ctx.line_to (scr_v, double.max (ey0, py0 + ph * (1 - ser.axis_y.place.zmin)));
						break;
					}
				} else {
					var crp = compact_rec_pos (v, text_t);
					switch (position) {
					case Position.LOW:
						chart.ctx.move_to (ex0 - text_t.width, crp);
						text_t.show(); ser.axis_y.grid_style.apply(chart);
						chart.ctx.move_to (ex0, scr_v);
						if (chart.joint_y) chart.ctx.line_to (chart.plarea.x1, scr_v);
						else chart.ctx.line_to (double.max (ex0, px0 + pw * ser.axis_x.place.zmax), scr_v);
						break;
					case Position.HIGH:
						chart.ctx.move_to (ex1 - text_t.width, crp);
						text_t.show(); ser.axis_y.grid_style.apply(chart);
						double x = ex1 - max_rec_size; chart.ctx.move_to (x, scr_v);
						if (chart.joint_y) chart.ctx.line_to (px0, scr_v);
						else chart.ctx.line_to (double.min (x, px0 + pw * ser.axis_x.place.zmin), scr_v);
						break;
					}
				}
			}
		}
	}
}
