namespace CairoChart {

	public class Math {

		public virtual Float128 calc_round_step (Float128 aver_step, bool date_time = false) {
			Float128 step = 1.0;

			if (aver_step > 1.0) {
				if (date_time) while (step < aver_step) step *= 60;
				if (date_time) while (step < aver_step) step *= 60;
				if (date_time) while (step < aver_step) step *= 24;
				while (step < aver_step) step *= 10;
				if (step / 5 > aver_step) step /= 5;
				while (step / 2 > aver_step) step /= 2;
			} else if (aver_step > 0) {
				while (step / 10 > aver_step) step /= 10;
				if (step / 5 > aver_step) step /= 5;
				while (step / 2 > aver_step) step /= 2;
			}

			return step;
		}

		public virtual bool are_intersect (double a_min, double a_max, double b_min, double b_max) {
			if (   a_min < a_max <= b_min < b_max
			    || b_min < b_max <= a_min < a_max)
				return false;
			return true;
		}

		public virtual bool point_belong (Float128 p, Float128 a, Float128 b) {
			if (a > b) { Float128 tmp = a; a = b; b = tmp; }
			if (a <= p <= b) return true;
			return false;
		}

		public virtual bool x_in_range (double x, double x0, double x1) {
			if (x0 <= x <= x1 || x1 <= x <= x0)
				return true;
			return false;
		}

		public virtual bool y_in_range (double y, double y0, double y1) {
			if (y0 <= y <= y1 || y1 <= y <= y0)
				return true;
			return false;
		}

		public virtual bool point_in_rect (Point p, double x0, double x1, double y0, double y1) {
			if (x_in_range(p.x, x0, x1) && y_in_range(p.y, y0, y1))
				return true;
			return false;
		}

		public virtual bool hcross (Point a1, Point a2, Float128 h_x1, Float128 h_x2, Float128 h_y, out Float128 x) {
			x = 0;
			if (a1.y == a2.y) return false;
			if (a1.y >= h_y && a2.y >= h_y || a1.y <= h_y && a2.y <= h_y) return false;
			x = a1.x + (a2.x - a1.x) * (h_y - a1.y) / (a2.y - a1.y);
			if (h_x1 <= x <= h_x2 || h_x2 <= x <= h_x1)
				return true;
			return false;
		}

		public virtual bool vcross (Point a1, Point a2, Float128 v_x, Float128 v_y1, Float128 v_y2, out Float128 y) {
			y = 0;
			if (a1.x == a2.x) return false;
			if (a1.x >= v_x && a2.x >= v_x || a1.x <= v_x && a2.x <= v_x) return false;
			y = a1.y + (a2.y - a1.y) * (v_x - a1.x) / (a2.x - a1.x);
			if (v_y1 <= y <= v_y2 || v_y2 <= y <= v_y1)
				return true;
			return false;
		}


		public Math () {}
	}
}
