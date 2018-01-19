namespace CairoChart {
	public class Text {
		public string text = "";
		public Font.Style style = Font.Style ();
		public Color color = Color();
		public double vspacing = 4;
		public double hspacing = 4;
		public double spacing {
			protected get {
				return 0;
			}
			set {
				vspacing = hspacing = value;
			}
			default = 4;
		}

		public virtual Cairo.TextExtents get_extents (Cairo.Context ctx) {
			ctx.select_font_face (style.family, style.slant, style.weight);
			ctx.set_font_size (style.size);
			Cairo.TextExtents extents;
			ctx.text_extents (text, out extents);
			return extents;
		}

		public virtual double get_width (Cairo.Context ctx) {
			var extents = get_extents (ctx);
			switch (style.orientation) {
			case Font.Orientation.HORIZONTAL: return extents.width;
			case Font.Orientation.VERTICAL: return extents.height;
			default: return 0.0;
			}
		}

		public virtual double get_height (Cairo.Context ctx) {
			var extents = get_extents (ctx);
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

		public virtual Size get_size (Cairo.Context ctx) {
			var sz = Size();
			var extents = get_extents (ctx);
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

		public virtual void show (Cairo.Context ctx) {
			ctx.select_font_face(style.family,
			                         style.slant,
			                         style.weight);
			ctx.set_font_size(style.size);
			if (style.orientation == Font.Orientation.VERTICAL) {
				ctx.rotate(- GLib.Math.PI / 2.0);
				ctx.show_text(text);
				ctx.rotate(GLib.Math.PI / 2.0);
			} else {
				ctx.show_text(text);
			}
		}

		public Text (string text = "",
		             Font.Style style = Font.Style(),
		             Color color = Color()
		) {
			this.text = text;
			this.style = style;
			this.color = color;
		}

		public virtual Text copy () {
			var text = new Text ();
			text.text = this.text;
			text.style = this.style;
			text.color = this.color;
			return text;
		}
	}
}
