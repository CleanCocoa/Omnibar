.PHONY: update
update:
	carthage update --no-use-binaries --use-xcframeworks --platform mac

.PHONY: all
all: update
