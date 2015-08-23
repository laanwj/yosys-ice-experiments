Experiments for iCEstick evaluation board with iCE40HX-1k FPGA.

Wladimir J. van der Laan, 2015.

Using [Yosys](https://github.com/cliffordwolf/yosys) + [Arachne-pnr](https://github.com/cseed/arachne-pnr) + [IceStorm](https://github.com/cliffordwolf/icestorm) open source Verilog FPGA toolchain.

General usage:
```bash
make # build FPGA bitstream (requires yosys toolchain in PATH)
iceprog X.bin # flash and run FPGA bitstream
python x.py   # run host component
```

The python scripts require Python 3 and python3-serial (some may work in Python 2, no guarantees). They are supposed to auto-detect the USB serial port that the iCEstick is connected to, although this will only work if there is only one such device connected.

Installing toolchain
======================

I use the following script to fetch, build and install the toolchain to a local `/opt` path.

```bash
DESTDIR=/opt/yosys
git clone https://github.com/cliffordwolf/yosys.git
git clone https://github.com/cseed/arachne-pnr.git
git clone https://github.com/cliffordwolf/icestorm.git
( cd icestorm
make
make install DESTDIR=$DESTDIR
)
( cd arachne-pnr
make ICEBOX=$DESTDIR/share/icebox
make install DESTDIR=$DESTDIR ICEBOX=$DESTDIR/share/icebox
)
( cd yosys
make
make install DESTDIR=$DESTDIR
)
```

pmodoled2
============

Example of driving Digilent PmodOLED module (128x32 grid SSD1306 module), using 4-wire SPI (10MHz max).
FPGA acts as SPI controller driven from host.

- `pmodoled2.v` main verilog source
- `pmodoled2.py` simple tests
- `mandelbrot.py` zoom into random points on Mandelbrot set
- `rawbench.py` measure FPS

