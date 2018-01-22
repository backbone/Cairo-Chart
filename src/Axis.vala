namespace CairoChart {

	/**
	 * ``Chart`` axis.
	 */
	public class Axis {

		Chart chart;
		public Text title;
		string _format = "%.2Lf";
		string _date_format = "%Y.%m.%d";
		string _time_format = "%H:%M:%S";
		int _dsec_signs = 2; // 2 signs = centiseconds

		/**
		 * ``Axis`` range/limits.
		 */
		public Range range = new Range();

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
		public LineStyle line_style = LineStyle ();

		/**
		 * Number of equally placed points to evaluate records sizes.
		 */
		public int nrecords = 128;

		/**
		 * Constructs a new ``Axis``.
		 * @param chart {@link Chart} instance.
		 */
		public Axis (Chart chart) {
			this.chart = chart;
			title = new Text (chart, "");
		}

		/**
		 * Gets a copy of the ``Axis``.
		 */
		public virtual Axis copy () {
			var axis = new Axis (chart);
			axis._date_format = this._date_format;
			axis._dsec_signs = this._dsec_signs;
			axis._format = this._format;
			axis._time_format = this._time_format;
			axis.color = this.color;
			axis.font = this.font.copy();
			axis.line_style = this.line_style;
			axis.range = this.range.copy();
			axis.position = this.position;
			axis.scale = this.scale;
			axis.title = this.title.copy();
			axis.dtype = this.dtype;
			axis.nrecords = this.nrecords;
			return axis;
		}

		/**
		 * Prints date/time to strings with a current formats.
		 */
		public virtual void print_dt (Float128 x, out string date, out string time) {
			date = time = "";
			var dt = new DateTime.from_unix_utc((int64)x);
			date = dt.format(date_format);
			var dsec_str =
				("%."+(dsec_signs.to_string())+"Lf").printf((LongDouble)(x - (int64)x)).offset(1);
			time = dt.format(time_format) + dsec_str;
		}

		/**
		 * Zooms out ``Axis``.
		 */
		public virtual void zoom_out () {
			range.zoom_out();
		}
	}
}
