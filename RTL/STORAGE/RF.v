module reg_file #(
    // Parameter
    parameter   DATA_WIDTH = 32,
    parameter   ADDR_WIDTH = 5
    )
    (
    // Port
    input                       clk,        
    input                       we_i,       // write enable (1'b0: read, 1'b1: write)
    input   [ADDR_WIDTH-1:0]    wa_i,       // write address
    input   [DATA_WIDTH-1:0]    wd_i,       // write data
    input   [ADDR_WIDTH-1:0]    ra_i,       // read address
    output  [DATA_WIDTH-1:0]    rd_o        // read data
    );


    // register file, ** is expenetial, (ADDR = 5 -> DEPTH = 32)
    reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0]; 

    // write when rising edge of clock
    always @(posedge clk) begin
        if (we_i) begin
            rf[wa_i] <= wd_i;
        end 
    end
    
    // read ports combiniationally
    // register 0 hardwired to 0
    assign rd_o = (ra_i != 1'b0) ? rf[ra_i] : {(DATA_WIDTH){1'b0}};

endmodule