namespace Gtk.CairoChart {
	[Compact]
	public class Text {
		public string text = "";
		public FontStyle style = FontStyle ();
		public Color color = Color();

		Cairo.TextExtents get_extents (Cairo.Context context) {
			context.select_font_face (style.family,
			                          style.slant,
			                          style.weight);
			context.set_font_size (style.size);
			Cairo.TextExtents extents;
			context.text_extents (text, out extents);
			return extents;
		}

		public double get_width (Cairo.Context context) {
			var extents = get_extents (context);
			if (style.orientation == FontOrient.HORIZONTAL)
				return extents.width;
			else
				return extents.height;
		}

		public double get_height (Cairo.Context context) {
			var extents = get_extents (context);
			if (style.orientation == FontOrient.HORIZONTAL)
				return extents.height;
			else
				return extents.width;
		}

		public double get_x_bearing (Cairo.Context context) {
			var extents = get_extents (context);
			if (style.orientation == FontOrient.HORIZONTAL)
				return extents.x_bearing;
			else
				return extents.y_bearing;
		}

		public Text (string text = "",
		             FontStyle style = FontStyle(),
		             Color color = Color()) {
			this.text = text;
			this.style = style;
			this.color = color;
		}

		public Text copy () {
			var text = new Text ();
			text.text = this.text;
			text.style = this.style;
			text.color = this.color;
			return text;
		}
	}
}
