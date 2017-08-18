using Cairo;

namespace Gtk.CairoChart {

	public class Series {

		public struct Point {
			Float128 x;
			Float128 y;

			public Point (Float128 x, Float128 y) {
				this.x = x; this.y = y;
			}
		}

		public Point[] points = {};
		public enum Sort {
			BY_X = 0,
			BY_Y = 1,
			NO_SORT
		}
		public Sort sort = Sort.BY_X;

		// If one of axis:title or axis:min/max are different
		// then draw separate axis for each/all series
		// or specify series name near the axis
		public class Axis {
			public Float128 min = 0;
			public Float128 max = 1;
			public Text title = new Text ("");
			public enum Type {
				NUMBERS = 0,
				DATE_TIME
			}
			public enum ScaleType {
				LINEAR = 0,		// default
				// LOGARITHMIC, // TODO
				// etc
			}
			public Type type;
			public ScaleType scale_type;
			public enum Position {
				LOW = 0,
				HIGH = 1,
				BOTH = 2
			}
			public Position position = Position.LOW;

			string _format = "%.2Lf";
			string _date_format = "%Y.%m.%d";
			string _time_format = "%H:%M:%S";
			int _dsec_signs = 2; // 2 signs = centiseconds
			public string format {
				get { return _format; }
				set {
					// TODO: check format
					_format = value;
				}
				default = "%.2Lf";
			}
			public string date_format {
				get { return _date_format; }
				set {
					// TODO: check format
					_date_format = value;
				}
				default = "%Y.%m.%d";
			}
			public string time_format {
				get { return _time_format; }
				set {
					// TODO: check format
					_time_format = value;
				}
				default = "%H:%M:%S";
			}
			public int dsec_signs {
				get { return _dsec_signs; }
				set {
					// TODO: check format
					_dsec_signs = value;
				}
				default = 2;
			}
			public FontStyle font_style = FontStyle ();
			public Color color = Color ();
			public LineStyle line_style = new LineStyle ();
			public double font_indent = 5;

			public Axis () {}
		}

		public Axis axis_x = new Axis();
		public Axis axis_y = new Axis();

		public struct Place {
			double x_low;
			double x_high;
			double y_low;
			double y_high;

			public Place (double x_low = 0, double x_high = 0, double y_low = 0, double y_high = 0) {
				this.x_low = x_low;
				this.x_high = x_high;
				this.y_low = y_low;
				this.y_high = y_high;
			}
		}

		public enum MarkerType {
			NONE = 0,	// default
			SQUARE,
			CIRCLE,
			TRIANGLE,
			PRICLE_SQUARE,
			PRICLE_CIRCLE,
			PRICLE_TRIANGLE
		}

		public Place place = new Place();
		public Text title = new Text ();
		public MarkerType marker_type = MarkerType.SQUARE;

		public class Grid {
			/*public enum GridType {
				PRICK_LINE = 0, // default
				LINE
			}*/
			public Color color = Color (0, 0, 0, 0.1);

			public LineStyle line_style = new LineStyle ();

			public Grid () {
				line_style.dashes = {2, 3};
			}
		}

		public Grid grid = new Grid ();

		public GLib.List<Float128?> cursors = new List<Float128?> ();
		public LineStyle line_style = new LineStyle ();

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

		public Series () {
		}

		public class LabelStyle {
			FontStyle font_style = FontStyle();
			LineStyle frame_line_style = new LineStyle();
			Color bg_color = Color();
			Color frame_color = Color();
		}
	}
}
