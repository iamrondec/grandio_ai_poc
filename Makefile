ifeq ($(OS),Windows_NT)
PLATFORM := windows
else
SHELL := /bin/bash
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
PLATFORM := macos
else ifeq ($(UNAME_S),Linux)
PLATFORM := ubuntu
else
$(error Unsupported platform: $(UNAME_S))
endif
endif

.PHONY: help setup test run serve setup-macos test-macos run-macos serve-macos install-ubuntu-requirements setup-ubuntu test-ubuntu run-ubuntu serve-ubuntu setup-ubuntu-qwen14b test-ubuntu-qwen14b run-ubuntu-qwen14b serve-ubuntu-qwen14b install-windows-requirements setup-windows test-windows run-windows serve-windows clean

help:
	@echo Available targets:
	@echo   make setup                       # auto-detects macOS, Ubuntu, or Windows
	@echo   make test                        # auto-detects macOS, Ubuntu, or Windows
	@echo   make run                         # auto-detects macOS, Ubuntu, or Windows
	@echo   make serve                       # auto-detects macOS, Ubuntu, or Windows
	@echo   make setup-macos
	@echo   make test-macos
	@echo   make run-macos
	@echo   make serve-macos
	@echo   make install-ubuntu-requirements
	@echo   make setup-ubuntu
	@echo   make test-ubuntu
	@echo   make run-ubuntu
	@echo   make serve-ubuntu
	@echo   make setup-ubuntu-qwen14b
	@echo   make test-ubuntu-qwen14b
	@echo   make run-ubuntu-qwen14b
	@echo   make serve-ubuntu-qwen14b
	@echo   make install-windows-requirements
	@echo   make setup-windows
	@echo   make test-windows
	@echo   make run-windows
	@echo   make serve-windows
	@echo   make clean

setup:
	$(MAKE) setup-$(PLATFORM)

test:
	$(MAKE) test-$(PLATFORM)

run:
	$(MAKE) run-$(PLATFORM)

serve:
	$(MAKE) serve-$(PLATFORM)

setup-macos:
	./scripts/macos/setup_llama_cpp_qwen.sh

test-macos:
	./scripts/macos/test_install.sh

run-macos:
	./scripts/macos/run_qwen.sh

serve-macos:
	./scripts/macos/run_qwen_server.sh

install-ubuntu-requirements:
	./scripts/ubuntu/install_requirements.sh

setup-ubuntu:
	./scripts/ubuntu/setup_llama_cpp_qwen.sh

test-ubuntu:
	./scripts/ubuntu/test_install.sh

run-ubuntu:
	./scripts/ubuntu/run_qwen.sh

serve-ubuntu:
	./scripts/ubuntu/run_qwen_server.sh

setup-ubuntu-qwen14b:
	./scripts/ubuntu/setup_qwen14b.sh

test-ubuntu-qwen14b:
	./scripts/ubuntu/test_qwen14b_install.sh

run-ubuntu-qwen14b:
	./scripts/ubuntu/run_qwen14b.sh

serve-ubuntu-qwen14b:
	./scripts/ubuntu/run_qwen14b_server.sh

install-windows-requirements:
	powershell -ExecutionPolicy Bypass -File .\scripts\windows\install_requirements.ps1

setup-windows:
	powershell -ExecutionPolicy Bypass -File .\scripts\windows\setup_llama_cpp_qwen.ps1

test-windows:
	powershell -ExecutionPolicy Bypass -File .\scripts\windows\test_install.ps1

run-windows:
	powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_qwen.ps1

serve-windows:
	powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_qwen_server.ps1

ifeq ($(OS),Windows_NT)
clean:
	powershell -ExecutionPolicy Bypass -Command "if (Test-Path '.venv') { Remove-Item -Recurse -Force '.venv' }; if (Test-Path 'build') { Remove-Item -Recurse -Force 'build' }; if (Test-Path 'vendor/llama.cpp/build') { Remove-Item -Recurse -Force 'vendor/llama.cpp/build' }"
else
clean:
	rm -rf .venv build
	rm -rf vendor/llama.cpp/build
endif
