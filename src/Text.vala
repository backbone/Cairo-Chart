namespace CairoChart {
	public class Text {
		public string text = "";
		public Font style = Font ();
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
			switch (style.direct) {
			case FontDirect.HORIZONTAL: return extents.width;
			case FontDirect.VERTICAL: return extents.height;
			default: return 0.0;
			}
		}

		public virtual double get_height (Cairo.Context ctx) {
			var extents = get_extents (ctx);
			switch (style.direct) {
			case FontDirect.HORIZONTAL: return extents.height;
			case FontDirect.VERTICAL: return extents.width;
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
			switch (style.direct) {
			case FontDirect.HORIZONTAL:
				sz.width = extents.width + extents.x_bearing;
				sz.height = extents.height;
				break;
			case FontDirect.VERTICAL:
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
			if (style.direct == FontDirect.VERTICAL) {
				ctx.rotate(- GLib.Math.PI / 2.0);
				ctx.show_text(text);
				ctx.rotate(GLib.Math.PI / 2.0);
			} else {
				ctx.show_text(text);
			}
		}

		public Text (string text = "",
		             Font style = Font(),
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
