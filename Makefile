.PHONY: project build run clean

project:
	@command -v xcodegen >/dev/null 2>&1 || { \
		echo "XcodeGen nao encontrado. Instalando via Homebrew..."; \
		brew install xcodegen; \
	}
	xcodegen generate
	@echo "Projeto gerado com sucesso! Abra ClipHist.xcodeproj no Xcode."

build: project
	xcodebuild -project ClipHist.xcodeproj -scheme ClipHist -configuration Debug build

run: build
	open build/Debug/ClipHist.app

clean:
	rm -rf build
	rm -rf ClipHist.xcodeproj
