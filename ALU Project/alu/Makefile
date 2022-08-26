# If you have a custom isntallation of iverilog, you can uncomment and
# set PREFIX to your custom install path.
#
# PREFIX:=/some/other/path/bin

IVERILOG:=$(if $(strip $(PREFIX)), $(PREFIX)/)iverilog
VVP:=$(if $(strip $(PREFIX)), $(PREFIX)/)vvp

SV_FILES:=alu_tb.sv alu.sv

.SUFFIXES:
.PHONY: test secret version compile_alu

test: PROG_SELECT=TEST
test: test.output
	diff -u $< test_reference.output

secret: PROG_SELECT=SECRET
secret: secret.output

.PRECIOUS: %.log

%.output: %.log
	grep "ALU:" $< | sed 's/ALU: \(.*\)/\1/' > $@

%.log: alu_%.vvp
	$(VVP) $< -fst | tee $@

alu_%.vvp: $(SV_FILES)
	$(IVERILOG) -g2012 -DPROGRAM_$(PROG_SELECT) $^ -s alu_tb -o $@

version:
	@$(IVERILOG) -v 2> /dev/null | head -n1

compile_alu: alu.vvp

alu.vvp: alu.sv
	$(IVERILOG) -g2012 $^ -s alu -o $@
