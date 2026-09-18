class all_test extends base_test;


    function new(
        virtual apb_if vif,
        int unsigned num_random = 100
    );

        super.new(
            vif,
            num_random
        );

    endfunction


    task run_test();

        $display("");
        $display("==================================================");
        $display("                  ALL TEST");
        $display("==================================================");


        //----------------------------------------------------
        // Do NOT reset here.
        //
        // base_test already performed reset.
        //----------------------------------------------------

        env.gen.fixed_write_test(
        32'h0000_0020,
        32'hA5A5_1234
        );

        env.gen.fixed_read_test(
           32'h0000_0030,
           32'hA5A5_1234);

        env.gen.invalid_address_test();

        env.gen.address_discovery_test();

        env.gen.random_test();

    endtask

endclass
