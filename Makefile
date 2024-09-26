SHELL := /bin/bash
HIDE ?= @

export HOMEBREW_NO_AUTO_UPDATE=true

-include Makefile.flutter.mk
-include Makefile.build.mk
-include Makefile.docker.mk
-include ./docker/s3.mk
-include ./docker/registry.mk

.PHONY: build test

fix:
	$(HIDE)dart format . --line-length 120
	$(HIDE)dart fix --apply

gen:
	$(HIDE)dart run build_runner build --delete-conflicting-outputs
	$(HIDE)dart make/codegen.dart
	$(HIDE)make fix