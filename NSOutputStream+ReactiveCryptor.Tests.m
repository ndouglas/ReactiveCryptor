//
//  NSOutputStream+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCouchbaseLite.h"
#import "RCRTestDefinitions.h"

@interface NSOutputStream_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *testString;
    NSData *testData;
}

@end

@implementation NSOutputStream_ReactiveCryptorTests

- (void)setUp {
	[super setUp];
    testString = [[NSUUID UUID] UUIDString];
    testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    inputStream = [[NSInputStream alloc] initWithData:testData];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
    outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStream open];
}

- (void)tearDown {
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    inputStream = nil;
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    outputStream = nil;
	[super tearDown];
}

- (NSData *)dataInOutputStream:(NSOutputStream *)anOutputStream {
    return [anOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

- (void)trivalTest {
	[outputStream write:testData.bytes maxLength:testData.length];
    XCTAssertEqualObjects([self dataInOutputStream:outputStream], testData);
}

- (void)testWrite {
    [self rcr_expectCompletionFromSignal:[outputStream rcr_write:testData] timeout:1.0 description:@"write completed"];
    XCTAssertEqualObjects([self dataInOutputStream:outputStream], testData);
}


@end
