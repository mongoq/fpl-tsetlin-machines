//============================================================================
// Tsetlin Machine - Simplified Verilog Implementation
//============================================================================
// Based directly on Granmo's original algorithm.
// Simplified for correctness over optimization.
//============================================================================

module tsetlin_machine #(
    parameter N_FEATURES = 4,
    parameter N_CLAUSES  = 32,
    parameter N_CLASSES  = 2,
    parameter N_STATES   = 100,
    parameter THRESHOLD  = 16
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,
    input  wire                         train_mode,
    input  wire [$clog2(N_CLASSES)-1:0] target_class,
    input  wire [N_FEATURES-1:0]        features_in,
    input  wire [15:0]                  random_in,
    output reg  [$clog2(N_CLASSES)-1:0] predicted_class,
    output reg                          done,
    output reg                          valid
);

    localparam STATE_BITS = $clog2(2*N_STATES);
    localparam N_LITERALS = 2 * N_FEATURES;
    localparam CLAUSES_PER_CLASS = N_CLAUSES / N_CLASSES;
    
    // States
    localparam [2:0] IDLE=0, EVALUATE=1, VOTE=2, TRAIN=3, DONE_ST=4;
    
    // TA states: flattened array [clause][literal]
    reg [STATE_BITS-1:0] ta [0:N_CLAUSES*N_LITERALS-1];
    
    // Registers
    reg [2:0] state;
    reg [N_FEATURES-1:0] X;           // Latched features
    reg [N_LITERALS-1:0] literals;    // [~X, X]
    reg [N_CLAUSES-1:0] clause_out;   // Clause outputs
    reg signed [15:0] vote [0:N_CLASSES-1];
    reg [15:0] lfsr;
    reg [$clog2(N_CLAUSES)-1:0] c_idx;
    reg [4:0] l_idx;
    reg train_latch;
    reg [$clog2(N_CLASSES)-1:0] target_latch;
    
    integer i, j;
    
    // Combinational clause evaluation
    reg [N_CLAUSES-1:0] clause_eval_comb;
    always @(*) begin
        for (i = 0; i < N_CLAUSES; i = i + 1) begin
            clause_eval_comb[i] = 1'b1;
            for (j = 0; j < N_LITERALS; j = j + 1) begin
                // Include literal if state >= N_STATES
                if (ta[i*N_LITERALS + j] >= N_STATES) begin
                    if (!literals[j])
                        clause_eval_comb[i] = 1'b0;
                end
            end
        end
    end
    
    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            valid <= 0;
            predicted_class <= 0;
            lfsr <= 16'hBEEF;
            c_idx <= 0;
            l_idx <= 0;
            
            // Init TAs to middle (some include, some exclude randomly)
            for (i = 0; i < N_CLAUSES*N_LITERALS; i = i + 1)
                ta[i] <= N_STATES;  // Right at threshold
                
            for (i = 0; i < N_CLASSES; i = i + 1)
                vote[i] <= 0;
                
        end else begin
            // LFSR
            lfsr <= {lfsr[14:0], lfsr[15]^lfsr[14]^lfsr[12]^lfsr[3]};
            
            case (state)
                IDLE: begin
                    done <= 0;
                    valid <= 0;
                    if (start) begin
                        X <= features_in;
                        literals <= {~features_in, features_in};
                        train_latch <= train_mode;
                        target_latch <= target_class;
                        state <= EVALUATE;
                    end
                end
                
                EVALUATE: begin
                    clause_out <= clause_eval_comb;
                    
                    // Compute votes for each class
                    for (i = 0; i < N_CLASSES; i = i + 1) begin
                        vote[i] <= 0;
                    end
                    state <= VOTE;
                end
                
                VOTE: begin
                    // Sum votes with polarity and clipping
                    for (i = 0; i < N_CLASSES; i = i + 1) begin
                        reg signed [15:0] sum;
                        sum = 0;
                        for (j = 0; j < CLAUSES_PER_CLASS; j = j + 1) begin
                            if (clause_out[i*CLAUSES_PER_CLASS + j]) begin
                                // Even j = positive, Odd j = negative
                                if (j[0] == 0) begin
                                    if (sum < THRESHOLD) sum = sum + 1;
                                end else begin
                                    if (sum > -THRESHOLD) sum = sum - 1;
                                end
                            end
                        end
                        vote[i] <= sum;
                    end
                    
                    // Simple argmax for 2 classes
                    if (N_CLASSES == 2) begin
                        // Will be valid next cycle after vote is updated
                        predicted_class <= 0;
                    end
                    
                    c_idx <= 0;
                    l_idx <= 0;
                    
                    if (train_latch)
                        state <= TRAIN;
                    else
                        state <= DONE_ST;
                end
                
                TRAIN: begin
                    // Update one TA per cycle
                    begin
                        reg [STATE_BITS-1:0] ta_state;
                        reg lit_val;
                        reg clause_val;
                        reg is_pos_polarity;
                        reg is_target;
                        reg [$clog2(N_CLASSES)-1:0] clause_class;
                        reg do_type1_reward;
                        reg do_type1_inaction;
                        reg do_type2;
                        reg [15:0] rand_val;
                        
                        ta_state = ta[c_idx*N_LITERALS + l_idx];
                        lit_val = literals[l_idx];
                        clause_val = clause_out[c_idx];
                        clause_class = c_idx / CLAUSES_PER_CLASS;
                        is_pos_polarity = ((c_idx % CLAUSES_PER_CLASS) & 1) == 0;
                        is_target = (clause_class == target_latch);
                        rand_val = lfsr ^ random_in ^ {c_idx, l_idx, 3'b0};
                        
                        do_type1_reward = 0;
                        do_type1_inaction = 0;
                        do_type2 = 0;
                        
                        // Determine feedback type based on class and polarity
                        if (is_target && is_pos_polarity) begin
                            do_type1_reward = 1;  // Reinforce for target
                        end else if (is_target && !is_pos_polarity) begin
                            do_type2 = 1;  // Type II for negative target clauses
                        end else if (!is_target && is_pos_polarity) begin
                            do_type2 = 1;  // Type II for non-target positive
                        end else begin
                            do_type1_inaction = 1;  // Inaction penalty for non-target negative
                        end
                        
                        // Apply feedback
                        if (do_type1_reward) begin
                            // Type I Feedback (Reward)
                            if (clause_val) begin
                                // Clause fires
                                if (lit_val) begin
                                    // Literal true: strengthen include (go up)
                                    if (rand_val[3:0] != 4'b0000) begin  // Prob (s-1)/s ≈ 94%
                                        if (ta_state < 2*N_STATES-1)
                                            ta[c_idx*N_LITERALS + l_idx] <= ta_state + 1;
                                    end
                                end else begin
                                    // Literal false: strengthen exclude (go down)
                                    if (rand_val[3:0] != 4'b0000) begin
                                        if (ta_state > 0)
                                            ta[c_idx*N_LITERALS + l_idx] <= ta_state - 1;
                                    end
                                end
                            end else begin
                                // Clause doesn't fire: decay toward exclude
                                if (rand_val[3:0] == 4'b0000) begin  // Prob 1/s ≈ 6%
                                    if (ta_state > 0)
                                        ta[c_idx*N_LITERALS + l_idx] <= ta_state - 1;
                                end
                            end
                        end
                        
                        if (do_type1_inaction) begin
                            // Type I with inaction (for non-target negative clauses)
                            // Only stochastic decay
                            if (rand_val[4:0] == 5'b00000) begin  // Low prob
                                if (ta_state > 0)
                                    ta[c_idx*N_LITERALS + l_idx] <= ta_state - 1;
                            end
                        end
                        
                        if (do_type2) begin
                            // Type II Feedback (make clause more specific)
                            if (clause_val && !lit_val) begin
                                // Clause fires but literal is false
                                // Include this literal to prevent clause from firing
                                if (ta_state < 2*N_STATES-1)
                                    ta[c_idx*N_LITERALS + l_idx] <= ta_state + 1;
                            end
                        end
                    end
                    
                    // Advance LFSR more
                    lfsr <= {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[11]^lfsr[2]};
                    
                    // Next literal/clause
                    if (l_idx == N_LITERALS - 1) begin
                        l_idx <= 0;
                        if (c_idx == N_CLAUSES - 1) begin
                            state <= DONE_ST;
                        end else begin
                            c_idx <= c_idx + 1;
                        end
                    end else begin
                        l_idx <= l_idx + 1;
                    end
                end
                
                DONE_ST: begin
                    // Final prediction (compare votes)
                    if (vote[1] > vote[0])
                        predicted_class <= 1;
                    else
                        predicted_class <= 0;
                    done <= 1;
                    valid <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
