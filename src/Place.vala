namespace Gtk.CairoChart {
	public struct Place {
		double x_low;
		double x_high;
		double y_low;
		double y_high;

		public Place (double x_low = 0, double x_high = 0, double y_low = 0, double y_high = 0) {
			this.x_low = x_low;
			this.x_high = x_high;
			this.y_low = y_low;
			this.y_high = y_high;
		}
	}
}
