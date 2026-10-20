module mult_array(clk, rst_n, a, b, p);
input clk;
input rst_n;
input [3:0] a;
input [3:0] b;
output reg [7:0] p;

reg [3:0] a_reg, b_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a_reg <= 4'b0;
        b_reg <= 4'b0;
    end else begin
        a_reg <= a;
        b_reg <= b;
    end
end

wire [3:0] pp0, pp1, pp2, pp3;
assign pp0 = a_reg & {4{b_reg[0]}};
assign pp1 = a_reg & {4{b_reg[1]}};
assign pp2 = a_reg & {4{b_reg[2]}};
assign pp3 = a_reg & {4{b_reg[3]}};

wire [3:0] r0, r1, r2;
wire [4:1] c1, c2, c3;
wire [3:0] s1, s2, s3;

assign r0 = {1'b0, pp0[3], pp0[2], pp0[1]};

// row1
full_adder fa1_0 (.a(pp1[0]), .b(r0[0]), .cin(1'b0),   .sum(s1[0]), .cout(c1[1]));
full_adder fa1_1 (.a(pp1[1]), .b(r0[1]), .cin(c1[1]), .sum(s1[1]), .cout(c1[2]));
full_adder fa1_2 (.a(pp1[2]), .b(r0[2]), .cin(c1[2]), .sum(s1[2]), .cout(c1[3]));
full_adder fa1_3 (.a(pp1[3]), .b(r0[3]), .cin(c1[3]), .sum(s1[3]), .cout(c1[4]));

assign r1 = {c1[4], s1[3], s1[2], s1[1]};

// row2
full_adder fa2_0 (.a(pp2[0]), .b(r1[0]), .cin(1'b0),   .sum(s2[0]), .cout(c2[1]));
full_adder fa2_1 (.a(pp2[1]), .b(r1[1]), .cin(c2[1]), .sum(s2[1]), .cout(c2[2]));
full_adder fa2_2 (.a(pp2[2]), .b(r1[2]), .cin(c2[2]), .sum(s2[2]), .cout(c2[3]));
full_adder fa2_3 (.a(pp2[3]), .b(r1[3]), .cin(c2[3]), .sum(s2[3]), .cout(c2[4]));

assign r2 = {c2[4], s2[3], s2[2], s2[1]};

// row3
full_adder fa3_0 (.a(pp3[0]), .b(r2[0]), .cin(1'b0),   .sum(s3[0]), .cout(c3[1]));
full_adder fa3_1 (.a(pp3[1]), .b(r2[1]), .cin(c3[1]), .sum(s3[1]), .cout(c3[2]));
full_adder fa3_2 (.a(pp3[2]), .b(r2[2]), .cin(c3[2]), .sum(s3[2]), .cout(c3[3]));
full_adder fa3_3 (.a(pp3[3]), .b(r2[3]), .cin(c3[3]), .sum(s3[3]), .cout(c3[4]));


wire [7:0] p_next;
assign p_next[0]     = pp0[0];
assign p_next[1]     = s1[0];
assign p_next[2]     = s2[0];
assign p_next[3]     = s3[0];
assign p_next[7:4]   = {c3[4], s3[3], s3[2], s3[1]};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p <= 8'b0;
    end else begin
        p <= p_next;
    end
end

endmodule