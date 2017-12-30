namespace Gtk.CairoChart {
	[Compact]
	public class Text {
		public string text = "";
		public FontStyle style = FontStyle ();
		public Color color = Color();

		public Cairo.TextExtents get_extents (Cairo.Context context) {
			context.select_font_face (style.family, style.slant, style.weight);
			context.set_font_size (style.size);
			Cairo.TextExtents extents;
			context.text_extents (text, out extents);
			return extents;
		}

		public double get_width (Cairo.Context context) {
			var extents = get_extents (context);
			switch (style.orientation) {
			case FontOrient.HORIZONTAL: return extents.width;
			case FontOrient.VERTICAL: return extents.height;
			default: return 0.0;
			}
		}

		public double get_height (Cairo.Context context) {
			var extents = get_extents (context);
			switch (style.orientation) {
			case FontOrient.HORIZONTAL: return extents.height;
			case FontOrient.VERTICAL: return extents.width;
			default: return 0.0;
			}
		}

		public struct Size {
			double width;
			double height;
		}

		public Size size (Cairo.Context context) {
			var sz = Size();
			var extents = get_extents (context);
			switch (style.orientation) {
			case FontOrient.HORIZONTAL:
				sz.width = extents.width + extents.x_bearing;
				sz.height = extents.height;
				break;
			case FontOrient.VERTICAL:
				sz.width = extents.height; // + extents.x_bearing ?
				sz.height = extents.width; // +- extents.y_bearing ?
				break;
			}
			return sz;
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
