class apb_driver;

    virtual apb_if vif;

    mailbox #(apb_transaction) gen2drv;

    mailbox #(bit) reset_done;


    function new(
        virtual apb_if vif,
        mailbox #(apb_transaction) gen2drv,
        mailbox #(bit) reset_done
    );

        this.vif       = vif;
        this.gen2drv   = gen2drv;
        this.reset_done = reset_done;

    endfunction

    // Initialize APB signals

    task initialize();

        vif.PRESETn <= 1'b1;
        vif.PSEL1   <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= 32'h0;
        vif.PWDATA  <= 32'h0;

    endtask

    // Reset

    task reset_phase();

        $display("");
        $display("==================================================");
        $display("                 DRIVER RESET");
        $display("==================================================");


        // Make bus idle

        @(posedge vif.PCLK);

        vif.PSEL1   <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= 32'h0;
        vif.PWDATA  <= 32'h0;

        // Assert reset
        vif.PRESETn <= 1'b0;

        $display(
            "[%0t] [DRIVER] RESET ASSERTED",
            $time
        );


        // Keep reset active for 3 clock cycles

        repeat (3) begin

            @(posedge vif.PCLK);

            $display(
                "[%0t] [DRIVER] RESET ACTIVE",
                $time
            );

        end


        // Release reset

        vif.PRESETn <= 1'b1;

        $display(
            "[%0t] [DRIVER] RESET RELEASED",
            $time
        );

        // One clock edge after release
        @(posedge vif.PCLK);
        
        // Tell environment reset is complete

        reset_done.put(1'b1);

    endtask

    // Write transfer

    task write_transfer(apb_transaction t);

        t.wait_cycles = 0;


        // SETUP PHASE

        @(posedge vif.PCLK);

        vif.PRESETn <= 1'b1;
        vif.PSEL1   <= 1'b1;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b1;
        vif.PADDR   <= t.PADDR;
        vif.PWDATA  <= t.PWDATA;


        // ACCESS PHASE

        @(posedge vif.PCLK);

        vif.PENABLE <= 1'b1;


        // Wait for PREADY

        forever begin

            @(posedge vif.PCLK);

            if (vif.PREADY)
                break;

            t.wait_cycles++;

        end


        // Capture response

        //t.PREADY  = vif.PREADY;
        //t.PSLVERR = vif.PSLVERR;

        // IDLE

        vif.PSEL1   <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= 32'h0;
        vif.PWDATA  <= 32'h0;

    endtask


    // Read transfer

    task read_transfer(apb_transaction t);

        t.wait_cycles = 0;


        // SETUP PHASE

        @(posedge vif.PCLK);

        vif.PRESETn <= 1'b1;
        vif.PSEL1   <= 1'b1;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= t.PADDR;
        vif.PWDATA  <= 32'h0;


        // ACCESS PHASE

        @(posedge vif.PCLK);

        vif.PENABLE <= 1'b1;


        // Wait for PREADY

        forever begin

            @(posedge vif.PCLK);

            if (vif.PREADY)
                break;

            t.wait_cycles++;

        end


        // Capture read data

        //t.PRDATA  = vif.PRDATA;
        //t.PREADY  = vif.PREADY;
        //t.PSLVERR = vif.PSLVERR;


        // IDLE

        vif.PSEL1   <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PADDR   <= 32'h0;
        vif.PWDATA  <= 32'h0;

    endtask


    // Drive transaction

    task drive(apb_transaction t);

        case (t.kind)

            APB_RESET:
                reset_phase();

            APB_WRITE:
                write_transfer(t);

            APB_READ:
                read_transfer(t);

            default:
                $error("[DRIVER] Unknown transaction kind");

        endcase

    endtask


    // Driver main process

    task start();

        initialize();

        forever begin

            apb_transaction t;

            gen2drv.get(t);

            drive(t);

        end

    endtask

endclass
