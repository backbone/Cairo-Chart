namespace Gtk.CairoChart {
	public class Place {
		double _x_low = 0;
		double _x_high = 0;
		double _y_low = 0;
		double _y_high = 0;
		public double x_low {
			get { return _x_low; }
			set { _x_low = zoom_x_low = value; }
			default = 0;
		}
		public double x_high {
			get { return _x_high; }
			set { _x_high = zoom_x_high = value; }
			default = 0;
		}
		public double y_low {
			get { return _y_low; }
			set { _y_low = zoom_y_low = value; }
			default = 0;
		}
		public double y_high {
			get { return _y_high; }
			set { _y_high = zoom_y_high = value; }
			default = 0;
		}
		public double zoom_x_low = 0;
		public double zoom_x_high = 1;
		public double zoom_y_low = 0;
		public double zoom_y_high = 1;

		public Place copy () {
			var place = new Place ();
			place.x_low = this.x_low;
			place.x_high = this.x_high;
			place.y_low = this.y_low;
			place.y_high = this.y_high;
			return place;
		}

		public Place (double x_low = 0, double x_high = 1, double y_low = 0, double y_high = 1) {
			this.x_low = x_low;
			this.x_high = x_high;
			this.y_low = y_low;
			this.y_high = y_high;
			zoom_x_low = x_low;
			zoom_x_high = x_high;
			zoom_y_low = y_low;
			zoom_y_high = y_high;
		}
	}
}
