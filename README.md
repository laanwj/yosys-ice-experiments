Experiments for iCEstick evaluation board with iCE40HX-1k FPGA.

Wladimir J. van der Laan, 2015.

Using [yosys](https://github.com/cliffordwolf/yosys) + [arachne-pnr](https://github.com/cseed/arachne-pnr) + [icestorm](https://github.com/cliffordwolf/icestorm) open source Verilog FPGA toolchain.

General usage:
```bash
make # build FPGA bitstream
iceprog X.bin # flash and run FPGA bitstream
python x.py   # run host component
```

Python scripts require Python 3 and python3-serial (some may work in Python 2, no guarantees).

pmodoled2
============

Example driving Digilent PmodOLED module (128x32 grid SSD1306 module), using 4-wire SPI (10MHz max).
FPGA acts as SPI controller driven from host.

- `pmodoled2.v` main verilog source
- `pmodoled2.py` simple tests
- `mandelbrot.py` zoom into random points on Mandelbrot set
- `rawbench.py` measure FPS

