namespace CairoChart {

	/**
	 * 128-bit float type.
	 */
	[CCode (cname = "cairo_chart_float128", has_type_id = false, cheader_filename = "cairo-chart-float128type-0.h")]
	public struct Float128 : double {}

	/**
	 * Long Double float type.
	 */
	[CCode (cname = "cairo_chart_long_double", has_type_id = false, cheader_filename = "cairo-chart-float128type-0.h")]
	public struct LongDouble : double {}
}
