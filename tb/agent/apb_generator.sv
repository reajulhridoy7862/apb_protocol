class apb_generator;

    mailbox #(apb_transaction) gen2drv;

    int unsigned num_random;

    int unsigned generated;


    function new(
        mailbox #(apb_transaction) gen2drv,
        int unsigned num_random = 100
    );

        this.gen2drv   = gen2drv;
        this.num_random = num_random;

        generated = 0;

    endfunction

    // Send transaction

    task send(apb_transaction t);

        gen2drv.put(t);

        generated++;

    endtask


    task fixed_write_test(
      input logic [31:0] address,
      input logic [31:0] data
      );

        apb_transaction t;


        $display("");
        $display("==================================================");
        $display("             FIXED WRITE TEST");
        $display("==================================================");


        // WRITE 0x20

        t = new();

        t.kind   = APB_WRITE;
        t.PWRITE = 1'b1;
        t.PADDR  = address;
        t.PWDATA = data;

        send(t);


        // READ 0x20

        t = new();

        t.kind   = APB_READ;
        t.PWRITE = 1'b0;
        t.PADDR  = address;

        send(t);

    endtask

    // Fixed read test

    task fixed_read_test(
      input logic [31:0] address,
      input logic [31:0] data
      );

        apb_transaction t;


        $display("");
        $display("==================================================");
        $display("              FIXED READ TEST");
        $display("==================================================");


        // Write known value

        t = new();

        t.kind   = APB_WRITE;
        t.PWRITE = 1'b1;
        t.PADDR  = address;
        t.PWDATA = data;

        send(t);


        // Read same address

        t = new();

        t.kind   = APB_READ;
        t.PWRITE = 1'b0;
        t.PADDR  = address;

        send(t);

    endtask


    // Invalid address test

    task invalid_address_test();

        apb_transaction t;


        $display("");
        $display("==================================================");
        $display("            INVALID ADDRESS TEST");
        $display("==================================================");


        // Invalid WRITE

        t = new();

        t.kind   = APB_WRITE;
        t.PWRITE = 1'b1;
        t.PADDR  = 32'h0000_0100;
        t.PWDATA = 32'hDEAD_BEEF;
        $display("[GENERATED] PREADY = %0b PADDR=%0h PRDATA=%0h PWRITE= %0b PWDATA=%0h PSLVERR=%0b", t.PREADY , t.PADDR, t.PRDATA, t.PWRITE, t.PWDATA, t.PSLVERR);
        send(t);


        // Invalid READ

        t = new();

        t.kind   = APB_READ;
        t.PWRITE = 1'b0;
        t.PADDR  = 32'h0000_0100;
        $display("[GENERATED] PREADY = %0b PADDR=%0h PRDATA=%0h PWRITE= %0b PWDATA=%0h PSLVERR=%0b", t.PREADY , t.PADDR, t.PRDATA, t.PWRITE, t.PWDATA, t.PSLVERR);
        send(t);

    endtask


    // Reset memory verification
    // Then read every memory location.

    task reset_memory_check();

        apb_transaction t;


        $display("");
        $display("==================================================");
        $display("          RESET MEMORY CHECK");
        $display("==================================================");


        for (
            int unsigned addr = 0;
            addr <= 32'h0000_00FC;
            addr += 4
        ) begin

            t = new();

            t.kind   = APB_READ;
            t.PWRITE = 1'b0;
            t.PADDR  = addr;

            send(t);

        end

    endtask


    // Address discovery

    task address_discovery_test();

        apb_transaction t;

        bit [31:0] data;


        $display("");
        $display("==================================================");
        $display("          ADDRESS DISCOVERY TEST");
        $display("==================================================");


        for (
            int unsigned addr = 0;
            addr <= 32'h0000_00FC;
            addr += 4
        ) begin

            data = $urandom();


            // WRITE

            t = new();

            t.kind   = APB_WRITE;
            t.PWRITE = 1'b1;
            t.PADDR  = addr;
            t.PWDATA = data;

            send(t);


            // READ BACK

            t = new();

            t.kind   = APB_READ;
            t.PWRITE = 1'b0;
            t.PADDR  = addr;

            send(t);

        end

    endtask



    task random_test();

        apb_transaction write_t;
        apb_transaction read_t;

        bit [31:0] addr;
        bit [31:0] data;


        $display("");
        $display("==================================================");
        $display("             RANDOM READ/WRITE TEST");
        $display("==================================================");


        repeat (num_random) begin

            write_t = new();


            if (!write_t.randomize()) begin

                $error("[GENERATOR] Randomization failed");

                $finish;

            end


            // Randomly choose operation

            if ($urandom_range(0,1)) begin


                write_t.kind   = APB_WRITE;
                write_t.PWRITE = 1'b1;

                addr = write_t.PADDR;
                data = write_t.PWDATA;

                send(write_t);


                read_t = new();

                read_t.kind   = APB_READ;
                read_t.PWRITE = 1'b0;
                read_t.PADDR  = addr;

                send(read_t);

            end
            else begin


                write_t.kind   = APB_READ;
                write_t.PWRITE = 1'b0;

                send(write_t);

            end

        end

    endtask

endclass
