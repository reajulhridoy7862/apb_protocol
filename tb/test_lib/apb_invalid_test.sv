class invalid_test extends base_test;


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
        $display("               INVALID ADDRESS TEST");
        $display("==================================================");

        env.gen.invalid_address_test();

    endtask

endclass
