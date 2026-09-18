class write_test extends base_test;


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
        $display("                 WRITE TEST");
        $display("==================================================");

        env.gen.fixed_write_test(
          32'h0000_0020,
          32'hA5A5_1234);

    endtask

endclass
