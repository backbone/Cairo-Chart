namespace CairoChart {

	/**
	 * ``Font`` style.
	 */
	[Compact]
	public class Font : Object {

		/**
		 * A font family name, encoded in UTF-8.
		 */
		public virtual string family { get; set; }

		/**
		 * The new font size, in user space units.
		 */
		public virtual double size { get; set; }

		/**
		 * The slant for the font.
		 */
		public virtual Cairo.FontSlant slant { get; set; }

		/**
		 * The weight for the font.
		 */
		public virtual Cairo.FontWeight weight { get; set; }

		/**
		 * Font/Text orientation.
		 */
		public virtual Gtk.Orientation orient { get; set; }

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
		public virtual double spacing {
			protected get {
				return 0;
			}
			set {
				vspacing = hspacing = value;
			}
			default = 4;
		}

		/**
		 * Constructs a new ``Font``.
		 * @param family a font family name, encoded in UTF-8.
		 * @param size the new font size, in user space units.
		 * @param slant the slant for the font.
		 * @param weight the weight for the font.
		 * @param orient font/text orientation.
		 */
		public Font (string family = "Sans",
		             double size = 10,
		             Cairo.FontSlant slant = Cairo.FontSlant.NORMAL,
		             Cairo.FontWeight weight = Cairo.FontWeight.NORMAL,
		             Gtk.Orientation orient = Gtk.Orientation.HORIZONTAL,
		             double vspacing = 4,
		             double hspacing = 4
		) {
			this.family = family;
			this.size = size;
			this.slant = slant;
			this.weight = weight;
			this.orient = orient;
		}

		/**
		 * Gets a copy of the ``Font``.
		 */
		public virtual Font copy () {
			var f = new Font(family, size, slant, weight, orient);
			f.vspacing = vspacing;
			f.hspacing = hspacing;
			return f;
		}
	}
}
