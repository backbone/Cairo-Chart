using Cairo;

namespace CairoChart {

	public class Series {

		public Point[] points = {};
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

		public virtual Series copy () {
			var series = new Series ();
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

		public Series () {
		}

		public virtual void draw (Chart chart) {
			var points = chart.math.sort_points(this, sort);
			line_style.set(chart);
			// draw series line
			for (int i = 1; i < points.length; ++i) {
				Point c, d;
				if (chart.math.cut_line (
				        Point(chart.plot_x_min, chart.plot_y_min),
				        Point(chart.plot_x_max, chart.plot_y_max),
				        Point(chart.get_scr_x(this, points[i - 1].x), chart.get_scr_y(this, points[i - 1].y)),
				        Point(chart.get_scr_x(this, points[i].x), chart.get_scr_y(this, points[i].y)),
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
				if (chart.point_in_plot_area (Point (x, y)))
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
	}
}
