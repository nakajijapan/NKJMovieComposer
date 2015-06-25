# Makefile
PROJECT = Project/NKJMovieComposerDemo.xcodeproj
SCHEME_TARGET = NKJMovieComposerDemo
TEST_TARGET = NKJMovieComposerDemoTests

clean:
	xcodebuild \
		-project $(PROJECT) \
		clean

build:
	xcodebuild \
		-project $(PROJECT) \
		-target $(TEST_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME_TARGET) \
		-destination-timeout 1 \
		-sdk iphonesimulator \
		-configuration Debug \
		-destination 'name=iPhone 6' 

test2:
	xctool \
		-destination "platform=iOS Simulator,name=iPhone 6,OS=8.1" \
		-configuration Debug \
		-sdk iphonesimulator \
		-project $(PROJECT) \
		-scheme $(SCHEME_TARGET) \
		test -only NKJMovieComposerDemoTests \
		-parallelize -freshSimulator -freshInstall --showTasks \
		TEST_HOST= \
		TEST_AFTER_BUILD=YES
