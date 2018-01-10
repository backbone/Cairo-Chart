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

		public bool are_intersect (double a_min, double a_max, double b_min, double b_max) {
			if (   a_min < a_max <= b_min < b_max
			    || b_min < b_max <= a_min < a_max)
				return false;
			return true;
		}

		public bool point_belong (Float128 p, Float128 a, Float128 b) {
			if (a > b) { Float128 tmp = a; a = b; b = tmp; }
			if (a <= p <= b) return true;
			return false;
		}

		public Math () {}
	}
}
