namespace CairoChart {

	/**
	 * Value of the point.
	 */
	public class Label {

		/**
		 * ``Label`` Style.
		 */
		public struct Style {

			/**
			 * Font style.
			 */
			Font.Style font_style;

			/**
			 * Frame line style.
			 */
			Line.Style frame_line_style;

			/**
			 * Background color.
			 */
			Color bg_color;

			/**
			 * Frame/border color.
			 */
			Color frame_color;
		}

		private Label () { }
	}
}
