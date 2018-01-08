namespace CairoChart {
	// If one of axis:title or axis:min/max are different
	// then draw separate axis for each/all series
	// or specify series name near the axis
	public class Axis {
		Float128 _min = 0;
		Float128 _max = 0;
		public Float128 min {
			get { return _min; }
			set { _min = zoom_min = value; }
			default = 0;
		}
		public Float128 max {
			get { return _max; }
			set { _max = zoom_max = value; }
			default = 1;
		}
		public Float128 zoom_min = 0;
		public Float128 zoom_max = 1;
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
		public Font.Style font_style = Font.Style ();
		public Color color = Color ();
		public Line.Style line_style = Line.Style ();
		public double font_indent = 5;

		public Axis copy () {
			var axis = new Axis ();
			axis._date_format = this._date_format;
			axis._dsec_signs = this._dsec_signs;
			axis._format = this._format;
			axis._time_format = this._time_format;
			axis.color = this.color;
			axis.font_indent = this.font_indent;
			axis.font_style = this.font_style;
			axis.line_style = this.line_style;
			axis.max = this.max;
			axis.min = this.min;
			axis.position = this.position;
			axis.scale_type = this.scale_type;
			axis.title = this.title.copy();
			axis.type = this.type;
			return axis;
		}

		public Axis () {}
	}
}
