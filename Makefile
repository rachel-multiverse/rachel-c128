# Rachel Commodore 128 Client Makefile

XA ?= xa
CL65 ?= cl65

BUILD_DIR = build
SRC_DIR = src

TARGET = $(BUILD_DIR)/rachel.prg

.PHONY: all clean

all: $(BUILD_DIR) $(TARGET)
	@echo "Built: $(TARGET)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(SRC_DIR)/main.asm $(SRC_DIR)/*.asm $(SRC_DIR)/net/*.asm
	cd $(SRC_DIR) && $(XA) -o ../$(TARGET) main.asm 2>/dev/null || \
	$(CL65) -t c128 -o ../$(TARGET) main.asm

clean:
	rm -rf $(BUILD_DIR)
