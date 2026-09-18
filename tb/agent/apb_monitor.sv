class apb_monitor;

    virtual apb_if vif;

    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) mon2rm;


    function new(
        virtual apb_if vif,
        mailbox #(apb_transaction) mon2sb,
        mailbox #(apb_transaction) mon2rm
    );

        this.vif    = vif;
        this.mon2sb = mon2sb;
        this.mon2rm = mon2rm;

    endfunction


    task start();

        forever begin

            apb_transaction t;


            // Look for SETUP phase

            @(posedge vif.PCLK);


            if (!(vif.PRESETn &&
                  vif.PSEL1   &&
                 !vif.PENABLE))
                continue;


            // Capture transaction

            t = new();

            t.PWRITE = vif.PWRITE;
            t.PADDR  = vif.PADDR;
            t.PWDATA = vif.PWDATA;


            if (vif.PWRITE)
                t.kind = APB_WRITE;
            else
                t.kind = APB_READ;

            // Wait for ACCESS completion

            forever begin

                @(posedge vif.PCLK);

                if (vif.PSEL1 &&
                    vif.PENABLE &&
                    vif.PREADY)
                    break;

            end


            // Capture response

            t.PREADY  = vif.PREADY;
            t.PRDATA  = vif.PRDATA;
            t.PSLVERR = vif.PSLVERR;


            t.print("MONITOR");


            // Send independent copies

            mon2sb.put(t.clone());

            mon2rm.put(t.clone());

        end

    endtask

endclass
