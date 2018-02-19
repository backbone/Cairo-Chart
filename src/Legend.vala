namespace CairoChart {

	/**
	 * {@link Chart} ``Legend``.
	 */
	public class Legend {

		protected unowned Chart chart;
		protected double [] max_font_heights;

		/**
		 * Show legend?
		 */
		public bool show = true;

		/**
		 * ``Legend`` position.
		 */
		public enum Position {
			/**
			 * Top position.
			 */
			TOP = 0,

			/**
			 * Left position.
			 */
			LEFT,

			/**
			 * Right position.
			 */
			RIGHT,

			/**
			 * Bottom position.
			 */
			BOTTOM
		}

		/**
		 * Position.
		 */
		public Position position = Position.TOP;

		/**
		 * ``Legend`` background color.
		 */
		public Color bg_color = Color(1, 1, 1);

		/**
		 * Border line style.
		 */
		public LineStyle border_style = LineStyle ();

		/**
		 * Both vertical & horizontal spacing.
		 */
		public double spacing = 5;

		/**
		 * ``Legend`` width.
		 */
		public double width { get; protected set; }

		/**
		 * ``Legend`` height.
		 */
		public double height { get; protected set; }

		/**
		 * {@link Series} line length.
		 */
		public double line_length = 30;

		/**
		 * Constructs a new ``Legend``.
		 * @param chart ``Chart`` instance.
		 */
		public Legend (Chart chart) {
			this.chart = chart;
			border_style.color = Color (0, 0, 0, 0.3);
		}

		/**
		 * Gets a copy of the ``Legend``.
		 */
		public virtual Legend copy () {
			var legend = new Legend (chart);
			legend.position = this.position;
			legend.bg_color = this.bg_color;
			legend.spacing = this.spacing;
			legend.height = this.height;
			legend.line_length = this.line_length;
			legend.width = this.width;
			legend.show = this.show;
			legend.max_font_heights = this.max_font_heights;
			return legend;
		}

		/**
		 * Draws the ``Legend``.
		 */
		public virtual void draw () {
			if (!show) return;
			process (ProcessType.CALC);
			process (ProcessType.DRAW);
		}

		protected virtual void draw_rect (out double x0, out double y0) {
			x0 = y0 = 0;
			if (chart.ctx != null) {
				switch (position) {
				case Position.TOP:
					x0 = (chart.area.width - width) / 2;
					var title_height = chart.title.height + (chart.legend.position == Position.TOP ?
					                   chart.title.font.vspacing * 2 : chart.title.font.vspacing);
					y0 = title_height;
				break;

				case Position.BOTTOM:
					x0 = (chart.area.width - width) / 2;
					y0 = chart.area.height - height;
				break;

				case Position.LEFT:
					x0 = 0;
					y0 = (chart.area.height - height) / 2;
				break;

				case Position.RIGHT:
					x0 = chart.area.width - width;
					y0 = (chart.area.height - height) / 2;
				break;
				}
				chart.color = bg_color;
				chart.ctx.rectangle (x0, y0, width, height);
				chart.ctx.fill();
				border_style.apply(chart);
				chart.ctx.move_to (x0, y0);
				chart.ctx.rel_line_to (width, 0);
				chart.ctx.rel_line_to (0, height);
				chart.ctx.rel_line_to (-width, 0);
				chart.ctx.rel_line_to (0, -height);
				chart.ctx.stroke ();
			}
		}

		protected enum ProcessType {
			CALC = 0, // default
			DRAW
		}

		protected virtual void process (ProcessType process_type) {
			var legend_x0 = 0.0, legend_y0 = 0.0;
			var heights_idx = 0;
			var leg_width_sum = 0.0;
			var leg_height_sum = 0.0;
			var max_font_h = 0.0;

			double [] mfh = max_font_heights;

			// prepare
			switch (process_type) {
			case ProcessType.CALC:
				width = 0;
				height = 0;
				mfh = {};
				heights_idx = 0;
				break;
			case ProcessType.DRAW:
				draw_rect(out legend_x0, out legend_y0);
				break;
			}

			foreach (var s in chart.series) {
				if (!s.zoom_show) continue;

				// carry
				switch (position) {
				case Position.TOP:
				case Position.BOTTOM:
					var ser_title_width = line_length + s.title.width + s.title.font.hspacing * 2;
					if (leg_width_sum + ser_title_width > chart.area.width) { // carry
						leg_height_sum += max_font_h;
						switch (process_type) {
						case ProcessType.CALC:
							mfh += max_font_h;
							width = double.max(width, leg_width_sum);
							break;
						case ProcessType.DRAW:
							heights_idx++;
							break;
						}
						leg_width_sum = 0;
						max_font_h = 0;
					}
					break;
				}

				switch (process_type) {
				case ProcessType.DRAW:
					var x = legend_x0 + leg_width_sum + s.title.font.hspacing;
					var y = legend_y0 + leg_height_sum + mfh[heights_idx] / 2;

					// series title
					chart.ctx.move_to (x + line_length, y + s.title.height / 2);
					chart.color = s.title.color;
					s.title.show();

					// series line style
					chart.ctx.move_to (x, y);
					s.line_style.apply(chart);
					chart.ctx.rel_line_to (line_length, 0);
					chart.ctx.stroke();
					s.marker.draw_at_pos (Point(x + line_length / 2, y));
					break;
				}

				switch (position) {
				case Position.TOP:
				case Position.BOTTOM:
					var ser_title_width = line_length + s.title.width + s.title.font.hspacing * 2;
					leg_width_sum += ser_title_width;
					max_font_h = double.max (max_font_h, s.title.height + s.title.font.vspacing * 2);
				break;

				case Position.LEFT:
				case Position.RIGHT:
					switch (process_type) {
					case ProcessType.CALC:
						mfh += s.title.height + s.title.font.vspacing * 2;
						width = double.max (width, s.title.font.hspacing * 2 + line_length + s.title.width);
						break;
					case ProcessType.DRAW:
						heights_idx++;
						break;
					}
					leg_height_sum += s.title.height + s.title.font.vspacing * 2;
				break;
				}
			}

			// TOP, BOTTOM
			switch (position) {
			case Position.TOP:
			case Position.BOTTOM:
				if (leg_width_sum != 0) {
					leg_height_sum += max_font_h;
					switch (process_type) {
						case ProcessType.CALC:
							mfh += max_font_h;
							width = double.max(width, leg_width_sum);
							break;
					}
				}
				break;
			}

			switch (process_type) {
			case ProcessType.CALC:
				height = leg_height_sum;
				switch (position) {
					case Position.TOP: chart.evarea.y0 += height + spacing; break;
					case Position.BOTTOM: chart.evarea.y1 -= height + spacing; break;
					case Position.LEFT: chart.evarea.x0 += width + spacing; break;
					case Position.RIGHT: chart.evarea.x1 -= width + spacing; break;
				}
				break;
			}

			max_font_heights = mfh;
		}
	}
}
