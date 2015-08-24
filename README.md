Experiments for iCEstick evaluation board with iCE40HX-1k FPGA.

Wladimir J. van der Laan, 2015.

Using [Yosys](https://github.com/cliffordwolf/yosys) + [Arachne-pnr](https://github.com/cseed/arachne-pnr) + [IceStorm](https://github.com/cliffordwolf/icestorm) open source Verilog FPGA toolchain.

General usage progression:
```bash
cd X
make          # build FPGA bitstream (requires yosys toolchain in PATH)
iceprog X.bin # flash and run FPGA bitstream
python x.py   # run host component
```

The python scripts require Python 3 and python3-serial (some may work in Python 2: no guarantees). Some require numpy installed too. They are supposed to auto-detect the USB serial port that the iCEstick is connected to, although this will only work if there is only one such device connected.

iCEstick
=========

The [iCEstick](http://www.latticesemi.com/icestick) is a low cost ($25) evaluation board for iCE range of FPGAs from Lattice Semiconductor.

The FPGA on the board is a iCE40HX1K-TQ144. The [bitstream format](http://www.clifford.at/icestorm/) as well as connectivity and logic of this FPGA has been reverse-engineered and an open-source toolchain has been developed. This toolchain goes all the way - it can synthesize from Verilog, does place and route, and produces working bitstreams.

It is programmed as well as powered through USB. Various peripherals can be connected conveniently through a 2x6 pin so-called Pmod connector.

The combination of low cost and readily available tooling makes it very attractive for experimentation, as well as for learning Verilog in an unburdened free software environment.

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

It may be necessary to first install prerequisites (for Ubuntu 14.04):
```bash
sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev
```

Don't forget to add the toolchain to your shell's path before usage:
```bash
export PATH="$PATH:/opt/yosys/bin"
```

pmodoled2
============

Experiment driving Digilent PmodOLED module (128x32 grid SSD1306 module), using 4-wire SPI (10MHz max).
The FPGA acts as SPI controller driven from host.

- `pmodoled2.v` main verilog source
- `pmodoled2.py` simple test screens
- `mandelbrot.py` zoom into random points on Mandelbrot set
- `rawbench.py` measure FPS
- `clear.py` clear screen and exit

[README](pmodoled2/README.md)

