interface apb_if(input logic PCLK);

    logic        PRESETn;
    logic        PSEL1;
    logic        PENABLE;
    logic        PWRITE;

    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;

    logic        PREADY;
    logic        PSLVERR;

endinterface
