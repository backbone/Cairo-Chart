namespace CairoChart {

	public class Legend {

		public enum Position {
			TOP = 0,	// default
			LEFT,
			RIGHT,
			BOTTOM
		}

		public Position position = Position.TOP;
		public Font.Style font_style = Font.Style();
		public Color bg_color = Color(1, 1, 1);
		public Line.Style border_style = Line.Style ();
		public double indent = 5;
		public double width = 0;
		public double height = 0;
		public double line_length = 30.0;
		public double text_hspace = 10.0;
		public double text_vspace = 2.0;
		public bool show = true;

		public virtual Legend copy () {
			var legend = new Legend ();
			legend.position = this.position;
			legend.font_style = this.font_style;
			legend.bg_color = this.bg_color;
			legend.indent = this.indent;
			legend.height = this.height;
			legend.line_length = this.line_length;
			legend.text_hspace = this.text_hspace;
			legend.text_vspace = this.text_vspace;
			legend.width = this.width;
			legend.show = this.show;
			legend.max_font_heights = this.max_font_heights;
			return legend;
		}

		public Legend () {
			border_style.color = Color (0, 0, 0, 0.3);
		}

		public virtual void draw (Chart chart) {
			process (chart, ProcessType.CALC);
			process (chart, ProcessType.DRAW);
		}

		public virtual void draw_rect (Chart chart, out double x0, out double y0) {
			x0 = y0 = 0.0;
			if (chart.ctx != null) {
				switch (position) {
				case Position.TOP:
					x0 = (chart.pos.width - width) / 2;
					y0 = chart.title_height;
				break;

				case Position.BOTTOM:
					x0 = (chart.pos.width - width) / 2;
					y0 = chart.pos.height - height;
				break;

				case Position.LEFT:
					x0 = 0;
					y0 = (chart.pos.height - height) / 2;
				break;

				case Position.RIGHT:
					x0 = chart.pos.width - width;
					y0 = (chart.pos.height - height) / 2;
				break;
				}
				chart.color = bg_color;
				chart.ctx.rectangle (x0, y0, width, height);
				chart.ctx.fill();
				border_style.set(chart);
				chart.ctx.move_to (x0, y0);
				chart.ctx.rel_line_to (width, 0);
				chart.ctx.rel_line_to (0, height);
				chart.ctx.rel_line_to (-width, 0);
				chart.ctx.rel_line_to (0, -height);
				chart.ctx.stroke ();
			}
		}

		public enum ProcessType {
			CALC = 0, // default
			DRAW
		}

		double [] max_font_heights;
		public virtual void process (Chart chart, ProcessType process_type) {
			var legend_x0 = 0.0, legend_y0 = 0.0;
			var heights_idx = 0;
			var leg_width_sum = 0.0;
			var leg_height_sum = 0.0;
			double max_font_h = 0.0;

			// prepare
			switch (process_type) {
			case ProcessType.CALC:
				width = 0.0;
				height = 0.0;
				max_font_heights = {};
				heights_idx = 0;
				break;
			case ProcessType.DRAW:
				draw_rect(chart, out legend_x0, out legend_y0);
				break;
			}

			foreach (var s in chart.series) {

				if (!s.zoom_show) continue;

				var title_sz = s.title.get_size(chart.ctx);

				// carry
				switch (position) {
				case Position.TOP:
				case Position.BOTTOM:
					var ser_title_width = title_sz.width + line_length;
					if (leg_width_sum + (leg_width_sum == 0 ? 0 : text_hspace) + ser_title_width > chart.pos.width) { // carry
						leg_height_sum += max_font_h;
						switch (process_type) {
						case ProcessType.CALC:
							max_font_heights += max_font_h;
							width = double.max(width, leg_width_sum);
							break;
						case ProcessType.DRAW:
							heights_idx++;
							break;
						}
						leg_width_sum = 0.0;
						max_font_h = 0;
					}
					break;
				}

				switch (process_type) {
				case ProcessType.DRAW:
					var x = legend_x0 + leg_width_sum + (leg_width_sum == 0.0 ? 0.0 : text_hspace);
					var y = legend_y0 + leg_height_sum + max_font_heights[heights_idx];

					// series title
					chart.ctx.move_to (x + line_length, y);
					chart.color = s.title.color;
					s.title.show(chart.ctx);

					// series line style
					chart.ctx.move_to (x, y - title_sz.height / 2);
					s.line_style.set(chart);
					chart.ctx.rel_line_to (line_length, 0);
					chart.ctx.stroke();
					s.marker.draw_at_pos (chart, x + line_length / 2, y - title_sz.height / 2);
					break;
				}

				switch (position) {
				case Position.TOP:
				case Position.BOTTOM:
					var ser_title_width = title_sz.width + line_length;
					leg_width_sum += (leg_width_sum == 0 ? 0 : text_hspace) + ser_title_width;
					max_font_h = double.max (max_font_h, title_sz.height) + (leg_height_sum != 0 ? text_vspace : 0);
				break;

				case Position.LEFT:
				case Position.RIGHT:
					switch (process_type) {
					case ProcessType.CALC:
						max_font_heights += title_sz.height + (leg_height_sum != 0 ? text_vspace : 0);
						width = double.max (width, title_sz.width + line_length);
						break;
					case ProcessType.DRAW:
						heights_idx++;
						break;
					}
					leg_height_sum += title_sz.height + (leg_height_sum != 0 ? text_vspace : 0);
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
							max_font_heights += max_font_h;
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
					case Position.TOP:
						chart.calc_pos.y += height;
						chart.calc_pos.height -= height;
						break;
					case Position.BOTTOM:
						chart.calc_pos.height -= height;
						break;
					case Position.LEFT:
						chart.calc_pos.x += width;
						chart.calc_pos.width -= width;
						break;
					case Position.RIGHT:
						chart.calc_pos.width -= width;
						break;
				}
				break;
			}
		}
	}
}
