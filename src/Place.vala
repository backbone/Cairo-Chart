namespace CairoChart {
	public class Place {
		double _x_min = 0;
		double _x_max = 0;
		double _y_min = 0;
		double _y_max = 0;
		public double x_min {
			get { return _x_min; }
			set { _x_min = zoom_x_min = value; }
			default = 0;
		}
		public double x_max {
			get { return _x_max; }
			set { _x_max = zoom_x_max = value; }
			default = 0;
		}
		public double y_min {
			get { return _y_min; }
			set { _y_min = zoom_y_min = value; }
			default = 0;
		}
		public double y_max {
			get { return _y_max; }
			set { _y_max = zoom_y_max = value; }
			default = 0;
		}
		public double zoom_x_min = 0;
		public double zoom_x_max = 1;
		public double zoom_y_min = 0;
		public double zoom_y_max = 1;

		public virtual Place copy () {
			var place = new Place ();
			place.x_min = this.x_min;
			place.x_max = this.x_max;
			place.y_min = this.y_min;
			place.y_max = this.y_max;
			return place;
		}

		public Place (double x_min = 0,
		              double x_max = 1, double y_min = 0, double y_max = 1) {
			this.x_min = x_min;
			this.x_max = x_max;
			this.y_min = y_min;
			this.y_max = y_max;
			zoom_x_min = x_min;
			zoom_x_max = x_max;
			zoom_y_min = y_min;
			zoom_y_max = y_max;
		}

		public virtual void unzoom () {
			zoom_x_min = x_min;
			zoom_x_max = x_max;
			zoom_y_min = y_min;
			zoom_y_max = y_max;
		}
	}
}
