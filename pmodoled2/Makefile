all: pmodoled2.bin

pmodoled2.bin: pmodoled2.v uart.v pmodoled2.pcf
	yosys  -q -p "synth_ice40 -top top -blif $(@:.bin=).blif" $(filter %.v,$^)
	arachne-pnr -p $(filter %.pcf,$^) $(@:.bin=).blif -o $(@:.bin=).txt
	icebox_explain $(@:.bin=).txt > $(@:.bin=).ex
	icepack $(@:.bin=).txt $@

clean:
	rm -f pmodoles2.blif pmodoles2.txt pmodoles2.ex pmodoles2.bin

.PHONY: subdirs
.PHONY: subdirs $(SUBDIRS)
.PHONY: clean
