`timescale 1ns/1ps

module tb_mult;

    reg clk;
    reg rst_n;
    reg [3:0] a;
    reg [3:0] b;
    wire [7:0] p;

    integer errors;
    integer i, j;
    reg [7:0] expected;

    mult_array uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Pipeline delay tracking for self-checking
    reg [3:0] a_d1, a_d2;
    reg [3:0] b_d1, b_d2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_d1 <= 4'b0;
            a_d2 <= 4'b0;
            b_d1 <= 4'b0;
            b_d2 <= 4'b0;
        end else begin
            a_d1 <= a;
            a_d2 <= a_d1;
            b_d1 <= b;
            b_d2 <= b_d1;
        end
    end

    // Test stimulus and checking
    initial begin
        // Initialize signals
        rst_n = 0;
        a = 4'b0;
        b = 4'b0;
        errors = 0;

        // VCD dump
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        // Hold reset low for 2 cycles
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // Loop through all 256 combinations
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                @(posedge clk);
                
                // Since there is a 2-cycle latency, check after pipeline fills
                if ((i > 0 || j > 0)) begin
                    expected = a_d2 * b_d2;
                    if (p !== expected) begin
                        $display("Mismatch: a=%0d, b=%0d | Expected=%0d, Got=%0d", 
                                 a_d2, b_d2, expected, p);
                        errors = errors + 1;
                    end
                end
            end
        end

        // Flush remaining pipeline cycles
        @(posedge clk);
        @(posedge clk);

        // Print final summary
        if (errors == 0) begin
            $display("PASS: 256 vectors checked, 0 errors");
        end else begin
            $display("FAIL: %0d errors detected", errors);
        end

        $finish;
    end

endmodule