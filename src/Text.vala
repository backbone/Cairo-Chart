namespace CairoChart {
	[Compact]
	public class Text {
		public string text = "";
		public Font.Style style = Font.Style ();
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
			case Font.Orientation.HORIZONTAL: return extents.width;
			case Font.Orientation.VERTICAL: return extents.height;
			default: return 0.0;
			}
		}

		public double get_height (Cairo.Context context) {
			var extents = get_extents (context);
			switch (style.orientation) {
			case Font.Orientation.HORIZONTAL: return extents.height;
			case Font.Orientation.VERTICAL: return extents.width;
			default: return 0.0;
			}
		}

		public struct Size {
			double width;
			double height;
		}

		public Size get_size (Cairo.Context context) {
			var sz = Size();
			var extents = get_extents (context);
			switch (style.orientation) {
			case Font.Orientation.HORIZONTAL:
				sz.width = extents.width + extents.x_bearing;
				sz.height = extents.height;
				break;
			case Font.Orientation.VERTICAL:
				sz.width = extents.height; // + extents.x_bearing ?
				sz.height = extents.width; // +- extents.y_bearing ?
				break;
			}
			return sz;
		}

		public void show (Cairo.Context context) {
			context.select_font_face(style.family,
			                         style.slant,
			                         style.weight);
			context.set_font_size(style.size);
			if (style.orientation == Font.Orientation.VERTICAL) {
				context.rotate(- GLib.Math.PI / 2.0);
				context.show_text(text);
				context.rotate(GLib.Math.PI / 2.0);
			} else {
				context.show_text(text);
			}
		}

		public Text (string text = "",
		             Font.Style style = Font.Style(),
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
