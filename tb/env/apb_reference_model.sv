class apb_reference_model;

    mailbox #(apb_transaction) mon2rm;
    mailbox #(apb_transaction) rm2sb;


    bit [31:0] model_mem [bit [31:0]];


    function new(
        mailbox #(apb_transaction) mon2rm,
        mailbox #(apb_transaction) rm2sb
    );

        this.mon2rm = mon2rm;
        this.rm2sb  = rm2sb;

    endfunction



    function void reset_model();

        model_mem.delete();

    endfunction



    function bit [31:0] get_expected_data(
        bit [31:0] addr
    );

        if (model_mem.exists(addr))
            return model_mem[addr];

        return 32'h0000_0000;

    endfunction



    task start();

        forever begin

            apb_transaction in_t;
            apb_transaction exp_t;

            mon2rm.get(in_t);

            exp_t = in_t.clone();


            // WRITE

            if (in_t.kind == APB_WRITE) begin

                model_mem[in_t.PADDR] = in_t.PWDATA;

                exp_t.PSLVERR = 1'b0;

                $display(
                    "[REFERENCE MODEL] WRITE ADDR=0x%08h DATA=0x%08h",
                    in_t.PADDR,
                    in_t.PWDATA
                );

            end


            // READ

            else if (in_t.kind == APB_READ) begin

                exp_t.PRDATA =
                    get_expected_data(in_t.PADDR);

                exp_t.PSLVERR = 1'b0;

                $display(
                    "[REFERENCE MODEL] READ ADDR=0x%08h EXPECTED=0x%08h",
                    in_t.PADDR,
                    exp_t.PRDATA
                );

            end


            // Send prediction to scoreboard

            rm2sb.put(exp_t);

        end

    endtask

endclass
