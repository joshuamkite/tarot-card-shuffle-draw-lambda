# Define the binary name
BINARY = main

BUILD_DIR := $(abspath $(CURDIR)/../builds/$(notdir $(CURDIR)))

# Default target executed when no arguments are given to make
all: build

# Build the binary for the specific function
build:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY) main.go
	cp bootstrap $(BUILD_DIR)/bootstrap

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)/$(BINARY)
	rm -rf $(BUILD_DIR)/bootstrap
