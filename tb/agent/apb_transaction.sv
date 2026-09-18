typedef enum bit [1:0] {
    APB_WRITE,
    APB_READ,
    APB_RESET
} apb_kind_e;


class apb_transaction;

    static int unsigned next_id = 0;

    int unsigned id;

    apb_kind_e kind;

    rand bit        PWRITE;
    rand bit [31:0] PADDR;
    rand bit [31:0] PWDATA;

    bit [31:0] PRDATA;
    bit        PREADY;
    bit        PSLVERR;

    int unsigned wait_cycles;


    //--------------------------------------------------------
    // Valid APB SRAM addresses
    //
    // 64 words
    // 32-bit data
    // 4 bytes/word
    //
    // 0x00000000 -> 0x000000FC
    //--------------------------------------------------------

    constraint c_valid_address {

        PADDR inside {
            [32'h0000_0000 : 32'h0000_00FC]
        };

        PADDR[1:0] == 2'b00;
    }


    constraint c_data {

        PWDATA inside {
            [32'h0000_0000 : 32'hFFFF_FFFF]
        };

    }


    function new();

        id = next_id++;

        PWRITE     = 1'b0;
        PADDR      = 32'h0;
        PWDATA     = 32'h0;

        PRDATA     = 32'h0;
        PREADY     = 1'b0;
        PSLVERR    = 1'b0;

        wait_cycles = 0;

    endfunction


    function void set_kind();

        if (PWRITE)
            kind = APB_WRITE;
        else
            kind = APB_READ;

    endfunction


    function apb_transaction clone();

        apb_transaction t;

        t = new();

        t.id          = this.id;
        t.kind        = this.kind;

        t.PWRITE      = this.PWRITE;
        t.PADDR       = this.PADDR;
        t.PWDATA      = this.PWDATA;

        t.PRDATA      = this.PRDATA;
        t.PREADY      = this.PREADY;
        t.PSLVERR     = this.PSLVERR;

        t.wait_cycles = this.wait_cycles;

        return t;

    endfunction


    function void print(string tag = "TRANSACTION");

        $display("--------------------------------------------------");
        $display("[%s]", tag);
        $display("ID          = %0d", id);
        $display("KIND        = %s", kind.name());
        $display("PADDR       = 0x%08h", PADDR);
        $display("PWDATA      = 0x%08h", PWDATA);
        $display("PRDATA      = 0x%08h", PRDATA);
        $display("PREADY      = %0b", PREADY);
        $display("PSLVERR     = %0b", PSLVERR);
        $display("WAIT_CYCLES = %0d", wait_cycles);
        $display("--------------------------------------------------");

    endfunction

endclass
