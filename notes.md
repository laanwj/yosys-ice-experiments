A few important notes regarding developing Verilog for this target.

Initialisation of values
---------------------------

Initializers such as reg `foo = 0;` and initial blocks both work with yosys, but the iCE40 architecture does not support initialization values for the registers, so whatever initialization value you set is being ignored. But all registers in the iCE40 are set to 0 when the bitstream is fed into the device, so you can ignore the warning for everything that you want to initialize to zero anyways (Page 5 of the iCE40 LP/HX Family Data Sheet says: "Each DFF also connects to a global reset signal that is automatically asserted immediately following device configuration.")

You can use explicit reset logic: The tools and the architecture both support synchronous and asynchronous reset. But as a general rule for HDL design I would recommend synchronous reset over asynchronous reset for various reasons.

Yes, you can also use the fact that registers are initialized to zero to generate a reset pulse. I usually do something like the following (only 5 LCs big and generates a 16 cycles long reset pulse):

    reg [3:0] reset_cnt = 0;
    wire resetn = &reset_cnt;
    always @(posedge clk)
      if (!resetn) reset_cnt <= reset_cnt + 1;

That being said: In many applications the clock isn't stable when the device is programmed and thus it is possible that the state of the circuit gets corrupted shortly after power on. So you either want to gate the clock and only let it through to your logic once it has been stabilized, or -- especially if you are already using a PLL -- use the LOCK output of the PLL as inverted reset signal for your design.

However, `reg foo;` and `reg foo = 0;` do not always yield the same result! If you need the register to be zero initialized, you have to tell the tools! Otherwise the initial value is assumed to be undefined, which allows yosys to perform more optimizations. Two examples:

(1) If you are using retiming in your flow (run `synth_ice40` with `-retime`), then yosys will possibly move any register that does not have an init value assigned. For example, when a register is moved to the other side of an inverter, then the effective initialization value of that register changes from 0 to 1.

(2) Consider the following code for a simple reset generator:

    reg resetn = 0;
    always @(posedge clk)
      resetn <= 1;

This will work. However, it won't work if you remove the initialization value like this:

    reg resetn;
    always @(posedge clk)
      resetn <= 1;

According to the language definition, the `resetn` register now starts out as undefined and can only be set to 1. Thus the tool may remove the register altogether and simply replace `resetn` with a constant 1.

I can only further underline the importance of simulation, as simulation correctly initializes non-initialized registers with the special undefined `x` state and lets you see the difference between zero-initialized and uninitialized FFs. If you only test in hardware, you can have situations where (maybe depending on unrelated changes in the design) the synthesis tool sometimes takes an optimization that break the zero-initialized FF assumption and sometime it does not. You'll never find a bug like this in a complex design without a simulation that correctly models the x state.

(Thanks Clifford Wolf and Cotton Seed)


