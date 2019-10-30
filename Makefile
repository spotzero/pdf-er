cpus=$(shell grep -c ^processor /proc/cpuinfo)

all: install
	docker build . -t spotzero/pdf-it

install: build
	cd bin && ../pdfserve/generate_cert.sh
	cp pdfserve/target/x86_64-unknown-linux-musl/release/pdfserve bin

build: setup
	cd pdfserve && rustup run nightly cargo build -j$(cpus) --release --target x86_64-unknown-linux-musl

setup:
	dpkg -l musl || sudo apt install -y musl musl-tools
	which rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	rustup show | grep nightly-x86_64 || rustup toolchain add nightly
	rustup show | grep x86_64-unknown-linux-musl || rustup target install x86_64-unknown-linux-musl
