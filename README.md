# Project Implementation README

- **Team Members:** Padmanjali Nethi (2024102047) & Sukeerthi Kattamuri (2024102074)

## Overview

This repository contains the RTL design, functional verification, synthesis, Static Timing Analysis (STA), and physical design implementation of a 4-bit array multiplier using open-source EDA tools and the SKY130A PDK.

---

## Part A: Functional Verification

In this part, we verified the functionality of the 4-bit array multiplier using Icarus Verilog. The testbench checked all 256 input combinations, and GTKWave was used to visualize the simulation waveforms and observe the pipeline behavior.

```bash
# Compile the RTL design and testbench
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v

# Run the functional simulation
vvp sim

# Open the generated waveform
gtkwave mult.vcd
```

---

## Part B: Logic Synthesis and Gate-Level Simulation

In this part, we synthesized the RTL design using Yosys and mapped the logic to SKY130 standard cells. We generated the synthesized gate-level netlist and cell statistics, then performed gate-level simulation using Icarus Verilog to verify the synthesized design.

```bash
# Run Yosys synthesis
yosys -c synth/synth.tcl

# Display synthesis statistics
cat synth/mult_array_stat.rpt

# Set the SKY130 standard-cell Verilog library path
export CELLS="$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog"

# Compile the gate-level netlist with the SKY130 cell models
iverilog -g2012 -DFUNCTIONAL '-DUNIT_DELAY=#1' -o gls \
tb/tb_mult.v \
"$CELLS/primitives.v" \
"$CELLS/sky130_fd_sc_hd.v" \
synth/mult_array_netlist.v

# Run gate-level simulation
vvp gls
```

---

## Part C: Static Timing Analysis (STA)

In this part, we used OpenSTA to analyze the timing characteristics of the synthesized multiplier. We evaluated the critical timing path, worst slack, and estimated the minimum clock period by changing the clock period in the STA script.

```bash
# Check the OpenSTA version
sta -version

# Run Static Timing Analysis
sta -exit sta/sta.tcl

# Display the timing report
cat sta/mult_array_timing.rpt

# After changing the clock period to 2.98 ns in sta/sta.tcl, rerun STA
sta -exit sta/sta.tcl

# Display the updated timing report
cat sta/mult_array_timing.rpt
```

---

## Part D: Physical Design Using LibreLane

In this part, we implemented the multiplier through the LibreLane physical design flow. We ran the flow with clock periods ranging from 4.0 ns to 7.0 ns in increments of 0.5 ns. The flow performs stages such as floorplanning, placement, clock-tree synthesis, routing, and physical verification. The final GDSII layout and metrics were copied into the `pnr` directory from the 7.0 ns run.

**Note:** Before each run, update `CLOCK_PERIOD` in `prn/config.json` to the corresponding value.

```bash
# Run LibreLane with a clock period of 4.0 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_40 prn/config.json

# Run LibreLane with a clock period of 4.5 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_45 prn/config.json

# Run LibreLane with a clock period of 5.0 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_50 prn/config.json

# Run LibreLane with a clock period of 5.5 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_55 prn/config.json

# Run LibreLane with a clock period of 6.0 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_60 prn/config.json

# Run LibreLane with a clock period of 6.5 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_65 prn/config.json

# Run LibreLane with a clock period of 7.0 ns
librelane --pdk-root "$PDK_ROOT" -p sky130A --design-dir . --run-tag mult4_run_70 prn/config.json

# Create the P&R output directory
mkdir -p pnr

# Copy the final metrics from the 7.0 ns run
cp runs/mult4_run_70/final/metrics.json pnr/

# Copy the final GDSII layout from the 7.0 ns run
cp runs/mult4_run_70/final/gds/mult_array.gds pnr/
```

---


