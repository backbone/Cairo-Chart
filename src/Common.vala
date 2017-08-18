using Cairo;

namespace Gtk.CairoChart {

	public struct Color {
		double red;
		double green;
		double blue;
		double alpha;

		public Color (double red = 0.0, double green = 0.0, double blue = 0.0, double alpha = 1.0) {
			this.red = red; this.green = green; this.blue = blue; this.alpha = alpha;
		}
	}

	public enum FontOrient {
			HORIZONTAL = 0,
			VERTICAL
		}
	public struct FontStyle {
		string family;
		FontSlant slant;
		FontWeight weight;

		FontOrient orientation;
		double size;

		public FontStyle (string family = "Sans",
		                  FontSlant slant = Cairo.FontSlant.NORMAL,
		                  FontWeight weight = Cairo.FontWeight.NORMAL,
		                  double size = 10) {
			this.family = family;
			this.slant = slant;
			this.weight = weight;
			this.size = size;
		}
	}

	public struct LineStyle {
		double width;
		LineJoin line_join;
		LineCap line_cap;
		double[]? dashes;
		double dash_offset;
		Color color;

		public LineStyle (double width = 1,
		                  LineJoin line_join = Cairo.LineJoin.MITER,
		                  LineCap line_cap = Cairo.LineCap.ROUND,
		                  double[]? dashes = null, double dash_offset = 0,
		                  Color color = Color()) {
			this.width = width;
			this.line_join = line_join;
			this.line_cap = line_cap;
			this.dashes = dashes;
			this.dash_offset = dash_offset;
			this.color = color;
		}
	}

	[Compact]
	public class Text {
		public string text = "";
		public FontStyle style = FontStyle ();
		public Color color = Color();

		TextExtents get_extents (Cairo.Context context) {
			context.select_font_face (style.family,
			                          style.slant,
			                          style.weight);
			context.set_font_size (style.size);
			TextExtents extents;
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

		public Text.by_instance (Text text) {
			this.text = text.text;
			this.style = text.style;
			this.color = text.color;
		}
	}
}
