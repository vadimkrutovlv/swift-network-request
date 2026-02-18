CONFIG = debug
IOS_SIMULATOR_NAME ?= iPhone 16 Pro
IOS_SIMULATOR_OS ?= latest
WATCHOS_SIMULATOR_NAME ?= Apple Watch Series 10 (42mm)
WATCHOS_SIMULATOR_OS ?= 11.0
PLATFORM_IOS = iOS Simulator,name=$(IOS_SIMULATOR_NAME),OS=$(IOS_SIMULATOR_OS)
PLATFORM_MAC = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_WATCHOS = watchOS Simulator,name=$(WATCHOS_SIMULATOR_NAME),OS=$(WATCHOS_SIMULATOR_OS)

build-all-platforms:
	for platform in \
	  "$(PLATFORM_IOS)" \
	  "$(PLATFORM_MAC)" \
	  "$(PLATFORM_MAC_CATALYST)" \
	  "$(PLATFORM_WATCHOS)"; \
	do \
		xcrun xcodebuild build \
			-workspace NetworkRequest.xcworkspace \
			-scheme SwiftNetworkRequest \
			-configuration $(CONFIG) \
			-destination platform="$$platform" || exit 1; \
	done;

build-for-library-evolution:
	swift build \
		-c release \
		--target SwiftNetworkRequest \
		-Xswiftc -emit-module-interface \
		-Xswiftc -enable-library-evolution \
		-Xswiftc -DRESILIENT_LIBRARIES

test:
	swift test

test-exampleApp:
	xcrun xcodebuild test \
		-scheme "NetworkRequestExample" \
		-destination platform="$(PLATFORM_IOS)" || exit 1; \
