//============================================================================
// Tsetlin Machine Testbench - Simplified
//============================================================================

`timescale 1ns / 1ps

module tsetlin_machine_tb;

    // Parameters - tuned for XOR
    //parameter N_FEATURES = 2;    // Only 2 bits for XOR
    parameter N_FEATURES = 3;    // 3 bits for majority of 3
    parameter N_CLAUSES  = 20;   // 10 per class
    parameter N_CLASSES  = 2;
    parameter N_STATES   = 100;
    parameter THRESHOLD  = 10;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk, rst_n, start, train_mode;
    reg [$clog2(N_CLASSES)-1:0] target_class;
    reg [N_FEATURES-1:0] features_in;
    reg [15:0] random_in;
    wire [$clog2(N_CLASSES)-1:0] predicted_class;
    wire done, valid;

    // Test data

    //reg [N_FEATURES-1:0] xor_x [0:3];
    //reg xor_y [0:3];

    // Added test data - Majority of three
    // y = 1 if at least two of the three bits are 1
    // y = (a & b) | (a & c) | (b & c)

    reg [N_FEATURES-1:0] x3maj_x [0:7];
    reg x3maj_y [0:7];

    integer epoch, i, correct;
    reg [31:0] seed;

    // DUT
    tsetlin_machine #(
        .N_FEATURES(N_FEATURES),
        .N_CLAUSES(N_CLAUSES),
        .N_CLASSES(N_CLASSES),
        .N_STATES(N_STATES),
        .THRESHOLD(THRESHOLD)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .train_mode(train_mode),
        .target_class(target_class),
        .features_in(features_in),
        .random_in(random_in),
        .predicted_class(predicted_class),
        .done(done),
        .valid(valid)
    );

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Random
    always @(posedge clk) begin
        seed <= seed * 1103515245 + 12345;
        random_in <= seed[15:0];
    end

    // Init test data
    // initial begin
    //     xor_x[0] = 2'b00; xor_y[0] = 0;
    //     xor_x[1] = 2'b01; xor_y[1] = 1;
    //     xor_x[2] = 2'b10; xor_y[2] = 1;
    //     xor_x[3] = 2'b11; xor_y[3] = 0;
    // end

    // Added test data
    initial begin
        x3maj_x[0] = 3'b000; x3maj_y[0] = 0;
        x3maj_x[1] = 3'b001; x3maj_y[1] = 0;
        x3maj_x[2] = 3'b010; x3maj_y[2] = 0;
        x3maj_x[3] = 3'b011; x3maj_y[3] = 1;
        x3maj_x[4] = 3'b100; x3maj_y[4] = 0;
        x3maj_x[5] = 3'b101; x3maj_y[5] = 1;
        x3maj_x[6] = 3'b110; x3maj_y[6] = 1;
        x3maj_x[7] = 3'b111; x3maj_y[7] = 1;
    end

    // Wait for done
    task wait_done;
        begin
            @(posedge clk);
            while (!done) @(posedge clk);
            @(posedge clk);
        end
    endtask

    // Inference
    task do_inference;
        input [N_FEATURES-1:0] x;
        begin
            @(posedge clk);
            features_in <= x;
            train_mode <= 0;
            target_class <= 0;
            start <= 1;
            @(posedge clk);
            start <= 0;
            wait_done();
        end
    endtask

    // Training
    task do_train;
        input [N_FEATURES-1:0] x;
        input y;
        begin
            @(posedge clk);
            features_in <= x;
            train_mode <= 1;
            target_class <= y;
            start <= 1;
            @(posedge clk);
            start <= 0;
            wait_done();
        end
    endtask

    // Test accuracy
    task test_accuracy;
        output integer acc;
        begin
            acc = 0;
            for (i = 0; i < $size(x3maj_x); i = i + 1) begin
                do_inference(x3maj_x[i]);
                if (predicted_class == x3maj_y[i])
                    acc = acc + 1;
            end
        end
    endtask

    // Main
    initial begin
        $display("==============================================");
        $display("Tsetlin Machine Majority Of Three Test");
        $display("Features=%0d Clauses=%0d States=%0d", N_FEATURES, N_CLAUSES, N_STATES);
        $display("==============================================");

        rst_n = 0;
        start = 0;
        train_mode = 0;
        features_in = 0;
        target_class = 0;
        seed = 32'h12345678;
        random_in = 16'hABCD;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Initial test
        $display("\n[Before Training]");
        test_accuracy(correct);
        $display("Accuracy: %0d/8", correct);

        // Training
        $display("\n[Training]");
        for (epoch = 1; epoch <= 2000; epoch = epoch + 1) begin
            // Train on all 8 samples each epoch (random order)
            for (i = 0; i < $size(x3maj_x); i = i + 1) begin
                do_train(x3maj_x[(i + epoch) % $size(x3maj_x)], x3maj_y[(i + epoch) % $size(x3maj_x)]);
            end

            if (epoch % 200 == 0) begin
                test_accuracy(correct);
                $display("Epoch %4d: %0d/8 (%0d%%)", epoch, correct, (correct*100)/8);
                if (correct == 8) begin
                    $display("*** 100%% reached! ***");
                end
            end
        end

        // Final test
        $display("\n[Final Results]");
        for (i = 0; i < $size(x3maj_x); i = i + 1) begin
            do_inference(x3maj_x[i]);
            $display("  %b 3maj %b 3maj %b = %0d (expected %0d) %s", x3maj_x[i][2],
                     x3maj_x[i][1], x3maj_x[i][0], predicted_class, x3maj_y[i],
                     (predicted_class == x3maj_y[i]) ? "OK" : "FAIL");
        end

        test_accuracy(correct);
        //$display("\nFinal Accuracy: %0d/8 (%0d%%)", correct, correct*25);
        $display("\nFinal Accuracy: %0d/8 (%0d%%)", correct, (correct*100)/8);

        $display("\n==============================================");
        $finish;
    end

    // Waveform
    initial begin
        $dumpfile("tm.vcd");
        $dumpvars(0, tsetlin_machine_tb);
    end

    // Timeout
    initial begin
        #500000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
