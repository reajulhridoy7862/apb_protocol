
//`timescale 1ns/1ps


module tb_top;

    import apb_agent_pkg::*;
    import apb_env_pkg::*;
    import apb_test_pkg::*;


    logic PCLK;

    initial begin

        PCLK = 1'b0;

        forever
            #5 PCLK = ~PCLK;

    end

    // APB INTERFACE

    apb_if vif(PCLK);

    // TEST SELECTION

    string test_name;

    int unsigned num_random;

    // DUT
    apb_v3_sram #(
        .ADDR_BUS_WIDTH     (32),
        .DATA_BUS_WIDTH     (32),
        .MEMSIZE            (64),
        .MEM_BLOCK_SIZE     (8),
        .RESET_VAL          (0),
        .EN_WAIT_DELAY_FUNC(1),
        .MIN_RAND_WAIT_CYC (1),
        .MAX_RAND_WAIT_CYC (1) 
    ) dut (

        .PRESETn(vif.PRESETn),
        .PCLK   (PCLK),
        .PSEL   (vif.PSEL1),
        .PENABLE(vif.PENABLE),
        .PWRITE (vif.PWRITE),
        .PADDR  (vif.PADDR),
        .PWDATA (vif.PWDATA),

        .PRDATA (vif.PRDATA),
        .PREADY (vif.PREADY),
        .PSLVERR(vif.PSLVERR)

    );
    // TEST

    base_test test;

    reset_test     reset_t;
    write_test     write_t;
    read_test      read_t;
    invalid_test   invalid_t;
    discovery_test discovery_t;
    random_test    random_t;
    all_test       all_t;

    initial begin

      if (!$value$plusargs("TEST=%s", test_name))
        test_name = "ALL";

      if (!$value$plusargs("NUM_RANDOM=%d", num_random))
        num_random = 100;

      case (test_name)

        "RESET": begin
            reset_t = new(vif);
            test = reset_t;
        end

        "WRITE": begin
            write_t = new(vif);
            test = write_t;
        end

        "READ": begin
            read_t = new(vif);
            test = read_t;
        end

        "INVALID": begin
            invalid_t = new(vif);
            test = invalid_t;
        end

        "DISCOVERY": begin
            discovery_t = new(vif);
            test = discovery_t;
        end

        "RANDOM": begin
            random_t = new(vif, num_random);
            test = random_t;
        end

        "ALL": begin
            all_t = new(vif, num_random);
            test = all_t;
        end

        default: begin
            $display("ERROR: Unknown TEST=%s", test_name);
            $finish;
        end

    endcase

    test.run();

    $finish;

  end


endmodule


