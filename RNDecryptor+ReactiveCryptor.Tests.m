//
//  RNDecryptor+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCryptor.h"
#import <ReactiveXCTest/ReactiveXCTest.h>

@interface RNDecryptor_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *testString;
    NSData *testData;
}

@end

@implementation RNDecryptor_ReactiveCryptorTests

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

- (void)test {
}

@end
