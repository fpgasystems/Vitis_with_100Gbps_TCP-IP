`include "network_types.svh"
`include "network_intf.svh"

module axis_data_reg_array #(
    parameter integer                       N_STAGES = 2
) (
    input  wire                             aclk,
    input  wire                             aresetn,
    axi_stream.slave                        s_axis,
    axi_stream.master                       m_axis
);

// ----------------------------------------------------------------------------------------------------------------------- 
// -- Register slices ---------------------------------------------------------------------------------------------------- 
// ----------------------------------------------------------------------------------------------------------------------- 
axi_stream axis_int [N_STAGES+1] ();

always_comb begin
    axis_int[0].valid           = s_axis.valid;
    axis_int[0].data            = s_axis.data;
    axis_int[0].keep            = s_axis.keep;
    axis_int[0].last            = s_axis.last;
    s_axis.ready                = axis_int[0].ready;

    m_axis.valid                = axis_int[N_STAGES].valid;
    m_axis.data                 = axis_int[N_STAGES].data;
    m_axis.keep                 = axis_int[N_STAGES].keep;
    m_axis.last                 = axis_int[N_STAGES].last;
    axis_int[N_STAGES].ready    = m_axis.ready;
end

for(genvar i = 0; i < N_STAGES; i++) begin
    axis_data_reg inst_reg (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_int[i]), .m_axis(axis_int[i+1]));  
end

endmodule