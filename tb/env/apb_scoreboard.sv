class apb_scoreboard;

    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) rm2sb;



    bit [31:0] write_history [bit [31:0]];


    // Statistics

    int unsigned total;
    int unsigned passed;
    int unsigned failed;

    int unsigned write_verified;
    int unsigned write_failed;

    int unsigned read_verified;
    int unsigned read_failed;


    function new(
        mailbox #(apb_transaction) mon2sb,
        mailbox #(apb_transaction) rm2sb
    );

        this.mon2sb = mon2sb;
        this.rm2sb  = rm2sb;

        total = 0;
        passed = 0;
        failed = 0;

        write_verified = 0;
        write_failed   = 0;

        read_verified = 0;
        read_failed   = 0;

    endfunction


    // Reset scoreboard state

    function void reset_history();

        write_history.delete();

    endfunction


    // Main scoreboard

    task start();

        forever begin

            apb_transaction actual;
            apb_transaction expected;

            // Get actual and expected transactions

            mon2sb.get(actual);
            rm2sb.get(expected);

            total++;


            // PREADY check

            if (actual.PREADY !== expected.PREADY) begin

                $display(
                    "[SCOREBOARD][FAIL] ID=%0d PREADY mismatch ACTUAL=%0b EXPECTED=%0b",
                    actual.id,
                    actual.PREADY,
                    expected.PREADY
                );

                failed++;

                continue;

            end


            // PSLVERR check

            if (actual.PSLVERR !== expected.PSLVERR) begin

                $display(
                    "[SCOREBOARD][FAIL] ID=%0d ADDR=0x%08h PSLVERR mismatch ACTUAL=%0b EXPECTED=%0b",
                    actual.id,
                    actual.PADDR,
                    actual.PSLVERR,
                    expected.PSLVERR
                );

                failed++;

                continue;

            end


            // WRITE

            if (actual.kind == APB_WRITE) begin

                write_history[actual.PADDR] = actual.PWDATA;

                $display(
                    "[SCOREBOARD] WRITE ACCEPTED ADDR=0x%08h DATA=0x%08h",
                    actual.PADDR,
                    actual.PWDATA
                );


                passed++;

                continue;

            end

            // READ

            if (actual.kind == APB_READ) begin

                // First compare with reference model

                if (actual.PRDATA !== expected.PRDATA) begin

                    $display("");
                    $display("==================================================");
                    $display("[SCOREBOARD][READ FAIL]");
                    $display("Transaction ID : %0d", actual.id);
                    $display("Address        : 0x%08h", actual.PADDR);
                    $display("Expected       : 0x%08h", expected.PRDATA);
                    $display("Actual         : 0x%08h", actual.PRDATA);
                    $display("==================================================");
                    $display("");

                    read_failed++;
                    failed++;

                    continue;

                end


                // Now verify previous write, if one exists

                if (write_history.exists(actual.PADDR)) begin

                    if (actual.PRDATA !==
                        write_history[actual.PADDR]) begin

                        $display("");
                        $display("==================================================");
                        $display("[SCOREBOARD][WRITE VERIFICATION FAIL]");
                        $display("Transaction ID : %0d", actual.id);
                        $display("Address        : 0x%08h", actual.PADDR);
                        $display("Written value  : 0x%08h",
                                 write_history[actual.PADDR]);
                        $display("Read value     : 0x%08h",
                                 actual.PRDATA);
                        $display("==================================================");
                        $display("");

                        write_failed++;
                        failed++;

                        continue;

                    end
                    else begin

                        write_verified++;

                        $display(
                            "[SCOREBOARD][WRITE VERIFIED] ADDR=0x%08h WRITE=0x%08h READ=0x%08h",
                            actual.PADDR,
                            write_history[actual.PADDR],
                            actual.PRDATA
                        );

                    end

                end


                // Read verification successful

                read_verified++;

                $display(
                    "[SCOREBOARD][READ PASS] ADDR=0x%08h DATA=0x%08h",
                    actual.PADDR,
                    actual.PRDATA
                );

                passed++;

            end

        end

    endtask


    // Report

    function void report();

        $display("");
        $display("==================================================");
        $display("              APB TEST REPORT");
        $display("==================================================");

        $display("Total transactions = %0d", total);
        $display("Passed transactions = %0d", passed);
        $display("Failed transactions = %0d", failed);

        $display("");

        $display("Write verified = %0d", write_verified);
        $display("Write failed   = %0d", write_failed);

        $display("");

        $display("Read verified = %0d", read_verified);
        $display("Read failed   = %0d", read_failed);

        $display("");

        if (failed == 0)
            $display("RESULT = TEST PASSED");
        else
            $display("RESULT = TEST FAILED");

        $display("==================================================");
        $display("");

    endfunction

endclass
