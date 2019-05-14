namespace CairoChart {

	/**
	 * {@link Chart} cursors.
	 */
	public class Cursors {

		protected unowned Chart chart;
		protected List<Point?> list = new List<Point?> ();
		protected Point active_cursor = Point(); // { get; protected set; default = Point128 (); }
		protected bool is_cursor_active = false; // { get; protected set; default = false; }
		protected Crossings[] crossings = {};

		/**
		 * ``Cursors`` lines orientation.
		 */
		protected enum Orientation {
			/**
			 * Vertical cursors.
			 */
			VERTICAL,

			/**
			 * Horizontal cursors.
			 */
			HORIZONTAL
		}

		/**
		 * ``Cursors`` style.
		 */
		public struct Style {
			/**
			 * ``Cursors`` lines orientation.
			 */
			public Orientation orientation;

			/**
			 * Maximum distance between mouse and cursor to remove it.
			 */
			public double select_distance;

			/**
			 * ``Cursors`` line style.
			 */
			public LineStyle line_style;

			/**
			 * Constructs a new ``Style``.
			 */
			public Style () {
				orientation = Orientation.VERTICAL;
				select_distance = 32;
				line_style = LineStyle(Color(0.2, 0.2, 0.2, 0.8));
			}
		}

		/**
		 * Cursor style.
		 */
		public Style style = Style();

		/**
		 * Value label style.
		 */
		public LabelStyle label_style = new LabelStyle();

		/**
		 * Has crossings.
		 */
		public bool has_crossings { get { return crossings.length != 0; } protected set {} }

		/**
		 * Constructs a new ``Chart``.
		 * @param chart ``Chart`` instance.
		 */
		public Cursors (Chart chart) {
			this.chart = chart;
		}

		/**
		 * Gets a copy of the ``Cursors``.
		 */
		public Cursors copy () {
			var c = new Cursors (chart);
			//c.list = list.copy();
			c.active_cursor = active_cursor;
			c.is_cursor_active = is_cursor_active;
			c.style = style;
			c.label_style = label_style.copy();
			c.crossings = crossings;
			return c;
		}

		/**
		 * Sets active cursor.
		 * @param p ``Cursor`` position.
		 * @param remove select for removing or not.
		 */
		public virtual void set_active (Point p, bool remove = false) {
			active_cursor.x = chart.zoom.x0 + (p.x - chart.plarea.x0) / chart.plarea.width * chart.zoom.width;
			active_cursor.y = chart.zoom.y1 - (chart.plarea.y1 - p.y) / chart.plarea.height * chart.zoom.height;
			is_cursor_active = ! remove;
		}

		/**
		 * Adds active cursor.
		 */
		public virtual void add_active () {
			list.append (active_cursor);
			is_cursor_active = false;
		}

		/**
		 * Removes active cursor.
		 */
		public virtual void remove_active () {
			if (list.length() == 0) return;
			var distance = 1024.0 * 1024;//width * width;
			uint rm_indx = 0;
			uint i = 0;
			foreach (var c in list) {
				double d = distance;
				switch (style.orientation) {
				case Orientation.VERTICAL: d = (rel2scr_x(c.x) - rel2scr_x(active_cursor.x)).abs(); break;
				case Orientation.HORIZONTAL: d = (rel2scr_y(c.y) - rel2scr_y(active_cursor.y)).abs(); break;
				}
				if (d < distance) {
					distance = d;
					rm_indx = i;
				}
				++i;
			}
			if (distance < style.select_distance)
				list.delete_link(list.nth(rm_indx));
			is_cursor_active = false;
		}

		/**
		 * Gets delta between 2 cursors values.
		 * @param delta returns delta value.
		 */
		public bool get_delta (out Float128 delta) {
			delta = 0;
			if (chart.series.length == 0) return false;
			if (list.length() + (is_cursor_active ? 1 : 0) != 2) return false;
			if (chart.joint_x && style.orientation == Orientation.VERTICAL) {
				Float128 val1 = chart.series[chart.zoom_1st_idx].axis_x.axis_val(rel2scr_x(list.nth_data(0).x));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = chart.series[chart.zoom_1st_idx].axis_x.axis_val(rel2scr_x(active_cursor.x));
				else
					val2 = chart.series[chart.zoom_1st_idx].axis_x.axis_val(rel2scr_x(list.nth_data(1).x));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			if (chart.joint_y && style.orientation == Orientation.HORIZONTAL) {
				Float128 val1 = chart.series[chart.zoom_1st_idx].axis_y.axis_val(rel2scr_y(list.nth_data(0).y));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = chart.series[chart.zoom_1st_idx].axis_y.axis_val(rel2scr_y(active_cursor.y));
				else
					val2 = chart.series[chart.zoom_1st_idx].axis_y.axis_val(rel2scr_y(list.nth_data(1).y));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			return false;
		}

		/**
		 * Gets delta formatted string.
		 */
		public string get_delta_str () {
			Float128 delta = 0;
			if (!get_delta(out delta)) return "";
			var str = "";
			var s = chart.series[chart.zoom_1st_idx];
			if (chart.joint_x)
				switch (s.axis_x.dtype) {
				case Axis.DType.NUMBERS:
					str = s.axis_x.format.printf((LongDouble)delta);
					break;
				case Axis.DType.DATE_TIME:
					var date = "", time = "";
					int64 days = (int64)(delta / 24 / 3600);
					s.axis_x.print_dt(delta, out date, out time);
					str = days.to_string() + " + " + time;
					break;
				}
			if (chart.joint_y) {
				str = s.axis_y.format.printf((LongDouble)delta);
			}
			return str;
		}

		/**
		 * Draws cursors.
		 */
		public virtual void draw () {
			if (chart.series.length == 0) return;

			var all_cursors = get_all_cursors();
			calc_cursors_value_positions();

			for (var cci = 0, max_cci = crossings.length; cci < max_cci; ++cci) {
				var low = Point128(chart.plarea.x1, chart.plarea.y1);  // low and high
				var high = Point128(chart.plarea.x0, chart.plarea.y0); //              points of the cursor
				unowned Cross[] ccs = crossings[cci].crossings;
				style.line_style.apply(chart);
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = chart.series[si];
					var p = ccs[ci].point;
					var scrp = s.scr_pnt(p);
					if (scrp.x < low.x) low.x = scrp.x;
					if (scrp.y < low.y) low.y = scrp.y;
					if (scrp.x > high.x) high.x = scrp.x;
					if (scrp.y > high.y) high.y = scrp.y;

					if (chart.joint_x) {
						switch (s.axis_x.position) {
						case Axis.Position.LOW: high.y = chart.plarea.y1 + s.axis_x.font.vspacing; break;
						case Axis.Position.HIGH: low.y = chart.plarea.y0 - s.axis_x.font.vspacing; break;
						case Axis.Position.BOTH:
							high.y = chart.plarea.y1 + s.axis_x.font.vspacing;
							low.y = chart.plarea.y0 - s.axis_x.font.vspacing;
							break;
						}
					}
					if (chart.joint_y) {
						switch (s.axis_y.position) {
						case Axis.Position.LOW: low.x = chart.plarea.x0 - s.axis_y.font.hspacing; break;
						case Axis.Position.HIGH: high.x = chart.plarea.x1 + s.axis_y.font.hspacing; break;
						case Axis.Position.BOTH:
							low.x = chart.plarea.x0 - s.axis_y.font.hspacing;
							high.x = chart.plarea.x1 + s.axis_y.font.hspacing;
							break;
						}
					}

					chart.ctx.move_to (ccs[ci].scr_point.x, ccs[ci].scr_point.y);
					chart.ctx.line_to (ccs[ci].scr_value_point.x, ccs[ci].scr_value_point.y);
				}

				var c = all_cursors.nth_data(crossings[cci].cursor_index);

				switch (style.orientation) {
				case Orientation.VERTICAL:
					if (low.y > high.y) continue;
					chart.ctx.move_to (rel2scr_x(c.x), low.y);
					chart.ctx.line_to (rel2scr_x(c.x), high.y);

					// show joint X value
					if (chart.joint_x) {
						var s = chart.series[chart.zoom_1st_idx];
						var x = s.axis_x.axis_val(rel2scr_x(c.x));
						string text = "", time_text = "";
						switch (s.axis_x.dtype) {
						case Axis.DType.NUMBERS: text = s.axis_x.format.printf((LongDouble)x); break;
						case Axis.DType.DATE_TIME: s.axis_x.print_dt(x, out text, out time_text); break;
						}
						var text_t = new Text(chart, text, s.axis_x.font, s.axis_x.color);
						var time_text_t = new Text(chart, time_text, s.axis_x.font, s.axis_x.color);
						var print_y = 0.0;
						switch (s.axis_x.position) {
							case Axis.Position.LOW: print_y = chart.area.y1 - s.axis_x.font.vspacing
								                    - (chart.legend.position == Legend.Position.BOTTOM ? chart.legend.height : 0);
								break;
							case Axis.Position.HIGH:
								var title_height = chart.title.height + (chart.legend.position == Legend.Position.TOP ?
								                   chart.title.font.vspacing * 2 : chart.title.font.vspacing);
								print_y = chart.area.y0 + title_height + s.axis_x.font.vspacing
								          + (chart.legend.position == Legend.Position.TOP ? chart.legend.height : 0);
								switch (s.axis_x.dtype) {
								case Axis.DType.NUMBERS:
									print_y += text_t.height;
									break;
								case Axis.DType.DATE_TIME:
									print_y += (s.axis_x.date_format == "" ? 0 : text_t.height)
									           + (s.axis_x.time_format == "" ? 0 : time_text_t.height)
									           + (s.axis_x.date_format == "" || s.axis_x.time_format == "" ? 0 : s.axis_x.font.vspacing);
									break;
								}
								break;
						}
						var print_x = s.axis_x.compact_rec_pos (x, text_t);
						chart.ctx.move_to (print_x, print_y);

						switch (s.axis_x.dtype) {
						case Axis.DType.NUMBERS:
							text_t.show();
							break;
						case Axis.DType.DATE_TIME:
							if (s.axis_x.date_format != "") text_t.show();
							print_x = s.axis_x.compact_rec_pos (x, time_text_t);
							chart.ctx.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : text_t.height + s.axis_x.font.vspacing));
							if (s.axis_x.time_format != "") time_text_t.show();
							break;
						}
					}
					break;
				case Orientation.HORIZONTAL:
					if (low.x > high.x) continue;
					chart.ctx.move_to (low.x, rel2scr_y(c.y));
					chart.ctx.line_to (high.x, rel2scr_y(c.y));

					// show joint Y value
					if (chart.joint_y) {
						var s = chart.series[chart.zoom_1st_idx];
						var y = s.axis_y.axis_val(rel2scr_y(c.y));
						var text_t = new Text(chart, s.axis_y.format.printf((LongDouble)y, s.axis_y.font));
						var print_y = s.axis_y.compact_rec_pos (y, text_t);
						var print_x = 0.0;
						switch (s.axis_y.position) {
						case Axis.Position.LOW:
							print_x = chart.area.x0 + s.axis_y.font.hspacing
							          + (chart.legend.position == Legend.Position.LEFT ? chart.legend.width : 0);
							break;
						case Axis.Position.HIGH:
							print_x = chart.area.x1 - text_t.width - s.axis_y.font.hspacing
							          - (chart.legend.position == Legend.Position.RIGHT ? chart.legend.width : 0);
							break;
						}
						chart.ctx.move_to (print_x, print_y);
						text_t.show();
					}
					break;
				}
				chart.ctx.stroke ();

				// show value (X, Y or [X;Y])
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = chart.series[si];
					var point = ccs[ci].point;
					var size = ccs[ci].size;
					var svp = ccs[ci].scr_value_point;
					var show_x = ccs[ci].show_x;
					var show_date = ccs[ci].show_date;
					var show_time = ccs[ci].show_time;
					var show_y = ccs[ci].show_y;

					// value label background
					chart.color = label_style.bg_color;
					chart.ctx.rectangle (svp.x - size.x / 2, svp.y - size.y / 2, size.x, size.y);
					chart.ctx.fill();
					// value label frame
					label_style.frame_style.apply(chart);
					chart.ctx.move_to (svp.x - size.x / 2, svp.y - size.y / 2);
					chart.ctx.rel_line_to (size.x, 0);
					chart.ctx.rel_line_to (0, size.y);
					chart.ctx.rel_line_to (-size.x, 0);
					chart.ctx.rel_line_to (0, -size.y);
					chart.ctx.stroke();

					if (show_x) {
						chart.color = s.axis_x.color;
						var text_t = new Text(chart, s.axis_x.format.printf((LongDouble)point.x), s.axis_x.font);
						chart.ctx.move_to (svp.x - size.x / 2, svp.y + text_t.height / 2);
						if (chart.joint_x) chart.color = chart.joint_color;
						text_t.show();
					}

					if (show_time) {
						chart.color = s.axis_x.color;
						string date = "", time = "";
						s.axis_x.print_dt(point.x, out date, out time);
						var text_t = new Text(chart, time, s.axis_x.font);
						var y = svp.y + text_t.height / 2;
						if (show_date) y -= text_t.height / 2 + s.axis_x.font.vspacing / 2;
						chart.ctx.move_to (svp.x - size.x / 2, y);
						if (chart.joint_x) chart.color = chart.joint_color;
						text_t.show();
					}

					if (show_date) {
						chart.color = s.axis_x.color;
						string date = "", time = "";
						s.axis_x.print_dt(point.x, out date, out time);
						var text_t = new Text(chart, date, s.axis_x.font);
						var y = svp.y + text_t.height / 2;
						if (show_time) y += text_t.height / 2 + s.axis_x.font.vspacing / 2;
						chart.ctx.move_to (svp.x - size.x / 2, y);
						if (chart.joint_x) chart.color = chart.joint_color;
						text_t.show();
					}

					if (show_y) {
						chart.color = s.axis_y.color;
						var text_t = new Text(chart, s.axis_y.format.printf((LongDouble)point.y), s.axis_y.font);
						chart.ctx.move_to (svp.x + size.x / 2 - text_t.width, svp.y + text_t.height / 2);
						if (chart.joint_y) chart.color = chart.joint_color;
						text_t.show();
					}
				}
			}
		}

		/**
		 * Evaluates crossings.
		 */
		public void eval_crossings () {
			var all_cursors = get_all_cursors();

			Crossings[] local_cursor_crossings = {};

			for (var ci = 0, max_ci = all_cursors.length(); ci < max_ci; ++ci) {
				var c = all_cursors.nth_data(ci);
				switch (style.orientation) {
				case Orientation.VERTICAL: if (c.x <= chart.zoom.x0 || c.x >= chart.zoom.x1) continue; break;
				case Orientation.HORIZONTAL: if (c.y <= chart.zoom.y0 || c.y >= chart.zoom.y1) continue; break;
				}

				Cross[] crossings = {};
				for (var si = 0, max_si = chart.series.length; si < max_si; ++si) {
					var s = chart.series[si];
					if (!s.zoom_show) continue;

					var points = Math.sort_points (s, s.sort);

					for (var i = 0; i + 1 < points.length; ++i) {
						switch (style.orientation) {
						case Orientation.VERTICAL:
							Float128 y = 0;
							if (Math.vcross(s.scr_pnt(points[i]), s.scr_pnt(points[i+1]), rel2scr_x(c.x),
							                chart.plarea.y0, chart.plarea.y1, out y)) {
								var point = Point128(s.axis_x.axis_val(rel2scr_x(c.x)), s.axis_y.axis_val(y));
								Point size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (s, point, out size, show_x, show_time, show_date, show_y);
								Cross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						case Orientation.HORIZONTAL:
							Float128 x = 0;
							if (Math.hcross(s.scr_pnt(points[i]), s.scr_pnt(points[i+1]),
							                chart.plarea.x0, chart.plarea.x1, rel2scr_y(c.y), out x)) {
								var point = Point128(s.axis_x.axis_val(x), s.axis_y.axis_val(rel2scr_y(c.y)));
								Point size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (s, point, out size, show_x, show_time, show_date, show_y);
								Cross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						}
					}
				}
				if (crossings.length != 0) {
					Crossings ccs = {ci, crossings};
					local_cursor_crossings += ccs;
				}
			}
			crossings = local_cursor_crossings;
		}

		protected struct Cross {
			uint series_index;
			Point128 point;
			Point size;
			bool show_x;
			bool show_date;
			bool show_time;
			bool show_y;
			Point scr_point;
			Point scr_value_point;
		}

		protected struct Crossings {
			uint cursor_index;
			Cross[] crossings;
		}

		protected virtual Float128 rel2scr_x(Float128 x) {
			return chart.plarea.x0 + chart.plarea.width * (x - chart.zoom.x0) / chart.zoom.width;
		}

		protected virtual Float128 rel2scr_y(Float128 y) {
			return chart.plarea.y0 + chart.plarea.height * (y - chart.zoom.y0) / chart.zoom.height;
		}

		protected List<Point?> get_all_cursors () {
			var all_cursors = list.copy_deep ((src) => { return src; });
			if (is_cursor_active)
				all_cursors.append(active_cursor);
			return all_cursors;
		}

		protected virtual void scr2cell (int m, int n, Point p, out int i, out int j) {
			i = (int)((p.x - chart.plarea.x0) / chart.plarea.width * m);
			j = (int)((p.y - chart.plarea.y0) / chart.plarea.height * n);
		}

		protected virtual void cell2scr (int m, int n, int i, int j, out Point p) {
			p = Point(chart.plarea.x0 + chart.plarea.width * (i + 0.5) / m,
			          chart.plarea.y0 + chart.plarea.height * (j + 0.5)/ n);
		}

		protected virtual void calc_cursors_value_positions () {
			// 1. Find maximum width/height of cursors values.
			var max_width = 1.0, max_height = 1.0;
			for (var ccsi = 0, max_ccsi = crossings.length; ccsi < max_ccsi; ++ccsi) {
				for (var cci = 0, max_cci = crossings[ccsi].crossings.length; cci < max_cci; ++cci) {
					unowned Cross[] cr = crossings[ccsi].crossings;
					max_width = double.max(max_width, cr[cci].size.x
					         + 4 * double.max(chart.series[cr[cci].series_index].axis_x.font.hspacing,
					                          chart.series[cr[cci].series_index].axis_y.font.hspacing));
					max_height = double.max(max_height, cr[cci].size.y
					         + 4 * double.max(chart.series[cr[cci].series_index].axis_x.font.vspacing,
					                          chart.series[cr[cci].series_index].axis_y.font.vspacing));
				}
			}

			// 2. Calculate 2D-array sizes.
			var m = (int.max(1, (int)(chart.plarea.width / max_width))),
			    n = (int.max(1, (int)(chart.plarea.height / max_height)));

			// 3. Create 2D-array of bool or links to cursors values.
			var arr2d_e = new bool[m, n];

			// 4. Set Busy/Cross Cells
			for (var ccsi = 0, max_ccsi = crossings.length; ccsi < max_ccsi; ++ccsi) {
				for (var cci = 0, max_cci = crossings[ccsi].crossings.length; cci < max_cci; ++cci) {
					unowned Cross[] cr = crossings[ccsi].crossings;
					cr[cci].scr_point = chart.series[cr[cci].series_index].scr_pnt (cr[cci].point);
					int i = 0, j = 0;
					scr2cell(m, n, cr[cci].scr_point, out i, out j);
					arr2d_e[i, j] = true;
				}
			}

			// 5. Calculate positions.
			for (var ccsi = 0, max_ccsi = crossings.length; ccsi < max_ccsi; ++ccsi) {
				for (var cci = 0, max_cci = crossings[ccsi].crossings.length; cci < max_cci; ++cci) {
					unowned Cross[] cr = crossings[ccsi].crossings;
					int i = 0, j = 0;
					scr2cell(m, n, cr[cci].scr_point, out i, out j);
					for (var radius = 1; radius < int.max(m, n); ++radius) {
						bool found = false;

						// top, bottom
						int[] ll = {int.max(0, j - radius), int.min(n - 1, j + radius)};
						foreach (var l in ll) {
							for (var k = int.max(0, i - radius); k <= int.min(m - 1, i + radius); ++k) {
								if (k == i) continue;
								if (!arr2d_e[k, l]) {
									arr2d_e[k, l] = true;
									cell2scr(m, n, k, l, out cr[cci].scr_value_point);
									found = true;
									break;
								}
							}
							if (found) break;
						}
						if (found) break;

						// left, right
						int[] kk = {int.max(0, i - radius), int.min(m - 1, i + radius)};
						foreach (var k in kk) {
							for (var l = int.max(0, j - radius); l <= int.min(n - 1, j + radius); ++l) {
								if (l == j) continue;
								if (!arr2d_e[k, l]) {
									arr2d_e[k, l] = true;
									cell2scr(m, n, k, l, out cr[cci].scr_value_point);
									found = true;
									break;
								}
							}
							if (found) break;
						}
						if (found) break;
					}
				}
			}
		}

		protected virtual void cross_what_to_show (Series s, out bool show_x, out bool show_time,
		                                                     out bool show_date, out bool show_y) {
			show_x = show_time = show_date = show_y = false;
			switch (style.orientation) {
			case Orientation.VERTICAL:
				show_y = true;
				if (!chart.joint_x)
					switch (s.axis_x.dtype) {
					case Axis.DType.NUMBERS: show_x = true; break;
					case Axis.DType.DATE_TIME:
						if (s.axis_x.date_format != "") show_date = true;
						if (s.axis_x.time_format != "") show_time = true;
						break;
					}
				break;
			case Orientation.HORIZONTAL:
				if (!chart.joint_y) show_y = true;
				switch (s.axis_x.dtype) {
				case Axis.DType.NUMBERS: show_x = true; break;
				case Axis.DType.DATE_TIME:
					if (s.axis_x.date_format != "") show_date = true;
					if (s.axis_x.time_format != "") show_time = true;
					break;
				}
				break;
			}
		}

		protected virtual void calc_cross_sizes (Series s, Point128 p, out Point size,
		                                         bool show_x = false, bool show_time = false,
		                                         bool show_date = false, bool show_y = false) {
			if (show_x == show_time == show_date == show_y == false)
				cross_what_to_show(s, out show_x, out show_time, out show_date, out show_y);
			size = Point ();
			string date, time;
			s.axis_x.print_dt(p.x, out date, out time);
			var date_t = new Text(chart, date, s.axis_x.font, s.axis_x.color);
			var time_t = new Text(chart, time, s.axis_x.font, s.axis_x.color);
			var x_t = new Text(chart, s.axis_x.format.printf((LongDouble)p.x), s.axis_x.font, s.axis_x.color);
			var y_t = new Text(chart, s.axis_y.format.printf((LongDouble)p.y), s.axis_y.font, s.axis_y.color);
			var h_x = 0.0, h_y = 0.0;
			if (show_x) { size.x = x_t.width; h_x = x_t.height; }
			if (show_date) { size.x = date_t.width; h_x = date_t.height; }
			if (show_time) { size.x = double.max(size.x, time_t.width); h_x += time_t.height; }
			if (show_y) { size.x += y_t.width; h_y = y_t.height; }
			if ((show_x || show_date || show_time) && show_y) size.x += s.axis_x.font.hspacing + s.axis_y.font.hspacing;
			if (show_date && show_time) h_x += s.axis_x.font.vspacing;
			size.y = double.max (h_x, h_y);
		}
	}
}
