/* Read memory, dump to UART on trigger */
`timescale 1 ns / 1 ps

`default_nettype none
`define WIDTH 16

module top(input clk,

           output TXD,        // UART TX
           input RXD,         // UART RX

           input resetq
);
    localparam MHZ = 12;

    // ######   UART   ##########################################
    //
    wire uart0_valid, uart0_busy;
    wire [7:0] uart0_data_in;
    wire [7:0] uart0_data_out;
    wire uart0_wr;
    wire uart0_rd;
    wire [31:0] uart_baud = 115200;
    reg uart0_reset = 1'b0;
    buart #(.CLKFREQ(MHZ * 1000000)) _uart0 (
     .clk(clk),
     .resetq(uart0_reset),
     .baud(uart_baud),
     .rx(RXD),
     .tx(TXD),
     .rd(uart0_rd),
     .wr(uart0_wr),
     .valid(uart0_valid),
     .busy(uart0_busy),
     .tx_data(uart0_data_out),
     .rx_data(uart0_data_in));

    // ######   ROM   ##########################################
    //
    wire [15:0] rom_rd;
    wire [7:0] rom_rdb;
    wire [8:0] rom_raddr; // 512x8
    SB_RAM40_4KNRNW #(
        .WRITE_MODE(1), // 8 bit
        .READ_MODE(1),  // 8 bit
        .INIT_0(256'h0000000000400105005501400044504015400014008828bb28a028b028362895),
        .INIT_1(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_2(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_3(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_4(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_5(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_6(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_7(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_8(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_9(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_A(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_B(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_C(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_D(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_E(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_F(256'h0000000000000000000000000000000000000000000000000000000000000000)
    ) _rom (
        .RDATA(rom_rd),
        .RADDR({2'b00, rom_raddr}),
        .RCLKN(clk), .RCLKE(1'b1), .RE(1'b1),
        .WCLKN(1'b0), .WCLKE(1'b0), .WE(1'b0),
        .WADDR(11'h0),
        .MASK(16'h0000), .WDATA(16'h0));
    assign rom_rdb = {rom_rd[14],rom_rd[12],rom_rd[10],rom_rd[8],rom_rd[6],rom_rd[4],rom_rd[2],rom_rd[0]}; // read byte

    // ######   CPU   ##########################################
    //
    // States
    localparam S_IDLE     =3'b000,
               S_OP       =3'b001,
               S_IMM8     =3'b010,
               S_UART_WAIT=3'b011,
               S_UART_END =3'b100,
               S_MEM_LOAD =3'b101;

    reg [8:0] ptr;
    wire [8:0] ptr_plus_one = ptr + 9'h1;
    assign rom_raddr = ptr;
    reg [8:0] ptr_saved;
    reg [7:0] outb;
    reg outf;
    reg [2:0] state;
    reg [7:0] opcode;
    reg [7:0] cpuregs [3:0];

    always @(posedge clk) begin
        case (state)
            S_IDLE: begin
                // "a" to start
                if (uart0_valid && uart0_data_in == "a") begin
                    ptr <= 9'h0;
                    state <= S_OP;
                end
            end
            S_OP: begin
                opcode <= rom_rdb;
                ptr <= ptr_plus_one;
                casez (rom_rdb)
                    8'b00000001, // 0x01 JUMP
                    8'b000001zz, // 0x04-0x07 MOV IMM r0-r3
                    8'b000100zz: begin // 0x10-0x13 JNZ
                        state <= S_IMM8;
                    end
                    8'b000010zz: begin // 0x08-0x0B SEND r0-r3
                        state <= S_UART_WAIT;
                        outb <= cpuregs[rom_rdb[1:0]];
                    end
                    // ALU (single reg)
                    8'b000011zz: begin // 0x0C-0x0F DEC r0-r3
                        cpuregs[rom_rdb[1:0]] <= cpuregs[rom_rdb[1:0]] - 8'h1;
                    end
                    8'b000110zz: begin // 0x18-0x1B INC r0-r3
                        cpuregs[rom_rdb[1:0]] <= cpuregs[rom_rdb[1:0]] + 8'h1;
                    end
                    // ALU (dual reg)
                    8'b1000zzzz: begin // 0x80-0x8F ADD rx, ry
                        cpuregs[rom_rdb[3:2]] <= cpuregs[rom_rdb[3:2]] + cpuregs[rom_rdb[1:0]];
                    end
                    // Load from memory (page 2)
                    8'b1100zzzz: begin // 0xC0-0xCF LD rx,[{ry+1,ry}]
                        state <= S_MEM_LOAD;
                        ptr_saved <= ptr_plus_one;
                        ptr <= {1'b1, cpuregs[{rom_rdb[1],1'b0}]}; // wrong
                        //ptr <= {1'b1, cpuregs[rom_rdb[1]<<1]};   // wrong
                        //ptr <= {1'b1, cpuregs[rom_rdb&2'h2]};    // wrong
                        //ptr <= {1'b1, cpuregs[rom_rdb[1:0]]};    // ok
                    end
                    default: begin // Invalid instruction, back to IDLE state
                        state <= S_IDLE;
                    end
                endcase
            end
            S_IMM8: begin
                ptr <= ptr_plus_one;
                state <= S_OP;
                casez (opcode)
                    8'b00000001: begin // JUMP
                        ptr <= rom_rdb;
                    end
                    8'b000100zz: begin // 0x10-0x13 JNZ
                        if (|cpuregs[opcode[1:0]]) begin
                            ptr <= rom_rdb;
                        end
                    end
                    8'b000001zz: begin // MOV IMM
                        cpuregs[opcode[1:0]] <= rom_rdb;
                    end
                endcase
            end
            S_UART_WAIT: begin
                if (!uart0_busy) begin // Send byte when UART ready
                    state <= S_UART_END;
                    outf <= 1;
                end
            end
            S_UART_END: begin // Clear outf flag after sending to UART
                outf <= 0;
                state <= S_OP;
            end
            S_MEM_LOAD: begin // Load from memory
                cpuregs[opcode[3:2]] <= rom_rdb;
                ptr <= ptr_saved;
                state <= S_OP;
            end
        endcase
        // Reset logic
        if (!uart0_reset) begin // Reset UART only for one clock
            uart0_reset <= 1;
            state <= S_IDLE;
        end
    end

    assign uart0_wr = outf;
    assign uart0_rd = (state == S_IDLE);
    assign uart0_data_out = outb;

endmodule // top
