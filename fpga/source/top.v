module top (
	    input clk,
	    input RXD,
	    output TXD,
	    inout LED0,
	    inout LED1,
	    inout LED2,
	    inout LED3,
	    inout LED4,
	    inout LED5,
	    inout LED6,
	    inout LED7,
	    inout PORTB0,
	    inout PORTB1,
	    inout PORTB2,
	    inout PORTB3,
	    inout PORTB4,
	    inout PORTB5,
	    inout PORTB6,
	    inout PORTB7,
	    output CDCLK,
	    );

   localparam REFCLK_FREQ = 11289600;
   localparam CDCLK_FREQ = 33868800;
   localparam CPU_FREQ = 22579200;

   wire clkout, lock, lock_cdclk;

   generate
      if(REFCLK_FREQ != CPU_FREQ) begin : use_clkgen

	 clkgen #(.INCLOCK_FREQ(REFCLK_FREQ),
		  .OUTCLOCK_FREQ(CPU_FREQ))
	 clkgen_inst(.clkin(clk), .clkout(clkout), .lock(lock));

      end
      else begin : use_refclk

	 assign clkout = clk;
	 assign lock = 1'b1;

      end
   endgenerate

   clkgen #(.INCLOCK_FREQ(REFCLK_FREQ),
	    .OUTCLOCK_FREQ(CDCLK_FREQ))
   clkgen_cdclk_inst(.clkin(clk), .clkout(CDCLK), .lock(lock_cdclk));

   avr #(.pm_size(1),
	 .dm_size(1),
	 .impl_avr109(1),
	 .CLK_FREQUENCY(CPU_FREQ),
	 .AVR109_BAUD_RATE(115200),
`ifdef PM_INIT_LOW
	 .pm_init_low(`PM_INIT_LOW),
`endif
`ifdef PM_INIT_HIGH
	 .pm_init_high(`PM_INIT_HIGH),
`endif
	 )
     avr_inst(.nrst(1'b1), .clk(clkout),
	      .porta({LED7, LED6, LED5, LED4, LED3, LED2, LED1, LED0}),
	      .portb({PORTB7, PORTB6, PORTB5, PORTB4, PORTB3, PORTB2, PORTB1, PORTB0}),
	      .rxd(RXD), .txd(TXD),
	      .m_scl(), .m_sda(), .s_scl(), .s_sda(),
	      .sram_a(), .sram_d_in({8{1'b0}}), .sram_d_out(),
	      .sram_cs(), .sram_oe(), .sram_we(), .sram_wait(1'b0));

endmodule // top