# Define the binary name
BINARY = main

# Define the build directory, use `$(ARTIFACTS_DIR)` provided by AWS SAM
BUILD_DIR = $(ARTIFACTS_DIR)

# Default target executed when no arguments are given to make
all: build

# Build the binary for the specific function
build-LicensePageFunction:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY)
	cp -r templates $(BUILD_DIR)/templates
	cp bootstrap $(BUILD_DIR)/bootstrap

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)/$(BINARY)
	rm -rf $(BUILD_DIR)/templates
	rm -rf $(BUILD_DIR)/bootstrap
