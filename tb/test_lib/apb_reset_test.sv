class reset_test extends base_test;


    function new(
        virtual apb_if vif
    );

        super.new(
            vif
        );

    endfunction


    task run_test();

        $display("");
        $display("==================================================");
        $display("                 RESET TEST");
        $display("==================================================");

        // Check all memory locations
        env.gen.reset_memory_check();

    endtask

endclass
