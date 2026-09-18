class discovery_test extends base_test;


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
        $display("              ADDRESS DISCOVERY TEST");
        $display("==================================================");

        env.gen.address_discovery_test();

    endtask

endclass
