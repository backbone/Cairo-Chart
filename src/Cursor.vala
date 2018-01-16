namespace CairoChart {

	public class Cursors {

		public List<Point?> list = new List<Point?> ();
		public Point active_cursor = Point(); // { get; protected set; default = Point128 (); }
		public bool is_cursor_active = false; // { get; protected set; default = false; }
		public Cursors.Style cursor_style = Cursors.Style();
		public Cursors.CursorCrossings[] cursors_crossings = {};

		public Cursors () {
		}

		public Cursors copy () {
			var c = new Cursors ();
			c.list = list.copy();
			c.active_cursor = active_cursor;
			c.is_cursor_active = is_cursor_active;
			c.cursor_style = cursor_style;
			c.cursors_crossings = cursors_crossings;
			return c;
		}

		public enum Orientation {
			VERTICAL = 0,  // default
			HORIZONTAL
		}

		public struct Style {

			public Orientation orientation;
			public double select_distance;
			public Line.Style line_style;

			public Style () {
				orientation = Orientation.VERTICAL;
				select_distance = 32;
				line_style = Line.Style(Color(0.2, 0.2, 0.2, 0.8));
			}
		}

		protected struct CursorCross {
			uint series_index;
			Point128 point;
			Point128 size;
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

		protected List<Point?> get_all_cursors (Chart chart) {
			var all_cursors = list.copy_deep ((src) => { return src; });
			if (is_cursor_active)
				all_cursors.append(active_cursor);
			return all_cursors;
		}

		public void get_cursors_crossings (Chart chart) {
			var all_cursors = get_all_cursors(chart);

			CursorCrossings[] local_cursor_crossings = {};

			for (var ci = 0, max_ci = all_cursors.length(); ci < max_ci; ++ci) {
				var c = all_cursors.nth_data(ci);
				switch (cursor_style.orientation) {
				case Orientation.VERTICAL:
					if (c.x <= chart.rz_x_min || c.x >= chart.rz_x_max) continue; break;
				case Orientation.HORIZONTAL:
					if (c.y <= chart.rz_y_min || c.y >= chart.rz_y_max) continue; break;
				}

				CursorCross[] crossings = {};
				for (var si = 0, max_si = chart.series.length; si < max_si; ++si) {
					var s = chart.series[si];
					if (!s.zoom_show) continue;

					Point128[] points = {};
					switch (cursor_style.orientation) {
					case Orientation.VERTICAL:
						points = chart.math.sort_points (s, s.sort);
						break;
					case Orientation.HORIZONTAL:
						points = chart.math.sort_points (s, s.sort);
						break;
					}

					for (var i = 0; i + 1 < points.length; ++i) {
						switch (cursor_style.orientation) {
						case Orientation.VERTICAL:
							Float128 y = 0.0;
							if (chart.math.vcross(s.get_scr_point(points[i]), s.get_scr_point(points[i+1]), chart.rel2scr_x(c.x),
							                chart.plot_y_min, chart.plot_y_max, out y)) {
								var point = Point128(s.get_real_x(chart.rel2scr_x(c.x)), s.get_real_y(y));
								Point128 size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(chart, s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (chart, s, point, out size, show_x, show_time, show_date, show_y);
								CursorCross cc = {si, point, size, show_x, show_date, show_time, show_y};
								crossings += cc;
							}
							break;
						case Orientation.HORIZONTAL:
							Float128 x = 0.0;
							if (chart.math.hcross(s.get_scr_point(points[i]), s.get_scr_point(points[i+1]),
							                chart.plot_x_min, chart.plot_x_max, chart.rel2scr_y(c.y), out x)) {
								var point = Point128(s.get_real_x(x), s.get_real_y(chart.rel2scr_y(c.y)));
								Point128 size; bool show_x, show_date, show_time, show_y;
								cross_what_to_show(chart, s, out show_x, out show_time, out show_date, out show_y);
								calc_cross_sizes (chart, s, point, out size, show_x, show_time, show_date, show_y);
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

		protected virtual void calc_cursors_value_positions (Chart chart) {
			for (var ccsi = 0, max_ccsi = cursors_crossings.length; ccsi < max_ccsi; ++ccsi) {
				for (var cci = 0, max_cci = cursors_crossings[ccsi].crossings.length; cci < max_cci; ++cci) {
					// TODO: Ticket #142: find smart algorithm of cursors values placements
					unowned CursorCross[] cr = cursors_crossings[ccsi].crossings;
					cr[cci].scr_point = chart.series[cr[cci].series_index].get_scr_point (cr[cci].point);
					var d_max = double.max (cr[cci].size.x / 1.5, cr[cci].size.y / 1.5);
					cr[cci].scr_value_point = Point (cr[cci].scr_point.x + d_max, cr[cci].scr_point.y - d_max);
				}
			}
		}

		protected virtual void cross_what_to_show (Chart chart, Series s, out bool show_x, out bool show_time,
		                                                                  out bool show_date, out bool show_y) {
			show_x = show_time = show_date = show_y = false;
			switch (cursor_style.orientation) {
			case Orientation.VERTICAL:
				show_y = true;
				if (!chart.joint_x)
					switch (s.axis_x.type) {
					case Axis.Type.NUMBERS: show_x = true; break;
					case Axis.Type.DATE_TIME:
						if (s.axis_x.date_format != "") show_date = true;
						if (s.axis_x.time_format != "") show_time = true;
						break;
					}
				break;
			case Orientation.HORIZONTAL:
				if (!chart.joint_y) show_y = true;
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

		protected virtual void calc_cross_sizes (Chart chart, Series s, Point128 p, out Point128 size,
		                                         bool show_x = false, bool show_time = false,
		                                         bool show_date = false, bool show_y = false) {
			if (show_x == show_time == show_date == show_y == false)
				cross_what_to_show(chart, s, out show_x, out show_time, out show_date, out show_y);
			size = Point128 ();
			string date, time;
			s.axis_x.format_date_time(p.x, out date, out time);
			var date_t = new Text (date, s.axis_x.font_style, s.axis_x.color);
			var time_t = new Text (time, s.axis_x.font_style, s.axis_x.color);
			var x_t = new Text (s.axis_x.format.printf((LongDouble)p.x), s.axis_x.font_style, s.axis_x.color);
			var y_t = new Text (s.axis_y.format.printf((LongDouble)p.y), s.axis_y.font_style, s.axis_y.color);
			double h_x = 0.0, h_y = 0.0;
			if (show_x) { var sz = x_t.get_size(chart.context); size.x = sz.width; h_x = sz.height; }
			if (show_date) { var sz = date_t.get_size(chart.context); size.x = sz.width; h_x = sz.height; }
			if (show_time) { var sz = time_t.get_size(chart.context); size.x = double.max(size.x, sz.width); h_x += sz.height; }
			if (show_y) { var sz = y_t.get_size(chart.context); size.x += sz.width; h_y = sz.height; }
			if ((show_x || show_date || show_time) && show_y) size.x += double.max(s.axis_x.font_indent, s.axis_y.font_indent);
			if (show_date && show_time) h_x += s.axis_x.font_indent;
			size.y = double.max (h_x, h_y);
		}

		public virtual void draw_cursors (Chart chart) {
			if (chart.series.length == 0) return;

			var all_cursors = get_all_cursors(chart);
			calc_cursors_value_positions(chart);

			for (var cci = 0, max_cci = cursors_crossings.length; cci < max_cci; ++cci) {
				var low = Point128(chart.plot_x_max, chart.plot_y_max);  // low and high
				var high = Point128(chart.plot_x_min, chart.plot_y_min); //              points of the cursor
				unowned CursorCross[] ccs = cursors_crossings[cci].crossings;
				cursor_style.line_style.set(chart);
				for (var ci = 0, max_ci = ccs.length; ci < max_ci; ++ci) {
					var si = ccs[ci].series_index;
					var s = chart.series[si];
					var p = ccs[ci].point;
					var scrx = s.get_scr_x(p.x);
					var scry = s.get_scr_y(p.y);
					if (scrx < low.x) low.x = scrx;
					if (scry < low.y) low.y = scry;
					if (scrx > high.x) high.x = scrx;
					if (scry > high.y) high.y = scry;

					if (chart.joint_x) {
						switch (s.axis_x.position) {
						case Axis.Position.LOW: high.y = chart.plot_y_max + s.axis_x.font_indent; break;
						case Axis.Position.HIGH: low.y = chart.plot_y_min - s.axis_x.font_indent; break;
						case Axis.Position.BOTH:
							high.y = chart.plot_y_max + s.axis_x.font_indent;
							low.y = chart.plot_y_min - s.axis_x.font_indent;
							break;
						}
					}
					if (chart.joint_y) {
						switch (s.axis_y.position) {
						case Axis.Position.LOW: low.x = chart.plot_x_min - s.axis_y.font_indent; break;
						case Axis.Position.HIGH: high.x = chart.plot_x_max + s.axis_y.font_indent; break;
						case Axis.Position.BOTH:
							low.x = chart.plot_x_min - s.axis_y.font_indent;
							high.x = chart.plot_x_max + s.axis_y.font_indent;
							break;
						}
					}

					chart.context.move_to (ccs[ci].scr_point.x, ccs[ci].scr_point.y);
					chart.context.line_to (ccs[ci].scr_value_point.x, ccs[ci].scr_value_point.y);
				}

				var c = all_cursors.nth_data(cursors_crossings[cci].cursor_index);

				switch (cursor_style.orientation) {
				case Orientation.VERTICAL:
					if (low.y > high.y) continue;
					chart.context.move_to (chart.rel2scr_x(c.x), low.y);
					chart.context.line_to (chart.rel2scr_x(c.x), high.y);

					// show joint X value
					if (chart.joint_x) {
						var s = chart.series[chart.zoom_first_show];
						var x = s.get_real_x(chart.rel2scr_x(c.x));
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
						var sz = text_t.get_size(chart.context);
						var time_text_t = new Text(time_text, s.axis_x.font_style, s.axis_x.color);
						var print_y = 0.0;
						switch (s.axis_x.position) {
							case Axis.Position.LOW: print_y = chart.y_min + chart.height - s.axis_x.font_indent
								                    - (chart.legend.position == Legend.Position.BOTTOM ? chart.legend.height : 0);
								break;
							case Axis.Position.HIGH: print_y = chart.y_min + chart.title_height + s.axis_x.font_indent
								                     + (chart.legend.position == Legend.Position.TOP ? chart.legend.height : 0);
								switch (s.axis_x.type) {
								case Axis.Type.NUMBERS:
									print_y += sz.height;
									break;
								case Axis.Type.DATE_TIME:
									print_y += (s.axis_x.date_format == "" ? 0 : sz.height)
									           + (s.axis_x.time_format == "" ? 0 : time_text_t.get_height(chart.context))
									           + (s.axis_x.date_format == "" || s.axis_x.time_format == "" ? 0 : s.axis_x.font_indent);
									break;
								}
								break;
						}
						var print_x = s.compact_rec_x_pos (x, text_t);
						chart.context.move_to (print_x, print_y);

						switch (s.axis_x.type) {
						case Axis.Type.NUMBERS:
							text_t.show(chart.context);
							break;
						case Axis.Type.DATE_TIME:
							if (s.axis_x.date_format != "") text_t.show(chart.context);
							print_x = s.compact_rec_x_pos (x, time_text_t);
							chart.context.move_to (print_x, print_y - (s.axis_x.date_format == "" ? 0 : sz.height + s.axis_x.font_indent));
							if (s.axis_x.time_format != "") time_text_t.show(chart.context);
							break;
						}
					}
					break;
				case Orientation.HORIZONTAL:
					if (low.x > high.x) continue;
					chart.context.move_to (low.x, chart.rel2scr_y(c.y));
					chart.context.line_to (high.x, chart.rel2scr_y(c.y));

					// show joint Y value
					if (chart.joint_y) {
						var s = chart.series[chart.zoom_first_show];
						var y = s.get_real_y(chart.rel2scr_y(c.y));
						var text_t = new Text(s.axis_y.format.printf((LongDouble)y, s.axis_y.font_style));
						var print_y = s.compact_rec_y_pos (y, text_t);
						var print_x = 0.0;
						switch (s.axis_y.position) {
						case Axis.Position.LOW:
							print_x = chart.x_min + s.axis_y.font_indent
							          + (chart.legend.position == Legend.Position.LEFT ? chart.legend.width : 0);
							break;
						case Axis.Position.HIGH:
							print_x = chart.x_min + chart.width - text_t.get_width(chart.context) - s.axis_y.font_indent
							          - (chart.legend.position == Legend.Position.RIGHT ? chart.legend.width : 0);
							break;
						}
						chart.context.move_to (print_x, print_y);
						text_t.show(chart.context);
					}
					break;
				}
				chart.context.stroke ();

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

					chart.set_source_rgba(chart.bg_color);
					chart.context.rectangle (svp.x - size.x / 2, svp.y - size.y / 2, size.x, size.y);
					chart.context.fill();

					if (show_x) {
						chart.set_source_rgba(s.axis_x.color);
						var text_t = new Text(s.axis_x.format.printf((LongDouble)point.x), s.axis_x.font_style);
						chart.context.move_to (svp.x - size.x / 2, svp.y + text_t.get_height(chart.context) / 2);
						if (chart.joint_x) chart.set_source_rgba (chart.joint_axis_color);
						text_t.show(chart.context);
					}

					if (show_time) {
						chart.set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						s.axis_x.format_date_time(point.x, out date, out time);
						var text_t = new Text(time, s.axis_x.font_style);
						var sz = text_t.get_size(chart.context);
						var y = svp.y + sz.height / 2;
						if (show_date) y -= sz.height / 2 + s.axis_x.font_indent / 2;
						chart.context.move_to (svp.x - size.x / 2, y);
						if (chart.joint_x) chart.set_source_rgba (chart.joint_axis_color);
						text_t.show(chart.context);
					}

					if (show_date) {
						chart.set_source_rgba(s.axis_x.color);
						string date = "", time = "";
						s.axis_x.format_date_time(point.x, out date, out time);
						var text_t = new Text(date, s.axis_x.font_style);
						var sz = text_t.get_size(chart.context);
						var y = svp.y + sz.height / 2;
						if (show_time) y += sz.height / 2 + s.axis_x.font_indent / 2;
						chart.context.move_to (svp.x - size.x / 2, y);
						if (chart.joint_x) chart.set_source_rgba (chart.joint_axis_color);
						text_t.show(chart.context);
					}

					if (show_y) {
						chart.set_source_rgba(s.axis_y.color);
						var text_t = new Text(s.axis_y.format.printf((LongDouble)point.y), s.axis_y.font_style);
						var sz = text_t.get_size(chart.context);
						chart.context.move_to (svp.x + size.x / 2 - sz.width, svp.y + sz.height / 2);
						if (chart.joint_y) chart.set_source_rgba (chart.joint_axis_color);
						text_t.show(chart.context);
					}
				}
			}
		}

		public bool get_cursors_delta (Chart chart, out Float128 delta) {
			delta = 0.0;
			if (chart.series.length == 0) return false;
			if (list.length() + (is_cursor_active ? 1 : 0) != 2) return false;
			if (chart.joint_x && cursor_style.orientation == Orientation.VERTICAL) {
				Float128 val1 = chart.series[chart.zoom_first_show].get_real_x(chart.rel2scr_x(list.nth_data(0).x));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = chart.series[chart.zoom_first_show].get_real_x(chart.rel2scr_x(active_cursor.x));
				else
					val2 = chart.series[chart.zoom_first_show].get_real_x(chart.rel2scr_x(list.nth_data(1).x));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			if (chart.joint_y && cursor_style.orientation == Orientation.HORIZONTAL) {
				Float128 val1 = chart.series[chart.zoom_first_show].get_real_y(chart.rel2scr_y(list.nth_data(0).y));
				Float128 val2 = 0;
				if (is_cursor_active)
					val2 = chart.series[chart.zoom_first_show].get_real_y(chart.rel2scr_y(active_cursor.y));
				else
					val2 = chart.series[chart.zoom_first_show].get_real_y(chart.rel2scr_y(list.nth_data(1).y));
				if (val2 > val1)
					delta = val2 - val1;
				else
					delta = val1 - val2;
				return true;
			}
			return false;
		}

		public string get_cursors_delta_str (Chart chart) {
			Float128 delta = 0.0;
			if (!get_cursors_delta(chart, out delta)) return "";
			var str = "";
			var s = chart.series[chart.zoom_first_show];
			if (chart.joint_x)
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
			if (chart.joint_y) {
				str = s.axis_y.format.printf((LongDouble)delta);
			}
			return str;
		}
	}
}
