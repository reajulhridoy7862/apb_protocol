class base_test;

    virtual apb_if vif;
    apb_environment env;

    function new(
        virtual apb_if vif,
        int unsigned num_random = 100
    );

        this.vif = vif;

        env = new(
            vif,
            num_random
        );

    endfunction
    // Child test implementation

    virtual task run_test();

        $display("[BASE TEST] No test implementation");

    endtask

    task run();

        int unsigned expected_transactions;
        // Start environment

        env.start();

        env.reset();

        run_test();

        expected_transactions = env.gen.generated;

        wait (
            env.sb.total == expected_transactions
        );

        env.sb.report();

    endtask

endclass
