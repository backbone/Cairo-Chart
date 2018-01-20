namespace CairoChart {

	/**
	 * Grid of the {@link Series}.
	 */
	public class Grid {

		/*public enum GridType {
			PRICK_LINE = 0, // default
			LINE
		}*/

		/**
		 * Color of the ``Grid``.
		 */
		public Color color = Color (0, 0, 0, 0.1);

		/**
		 * Line style of the ``Grid``.
		 */
		public LineStyle line_style = LineStyle ();

		/**
		 * Gets a copy of the ``Grid``.
		 */
		public virtual Grid copy () {
			var grid = new Grid ();
			grid.color = this.color;
			grid.line_style = this.line_style;
			return grid;
		}

		/**
		 * Constructs a new ``Grid``.
		 */
		public Grid () {
			line_style.dashes = {2, 3};
		}
	}
}
