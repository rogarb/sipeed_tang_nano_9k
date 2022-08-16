################################################################################
#                                                                              #
#                     Makefile for Sipeed Tang Nano 9K                         #
#                                                                              #
################################################################################
#                                                                              #
# This Makefile makes use of the following software:                           #
#  - Yosys: https://github.com/YosysHQ/nextpnr#nextpnr-gowin                   #
#  - nextpnr-gowin: https://github.com/YosysHQ/nextpnr#nextpnr-gowin           #
#  - apicula: https://github.com/YosysHQ/apicula                               #
#  - openFPGALoader: https://github.com/trabucayre/openFPGALoader              #
#                                                                              #
################################################################################
#
# Paths to utils
#
YOSYS=/CHANGEME/yosys
NEXTPNR=/CHANGEME/nextpnr-gowin
OPENFPGALOADER=/CHANGEME/openFPGALoader
PACKER=/CHANGEME/gowin_pack
#
# Target configuration
#
DEVICE='GW1NR-LV9QN88PC6/I5'
FAMILY='GW1N-9C'
BOARD='tangnano9k'
CST=${BOARD}.cst # Constraints file: mapping of board I/O, can be found in the apicula repo
#
# Basename for output files
#
BASENAME=blinky
#
# Path to libs
#
LIBDIR=
###############################################################################
#
# Internal variables, shouldn't be edited
SRC=$(wildcard *.v)
JSON=${BASENAME}.json
VOUT=${BASENAME}.vout
PNR=${BASENAME}-pnr.json
PACKED=${BASENAME}.bin
LIBS=$(wildcard ${LIBDIR}/*.v)

.PHONY: default
default: upload

${JSON}: ${SRC}
	${YOSYS} -p "read_verilog ${SRC} ${LIBS}; synth_gowin -json ${JSON}"

${VOUT}: 
	${YOSYS} -p "read_verilog ${SRC} ${LIBS}; synth_gowin -vout ${VOUT}"

${PNR}: ${JSON} 
	${NEXTPNR}	--json ${JSON} \
			--write ${PNR} \
			--family ${FAMILY} \
			--device ${DEVICE} \
			--cst ${CST}

${PACKED}: ${PNR} 
	${PACKER} -d ${FAMILY} -o ${PACKED} ${PNR}

.PHONY: upload
upload: ${PACKED}
	$(OPENFPGALOADER) -v -b ${BOARD} ${PACKED}

.PHONY: gui
gui: ${JSON}
	${NEXTPNR}	--json ${JSON} \
			--write ${PNR} \
			--family ${FAMILY} \
			--device ${DEVICE} \
			--cst ${CST} \
			--gui

.PHONY: clean
clean:
	rm -f ${JSON} ${VOUT} ${PNR} ${PACKED}

.PHONY: synthesize
synthesize: ${JSON}

.PHONY: pnr
pnr: ${PNR}

.PHONY: pack
pack: ${PACKED}
