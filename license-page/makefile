# Binary name
BINARY = main

# Output directory for final zipped artifacts (repo root `builds/`)
OUTPUT_DIR := $(abspath $(CURDIR)/../builds)

# Temporary build directory inside function folder
BUILD_DIR := $(CURDIR)/.build

# Function name inferred from directory name
FN := $(notdir $(CURDIR))

.PHONY: all build \:zip clean

all: \:zip

# Build binary into temporary build dir
build:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY)
	cp -r templates $(BUILD_DIR)/templates
	cp bootstrap $(BUILD_DIR)/bootstrap

# Create a deployment zip in `builds/<function>.zip` (used by terraform)
\:zip:
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY)
	cp -r templates $(BUILD_DIR)/templates 2>/dev/null || true
	cp bootstrap $(BUILD_DIR)/bootstrap
	mkdir -p $(OUTPUT_DIR)
	(cd $(BUILD_DIR) && zip -r $(OUTPUT_DIR)/$(FN).zip .)
	rm -rf $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(OUTPUT_DIR)/$(FN).zip
