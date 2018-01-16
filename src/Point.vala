namespace CairoChart {
	public struct Point {
		double x;
		double y;

		public Point (double x = 0.0, double y = 0.0) {
			this.x = x; this.y = y;
		}
	}
	public struct Point128 {
		Float128 x;
		Float128 y;

		public Point128 (Float128 x = 0.0, Float128 y = 0.0) {
			this.x = x; this.y = y;
		}
	}
}
