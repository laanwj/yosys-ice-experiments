all: ok.bin fail.bin

ok.bin: ok.v uart.v ok.pcf
	yosys  -q -p "synth_ice40 -top top -blif $(@:.bin=).blif" $(filter %.v,$^)
	arachne-pnr -p $(filter %.pcf,$^) $(@:.bin=).blif -o $(@:.bin=).txt
	icebox_explain $(@:.bin=).txt > $(@:.bin=).ex
	icepack $(@:.bin=).txt $@

fail.bin: fail.v uart.v fail.pcf
	yosys  -q -p "synth_ice40 -top top -blif $(@:.bin=).blif" $(filter %.v,$^)
	arachne-pnr -p $(filter %.pcf,$^) $(@:.bin=).blif -o $(@:.bin=).txt
	icebox_explain $(@:.bin=).txt > $(@:.bin=).ex
	icepack $(@:.bin=).txt $@

clean:
	rm -f ok.blif ok.txt ok.ex ok.bin
	rm -f fail.blif fail.txt fail.ex fail.bin

.PHONY: subdirs
.PHONY: subdirs $(SUBDIRS)
.PHONY: clean
