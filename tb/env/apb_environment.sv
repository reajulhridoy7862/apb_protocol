class apb_environment;

    virtual apb_if vif;


    //--------------------------------------------------------
    // Components
    //--------------------------------------------------------

    apb_generator       gen;
    apb_agent           agent;
    apb_reference_model rm;
    apb_scoreboard      sb;


    //--------------------------------------------------------
    // Mailboxes
    //--------------------------------------------------------

    mailbox #(apb_transaction) gen2drv;

    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) mon2rm;

    mailbox #(apb_transaction) rm2sb;


    mailbox #(bit) reset_done;


    //--------------------------------------------------------
    // Constructor
    //--------------------------------------------------------

    function new(
        virtual apb_if vif,
        int unsigned num_random = 100
    );

        this.vif = vif;


        //----------------------------------------------------
        // Get mailboxes from agent
        //----------------------------------------------------

        agent = new(vif);

        gen2drv = agent.gen2drv;

        mon2sb  = agent.mon2sb;
        mon2rm  = agent.mon2rm;

        reset_done = agent.reset_done;


        //----------------------------------------------------
        // Create generator
        //----------------------------------------------------

        gen = new(
            gen2drv,
            num_random
        );


        //----------------------------------------------------
        // Reference model
        //----------------------------------------------------

        rm2sb = new();

        rm = new(
            mon2rm,
            rm2sb
        );


        //----------------------------------------------------
        // Scoreboard
        //----------------------------------------------------

        sb = new(
            mon2sb,
            rm2sb
        );

    endfunction


    //--------------------------------------------------------
    // Start environment
    //--------------------------------------------------------

    task start();

        agent.start();

        fork

            rm.start();

            sb.start();

        join_none

    endtask


    //--------------------------------------------------------
    // Reset DUT
    //--------------------------------------------------------

    task reset();

        apb_transaction t;
        bit reset_status;

        t = new();

        t.kind = APB_RESET;

        gen2drv.put(t);


        //----------------------------------------------------
        // Wait for driver to complete reset
        //----------------------------------------------------

        //reset_done.get();
        reset_done.get(reset_status);


        //----------------------------------------------------
        // Reset reference model and scoreboard
        //----------------------------------------------------

        rm.reset_model();

        sb.reset_history();


        $display(
            "[ENVIRONMENT] Reset completed"
        );

    endtask

endclass
