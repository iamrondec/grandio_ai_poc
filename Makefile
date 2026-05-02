ifeq ($(OS),Windows_NT)
PLATFORM := windows
else
SHELL := /bin/bash
PLATFORM := macos
endif

.PHONY: help setup test run serve setup-macos test-macos run-macos serve-macos install-windows-requirements setup-windows test-windows run-windows serve-windows clean

help:
	@echo Available targets:
	@echo   make setup                       # auto-detects macOS or Windows
	@echo   make test                        # auto-detects macOS or Windows
	@echo   make run                         # auto-detects macOS or Windows
	@echo   make serve                       # auto-detects macOS or Windows
	@echo   make setup-macos
	@echo   make test-macos
	@echo   make run-macos
	@echo   make serve-macos
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
