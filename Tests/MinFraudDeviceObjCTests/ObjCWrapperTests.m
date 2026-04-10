@import XCTest;
@import MinFraudDevice;

@interface ObjCWrapperTests : XCTestCase
@end

@implementation ObjCWrapperTests

- (void)testSDKConfigCreationWithDefaults {
    MMSDKConfig *config = [[MMSDKConfig alloc] initWithAccountID:12345];
    XCTAssertNotNil(config);
}

- (void)testSDKConfigCreationWithAllOptions {
    NSURL *url = [NSURL URLWithString:@"https://custom.example.com"];
    MMSDKConfig *config = [[MMSDKConfig alloc] initWithAccountID:12345
                                                       serverURL:url
                                                  loggingEnabled:YES
                                       collectionIntervalSeconds:300];
    XCTAssertNotNil(config);
}

- (void)testDeviceTrackerCreation {
    MMSDKConfig *config = [[MMSDKConfig alloc] initWithAccountID:12345];
    MMDeviceTracker *tracker = [[MMDeviceTracker alloc] initWithConfig:config];
    XCTAssertNotNil(tracker);
    [tracker shutdown];
}

- (void)testTrackingResultDescription {
    // We can't easily construct an MMTrackingResult from ObjC (init is internal),
    // but we can verify the class is visible and the API compiles.
    XCTAssertTrue([MMTrackingResult instancesRespondToSelector:@selector(trackingToken)]);
}

- (void)testCollectAndSendSignature {
    // Verify the completion-handler API is callable from ObjC.
    MMSDKConfig *config = [[MMSDKConfig alloc] initWithAccountID:12345];
    MMDeviceTracker *tracker = [[MMDeviceTracker alloc] initWithConfig:config];
    XCTAssertTrue([tracker respondsToSelector:@selector(collectAndSendWithCompletion:)]);
    [tracker shutdown];
}

@end
