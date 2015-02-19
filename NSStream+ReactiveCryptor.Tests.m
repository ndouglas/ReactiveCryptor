//
//  NSStream+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCryptor.h"
#import <ReactiveXCTest/ReactiveXCTest.h>

@interface NSStream_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
    NSString *testString;
    NSData *testData;
}

@end

@implementation NSStream_ReactiveCryptorTests

- (void)setUp {
	[super setUp];
    testString = [[NSUUID UUID] UUIDString];
    testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    inputStream = [[NSInputStream alloc] initWithData:testData];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
}

- (void)tearDown {
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    inputStream = nil;
	[super tearDown];
}

- (void)testOpenSignal {
	NSInputStream *stream = [[NSInputStream alloc] initWithData:testData];
    [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [stream open];
    });
    [self rxct_expectCompletionFromSignal:[stream rcr_openSignal] timeout:5.0 description:@"signal eventually opened"];
}

#undef __CLASS__
@end
