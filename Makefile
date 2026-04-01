# Makefile
PROJECT = NKJMovieComposer
WORKSPACE = $(PROJECT).xcworkspace

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT)-iOS \
		clean

build:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT)-iOS \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-configuration Debug \
		build

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT)-iOS \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-configuration Debug \
		clean test

spm-build:
	swift build

spm-test:
	swift test

lint:
	pod lib lint --allow-warnings
