module TRI_BUF #(
    parameter DATA_WIDTH = 64
    )
    (
    // port
    input   con,    
    input   [DATA_WIDTH-1:0] in,
    output  [DATA_WIDTH-1:0] out
);
    // dataflow of tri state bus
    assign out = con ? in : {(DATA_WIDTH){1'bz}};

endmodule