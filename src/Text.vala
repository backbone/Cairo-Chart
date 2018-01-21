namespace CairoChart {

	/**
	 * ``CairoChart`` Text.
	 */
	public class Text {

		Chart chart = null;

		/**
		 * ``Text`` string.
		 */
		public string text = "";

		/**
		 * ``Text`` font style.
		 */
		public Font style = Font ();

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
		public virtual Cairo.TextExtents ext {
			get {
				chart.ctx.select_font_face (style.family, style.slant, style.weight);
				chart.ctx.set_font_size (style.size);
				Cairo.TextExtents ext;
				chart.ctx.text_extents (text, out ext);
				return ext;
			}
			protected set {
			}
		}

		/**
		 * ``Text`` width.
		 */
		public virtual double width {
			get {
				switch (style.orient) {
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
				switch (style.orient) {
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
		public struct Size {
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
		public virtual Size size {
			get {
				var sz = Size();
				var e = ext;
				switch (style.orient) {
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
			chart.ctx.select_font_face(style.family,
			                           style.slant,
			                           style.weight);
			chart.ctx.set_font_size(style.size);
			if (style.orient == Gtk.Orientation.VERTICAL) {
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
		 * @param style ``Text`` font style.
		 * @param color ``Text`` color.
		 */
		public Text (Chart chart,
		             string text = "",
		             Font style = Font(),
		             Color color = Color()
		) {
			this.chart = chart;
			this.text = text;
			this.style = style;
			this.color = color;
		}

		/**
		 * Gets a copy of the ``Text``.
		 */
		public virtual Text copy () {
			var text = new Text (chart);
			text.chart = this.chart;
			text.text = this.text;
			text.style = this.style;
			text.color = this.color;
			return text;
		}
	}
}
