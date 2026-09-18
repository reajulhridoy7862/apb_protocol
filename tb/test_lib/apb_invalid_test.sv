class invalid_test extends base_test;


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
        $display("               INVALID ADDRESS TEST");
        $display("==================================================");

        env.gen.invalid_address_test();

    endtask

endclass
