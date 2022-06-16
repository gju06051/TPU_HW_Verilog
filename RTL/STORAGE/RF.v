module reg_file #(
    // parameter
    parameter   DATA_WIDTH = 32,
    parameter   DATA_DEPTH = 32,
    parameter   ADDR_WIDTH = $clog2(DATA_DEPTH)     // ex) DATA_DEPTH = 32, ADDR_WIDTH = 5
    )
    (
    // port
    input                       we,                 // write enable
    input   [ADDR_WIDTH-1:0]    ra1, ra2,           // read address
    input   [ADDR_WIDTH-1:0]    wa,                 // write address
    input   [DATA_WIDTH-1:0]    wd,                 // write data
    output  [DATA_WIDTH-1:0]    rd1, rd2, rd3       // read data
    );

    // wire & reg
    reg     [DATA_DEPTH-1:0]  rf [DATA_WIDTH:0];

    // write third port on rising edge of clock
    always @(posedge clk) begin
        if (we) begin
            rf[wa] <= wd;
        end
    end
    
    // register 0 hardwired to 0
    // read ports combiniationally(show ahead)
    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
    assign rd3 = (ra3 != 0) ? rf[ra3] : 0;

endmodule