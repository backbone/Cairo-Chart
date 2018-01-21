namespace CairoChart {

	/**
	 * ``CairoChart`` Text.
	 */
	public class Text {

		Chart chart;
		string _text;
		Font _font;
		Cairo.TextExtents? _ext;

		/**
		 * ``Text`` string.
		 */
		public string text {
			get {
				return _text;
			}
			set {
				_text = value;
				//_ext = null;// TODO: check necessity
			}
		}

		/**
		 * ``Text`` font style.
		 */
		public Font font {
			get {
				return _font;
			}
			set {
				_font = value;
				// TODO: check necessity
				//_font.notify.connect((s, p) => {
				//	_ext = null;
				//});
				//_ext = null;// TODO: check necessity
			}
		}

		/**
		 * ``Text`` color.
		 */
		public Color color = Color();

		/**
		 * Vertical spacing.
		 */
		public double vspacing = 4;

		/**
		 * Horizontal spacing.
		 */
		public double hspacing = 4;

		/**
		 * Both vertical & horizontal spacing (set only).
		 */
		public double spacing {
			protected get {
				return 0;
			}
			set {
				vspacing = hspacing = value;
			}
			default = 4;
		}

		/**
		 * Cairo ``Text`` extents.
		 */
		virtual Cairo.TextExtents ext {
			get {
				if (_ext == null) {
					chart.ctx.select_font_face (font.family, font.slant, font.weight);
					chart.ctx.set_font_size (font.size);
					chart.ctx.text_extents (text, out _ext);
				}
				return _ext;
			}
			protected set {
			}
		}

		/**
		 * ``Text`` width.
		 */
		public virtual double width {
			get {
				switch (font.orient) {
				case Gtk.Orientation.HORIZONTAL: return ext.width;
				case Gtk.Orientation.VERTICAL: return ext.height;
				default: return 0.0;
				}
			}
			protected set {
			}
		}

		/**
		 * ``Text`` height.
		 */
		public virtual double height {
			get {
				switch (font.orient) {
				case Gtk.Orientation.HORIZONTAL: return ext.height;
				case Gtk.Orientation.VERTICAL: return ext.width;
				default: return 0.0;
				}
			}
			protected set {
			}
		}

		/**
		 * ``Text`` size.
		 */
		struct Size {
			/**
			 * ``Text`` width.
			 */
			double width;

			/**
			 * ``Text`` height.
			 */
			double height;
		}

		/**
		 * ``Text`` @{link Size}.
		 */
		virtual Size size {
			get {
				var sz = Size();
				var e = ext;
				switch (font.orient) {
				case Gtk.Orientation.HORIZONTAL:
					sz.width = e.width + e.x_bearing;
					sz.height = e.height;
					break;
				case Gtk.Orientation.VERTICAL:
					sz.width = e.height; // + e.x_bearing ?
					sz.height = e.width; // +- e.y_bearing ?
					break;
				}
				return sz;
			}
			protected set {
			}
		}

		/**
		 * Show ``Text``.
		 */
		public virtual void show () {
			chart.ctx.select_font_face(font.family,
			                           font.slant,
			                           font.weight);
			chart.ctx.set_font_size(font.size);
			if (font.orient == Gtk.Orientation.VERTICAL) {
				chart.ctx.rotate(- GLib.Math.PI / 2.0);
				chart.ctx.show_text(text);
				chart.ctx.rotate(GLib.Math.PI / 2.0);
			} else {
				chart.ctx.show_text(text);
			}
		}

		/**
		 * Constructs a new ``Text``.
		 * @param chart ``Chart`` instance.
		 * @param text ``Text`` string.
		 * @param font ``Text`` font style.
		 * @param color ``Text`` color.
		 */
		public Text (Chart chart,
		             string text = "",
		             Font font = new Font(),
		             Color color = Color()
		) {
			this.chart = chart;
			this.text = text;
			this.font = font;
			this.color = color;
			// TODO: check necessity
			//_font.notify.connect((s, p) => {
			//	_ext = null;
			//});
		}

		/**
		 * Gets a copy of the ``Text``.
		 */
		public virtual Text copy () {
			var text = new Text (chart);
			text.chart = this.chart;
			text._text = this._text;
			text._font = this._font;
			text._ext = this._ext;
			text.color = this.color;
			return text;
		}
	}
}
