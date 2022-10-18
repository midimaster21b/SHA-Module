# SHA-256

This is a SHA-256 algorithm implementation that I wrote in Verilog initially and rewrote in VHDL later on. This project is more of a test environment than anything else for tooling and project environment setup.

Currently this project utilizes FuseSoC for automation of test and build.

[Original SHA-256 whitepaper](https://csrc.nist.gov/csrc/media/publications/fips/180/2/archive/2002-08-01/documents/fips180-2withchangenotice.pdf)


## Usage

### Setup

Before starting these steps, make sure you have an installation of python3 available in your PATH environment variable.

1. Clone the repository

   `git clone https://github.com/midimaster21b/SHA-Module.git`

1. Move into cloned repository

   `cd SHA-Module`

1. Create a venv python virtual env

   `python -m venv env`

1. Source the new virtual environment

   `source env/bin/activate`

1. Install the python requirements

   `pip install -r requirements`


### Running the simulation

While in the base directory of the cloned repository

`fusesoc --cores-root . run --target sim midimaster21b:cryptography:sha256:0.1.0`


## Limitations

- This implementation is currently not pipelined and takes 66 clock cycles for a single 512 bit message to result in a 256 bit hash.
- This implementation only supports a 512 bit input message and must be manually padded and packed with the message length and end of message byte.


## Future

Since this repository is essentially a test-ground for me to test new tools and test methods, I will try to keep track of any future plans for this repository in the github issues tracker. If there are any desired tools or test libraries you'd like to see used, please let me know via [email](mailto:joshedgcombe@gmail.com).