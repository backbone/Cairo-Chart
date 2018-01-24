namespace CairoChart {

	/**
	 * ``LabelStyle`` Style.
	 */
	public class LabelStyle {

		/**
		 * Background color.
		 */
		public Color bg_color;

		/**
		 * Frame line style.
		 */
		public LineStyle frame_style;

		/**
		 * Font style.
		 */
		public Font font;

		/**
		 * Constructs a new ``LabelStyle``.
		 * @param font font style.
		 * @param bg_color background color.
		 * @param frame_style frame line style.
		 */
		public LabelStyle (
			Color bg_color = Color(1, 1, 1, 1),
			LineStyle frame_style = LineStyle(Color(0, 0, 0, 0.1)),
			Font font = new Font()
		) {
			this.bg_color = bg_color;
			this.frame_style = frame_style;
			this.font = font;
		}

		/**
		 * Gets a copy of the ``LabelStyle``.
		 */
		public virtual LabelStyle copy () {
			return new LabelStyle(bg_color, frame_style, font);
		}
	}
}
