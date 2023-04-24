`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module REG_FILE_TB #(
    // Parameter
    parameter   DATA_WIDTH = 32,
    parameter   ADDR_WIDTH = 5
    )
    (
    // no inout
    // this is testbench
    );
    
    // Port
    reg                       CLK;        
    reg                       WE;       // write enable (1'b0: read, 1'b1: write)
    reg   [ADDR_WIDTH-1:0]    WA;       // write address
    reg   [DATA_WIDTH-1:0]    WD;       // write data
    reg   [ADDR_WIDTH-1:0]    RA;       // read address
    wire  [DATA_WIDTH-1:0]    RD;       // read data


    REG_FILE #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        // Port
        .clk    (CLK),
        .we_i   (WE),
        .wa_i   (WA),
        .wd_i   (WD),
        .ra_i   (RA),
        .rd_o   (RD)
    );


    // clock signal
    initial begin
        CLK = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) CLK = ~CLK;
        end
    end


    // monitor func
    initial begin 
        $monitor("Write_En = %b, Write_Addr = %b, Write_DATA = %b, Read_Addr = %b, Read_Data = %b",
                    WE, WA, WD, RA, RD);
    end
    
    // test stimulus
    initial begin
        WE = 1'b0;
        WA = {(ADDR_WIDTH){1'b0}};
        WD = {(DATA_WIDTH){1'b0}};
        RA = {(ADDR_WIDTH){1'b0}};
        
        $display("Write1");
        @(posedge CLK);
        #(`DELTA)
            WE = 1'b1;
            WA = 'd1;
            WD = 'd1;
        
        $display("Write2");
        @(posedge CLK);
            WA = 'd2;
            WD = 'd2;

        $display("Write3");
        @(posedge CLK);
            WA = 'd3;
            WD = 'd3;
            
        $display("Write4");
        @(posedge CLK);
            WA = 'd4;
            WD = 'd4;
        
        $display("Read1");
        @(posedge CLK);
            WE = 1'b0;
            RA = 'd1;
            
        $display("Read2");
        @(posedge CLK);
            RA = 'd2;

        $display("Read3");
        @(posedge CLK);
            RA = 'd3;

        $display("Read4");
        @(posedge CLK);
            RA = 'd4;
            
        @(posedge CLK);

        $display("finished testbench");
        $finish;
    end

endmodule