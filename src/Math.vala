namespace CairoChart {

	namespace Math {

		internal Float128 calc_round_step (Float128 aver_step, bool date_time = false) {
			Float128 step = 1;

			if (aver_step > 1) {
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

		internal bool coord_cross (double a_min, double a_max, double b_min, double b_max) {
			if (   a_min < a_max <= b_min < b_max
			    || b_min < b_max <= a_min < a_max)
				return false;
			return true;
		}

		/*internal bool rect_cross (Cairo.Rectangle r1, Cairo.Rectangle r2) {
			return    coord_cross(r1.x, r1.x + r1.width, r2.x, r2.x + r2.width)
			       && coord_cross(r1.y, r1.y + r1.height, r2.y, r2.y + r2.height);
		}*/

		internal bool point_belong (Float128 p, Float128 a, Float128 b) {
			if (a > b) { Float128 tmp = a; a = b; b = tmp; }
			if (a <= p <= b) return true;
			return false;
		}

		internal bool x_in_range (double x, double x0, double x1) {
			if (x0 <= x <= x1 || x1 <= x <= x0)
				return true;
			return false;
		}

		internal bool y_in_range (double y, double y0, double y1) {
			if (y0 <= y <= y1 || y1 <= y <= y0)
				return true;
			return false;
		}

		internal bool point_in_rect (Point p, double x0, double x1, double y0, double y1) {
			if (x_in_range(p.x, x0, x1) && y_in_range(p.y, y0, y1))
				return true;
			return false;
		}

		internal bool hcross (Point a1, Point a2, double h_x1, double h_x2, double h_y, out double x) {
			x = 0;
			if (a1.y == a2.y) return false;
			if (a1.y >= h_y && a2.y >= h_y || a1.y <= h_y && a2.y <= h_y) return false;
			x = a1.x + (a2.x - a1.x) * (h_y - a1.y) / (a2.y - a1.y);
			if (h_x1 <= x <= h_x2 || h_x2 <= x <= h_x1)
				return true;
			return false;
		}

		internal bool vcross (Point a1, Point a2, double v_x, double v_y1, double v_y2, out double y) {
			y = 0;
			if (a1.x == a2.x) return false;
			if (a1.x >= v_x && a2.x >= v_x || a1.x <= v_x && a2.x <= v_x) return false;
			y = a1.y + (a2.y - a1.y) * (v_x - a1.x) / (a2.x - a1.x);
			if (v_y1 <= y <= v_y2 || v_y2 <= y <= v_y1)
				return true;
			return false;
		}

		internal delegate int PointComparator(Point128 a, Point128 b);

		internal void sort_points_delegate(Point128[] points, PointComparator compare) {
			for(var i = 0; i < points.length; ++i) {
				for(var j = i + 1; j < points.length; ++j) {
					if(compare(points[i], points[j]) > 0) {
						var tmp = points[i];
						points[i] = points[j];
						points[j] = tmp;
					}
				}
			}
		}

		internal bool cut_line (Point p_min, Point p_max, Point a, Point b, out Point c, out Point d) {
			int ncross = 0;
			Float128 x = 0, y = 0;
			Point pc[4];
			if (hcross(a, b, p_min.x, p_max.x, p_min.y, out x))
				pc[ncross++] = Point(x, p_min.y);
			if (hcross(a, b, p_min.x, p_max.x, p_max.y, out x))
				pc[ncross++] = Point(x, p_max.y);
			if (vcross(a, b, p_min.x, p_min.y, p_max.y, out y))
				pc[ncross++] = Point(p_min.x, y);
			if (vcross(a, b, p_max.x, p_min.y, p_max.y, out y))
				pc[ncross++] = Point(p_max.x, y);
			c = a;
			d = b;
			if (ncross == 0) {
				if (   point_in_rect (a, p_min.x, p_max.x, p_min.y, p_max.y)
				    && point_in_rect (b, p_min.x, p_max.x, p_min.y, p_max.y))
					return true;
				return false;
			}
			if (ncross >= 2) {
				c = pc[0]; d = pc[1];
				return true;
			}
			if (ncross == 1) {
				if (point_in_rect (a, p_min.x, p_max.x, p_min.y, p_max.y)) {
					c = a;
					d = pc[0];
					return true;
				} else if (point_in_rect (b, p_min.x, p_max.x, p_min.y, p_max.y)) {
					c = b;
					d = pc[0];
					return true;
				}
			}
			return false;
		}

		internal Point128[] sort_points (Series s, Series.Sort sort) {
			var points = s.points;
			switch(sort) {
			case Series.Sort.BY_X:
				sort_points_delegate(points, (a, b) => {
				    if (a.x < b.x) return -1;
				    if (a.x > b.x) return 1;
				    return 0;
				});
				break;
			case Series.Sort.BY_Y:
				sort_points_delegate(points, (a, b) => {
				    if (a.y < b.y) return -1;
				    if (a.y > b.y) return 1;
				    return 0;
				});
				break;
			}
			return points;
		}

		internal int find_arr<G> (G[] arr, G elem) {
			for (var i = 0; i < arr.length; ++i) {
				if (arr[i] == elem)
					return i;
			}
			return -1;
		}
	}
}
