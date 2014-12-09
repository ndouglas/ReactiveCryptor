//
//  NSInputStream+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCouchbaseLite.h"
#import "RCRTestDefinitions.h"

@interface NSInputStream_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
}

@end

@implementation NSInputStream_ReactiveCryptorTests

- (void)setUp {
	[super setUp];
    inputStream = [[NSInputStream alloc] initWithFileAtPath:@"/mach_kernel"];
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
	/*
		Run a test here.
	*/
}

@end
