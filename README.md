# SHA-256

This is a SHA-256 algorithm implementation that I wrote in Verilog initially and rewrote in VHDL later on. This project is more of a test environment than anything else for tooling and project environment setup.

Currently this project utilizes FuseSoC for automation of test and build.

## Usage

### Running the simulation

fusesoc --cores-root . run --target sim midimaster21b:cryptography:sha256:0.1.0


