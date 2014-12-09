//
//  NSInputStream+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCryptor.h"
#import "RCRTestDefinitions.h"

@interface NSInputStream_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
}

@end

@implementation NSInputStream_ReactiveCryptorTests

- (void)setUp {
	[super setUp];
    inputStream = [[NSInputStream alloc] initWithData:[@"Data" dataUsingEncoding:NSUTF8StringEncoding]];
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
	[self rcr_expectNext:^(NSData *next) {
        XCTAssertNotNil(next);
        XCTAssertTrue(next.length == 4);
    } signal:[inputStream rcr_readWithBufferSize:4] timeout:5.0 description:@"read data successfully"];
}

@end
