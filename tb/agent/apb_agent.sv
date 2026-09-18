class apb_agent;

    virtual apb_if vif;


    //--------------------------------------------------------
    // Mailboxes
    //--------------------------------------------------------

    mailbox #(apb_transaction) gen2drv;

    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) mon2rm;

    mailbox #(bit) reset_done;


    //--------------------------------------------------------
    // Components
    //--------------------------------------------------------

    apb_driver  drv;
    apb_monitor mon;


    function new(virtual apb_if vif);

        this.vif = vif;


        //----------------------------------------------------
        // Mailboxes
        //----------------------------------------------------

        gen2drv   = new();

        mon2sb    = new();
        mon2rm    = new();

        reset_done = new();


        //----------------------------------------------------
        // Components
        //----------------------------------------------------

        drv = new(
            vif,
            gen2drv,
            reset_done
        );

        mon = new(
            vif,
            mon2sb,
            mon2rm
        );

    endfunction


    //--------------------------------------------------------
    // Start agent
    //--------------------------------------------------------

    task start();

        fork

            drv.start();

            mon.start();

        join_none

    endtask

endclass
