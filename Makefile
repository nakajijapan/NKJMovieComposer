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
	xctool -arch i386 \
		-destination "name=iPhone Retina (4-inch),OS=7.0" \
		-configuration Debug \
		-sdk iphonesimulator \
		-project $(PROJECT) \
		-scheme $(SCHEME_TARGET) \
		clean test \
		-parallelize -freshSimulator -freshInstall --showTasks \
		TEST_HOST= \
		TEST_AFTER_BUILD=YES