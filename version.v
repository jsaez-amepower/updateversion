module version (
	output wire [23:0] version_out,
	output wire [39:0] commit_out,
	output wire [31:0] version_upper32,
	output wire [31:0] version_lower32
);

// v0.0.
// Major: 0
// Minor: 0
// Patch: 0
// Build: 0
// Branch: main

// version_out = (VERSION_MAJOR << 20 | VERSION_MINOR << 14 | VERSION_PATCH << 8 | VERSION_BUILD)
localparam [23:0] CONST_VERSION_OUT = 24'h0;
localparam [39:0] CONST_COMMIT_OUT = 40'h0;

// Continuous assignments for wire outputs
assign version_out = CONST_VERSION_OUT;
assign commit_out = CONST_COMMIT_OUT;

// Make version_upper32 to be: lower 8 bits from commit_out and version_out
assign version_upper32 = {CONST_VERSION_OUT[23:0], CONST_COMMIT_OUT[39:32]};

// version_lower32: upper 32 bits of commit_out
assign version_lower32 = CONST_COMMIT_OUT[31:0];

endmodule
