namespace Gtk.CairoChart {
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
}
