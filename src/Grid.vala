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
		 * Line style of the ``Grid``.
		 */
		public LineStyle style = LineStyle ();

		/**
		 * Gets a copy of the ``Grid``.
		 */
		public virtual Grid copy () {
			var grid = new Grid ();
			grid.style = this.style;
			return grid;
		}

		/**
		 * Constructs a new ``Grid``.
		 */
		public Grid () {
			style.dashes = {2, 3};
		}
	}
}
