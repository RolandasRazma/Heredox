default: help

help:
	@echo "make help    	 - This help :)"
	@echo "make init    	 - Initialise git submodules"
	@echo "make update  	 - Update App and submodules"
	@echo "make clean   	 - Clean build"
	@echo "make build   	 - Build YPlan"
	@echo "make version 	 - Get current app version"

init:
	@git submodule init
	@git submodule update
	@git submodule foreach git checkout master

update:
	@git pull --rebase
	@git submodule foreach git pull

clean:
	@xcodebuild clean

build:
	@xcodebuild -project RRHeredox.xcodeproj

version:
	@/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "RRGame/Resources/Info.plist"

