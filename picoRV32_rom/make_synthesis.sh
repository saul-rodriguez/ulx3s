# synthesize (expects top's module name = top)
yosys -p 'synth_ice40 -top top -blif top.blif' $1.v

#Place and route
arachne-pnr -d 8k -P cm81 -o $1.asc -p pins.pcf top.blif

#Timing report
icetime -d lp8k -mtr $1.rpt $1.asc

#Generate binary
icepack $1.asc $1.bin

#upload binary
#tinyprog -p top.bin 
