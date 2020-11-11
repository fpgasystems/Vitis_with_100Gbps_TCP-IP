`include "network_intf.svh"
`include "network_types.svh"

module axis_meta_reg #(
	parameter WIDTH = 32
) (
	input wire  			aclk,
	input wire  			aresetn,
	
	axis_meta.slave 		meta_in,
	axis_meta.master 		meta_out
);

if(WIDTH == 56) begin
	axis_register_slice_meta_56_0 inst_reg_slice (
		.aclk(aclk),
		.aresetn(aresetn),
		.s_axis_tvalid(meta_in.valid),
		.s_axis_tready(meta_in.ready),
		.s_axis_tdata(meta_in.data),
		.m_axis_tvalid(meta_out.valid),
		.m_axis_tready(meta_out.ready),
		.m_axis_tdata(meta_out.data)
	);
end
else if(WIDTH == 32) begin
	axis_register_slice_meta_32_0 inst_reg_slice (
		.aclk(aclk),
		.aresetn(aresetn),
		.s_axis_tvalid(meta_in.valid),
		.s_axis_tready(meta_in.ready),
		.s_axis_tdata(meta_in.data),
		.m_axis_tvalid(meta_out.valid),
		.m_axis_tready(meta_out.ready),
		.m_axis_tdata(meta_out.data)
	);
end

endmodule