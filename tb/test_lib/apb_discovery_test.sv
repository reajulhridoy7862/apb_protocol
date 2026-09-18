class discovery_test extends base_test;


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
        $display("              ADDRESS DISCOVERY TEST");
        $display("==================================================");

        env.gen.address_discovery_test();

    endtask

endclass
