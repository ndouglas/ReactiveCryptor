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
    NSString *testString;
    NSData *testData;
}

@end

@implementation NSInputStream_ReactiveCryptorTests

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

- (void)testReadWithBufferSize {
	[self rcr_expectNext:^(NSData *next) {
        XCTAssertNotNil(next);
        XCTAssertTrue(next.length == testData.length);
        NSString *returnedString = [[NSString alloc] initWithData:next encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(returnedString, testString);
    } signal:[inputStream rcr_readWithBufferSize:testData.length] timeout:5.0 description:@"read data successfully"];
    
    NSString *thisString = [[NSUUID UUID] UUIDString];
    NSData *thisData = [thisString dataUsingEncoding:NSUTF8StringEncoding];
    for (int i = 1; i < thisData.length; i++) {
        __block BOOL complete = NO;
        __block NSUInteger position = 0;
        __block NSUInteger remaining = thisData.length;
        __block NSUInteger expectedLength = MIN(i, remaining);
        __block NSUInteger nexts = 0;
        NSInputStream *thisStream = [[NSInputStream alloc] initWithData:thisData];
        [thisStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [thisStream open];
        [self rcr_expectCompletionFromSignal:[[[[[thisStream rcr_readWithBufferSize:i]
        repeat]
        doNext:^(NSData *next) {
            XCTAssertNotNil(next);
            XCTAssertTrue(next.length == expectedLength);
            if (next.length == 0) {
                complete = YES;
            } else {
                NSString *nextString = [[NSString alloc] initWithData:next encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects(nextString, [thisString substringWithRange:NSMakeRange(position, expectedLength)]);
                position += next.length;
                remaining -= next.length;
                expectedLength = MIN(i, remaining);
                nexts++;
            }
        }]
        takeUntilBlock:^BOOL(NSData *next) {
            return complete;
        }]
        then:^RACSignal * {
            XCTAssertEqual(nexts, thisData.length / i + (thisData.length % i > 0));
            return [RACSignal empty];
        }]
        timeout:5.0 description:@"read data successfully"];
        [thisStream close];
        [thisStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)testReadWithSampleSignal {
	[self rcr_expectNext:^(NSData *next) {
        XCTAssertNotNil(next);
        XCTAssertTrue(next.length == testData.length);
        NSString *returnedString = [[NSString alloc] initWithData:next encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(returnedString, testString);
    } signal:[inputStream rcr_readWithSampleSignal:[RACSignal return:@(testData.length)]] timeout:5.0 description:@"read data successfully"];
    
    NSString *thisString = [[NSUUID UUID] UUIDString];
    NSData *thisData = [thisString dataUsingEncoding:NSUTF8StringEncoding];
    for (int i = 1; i < thisData.length; i++) {
        __block BOOL complete = NO;
        __block NSUInteger position = 0;
        __block NSUInteger remaining = thisData.length;
        __block NSUInteger expectedLength = MIN(i, remaining);
        __block NSUInteger nexts = 0;
        RACBehaviorSubject *subject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:@(i)];
        NSInputStream *thisStream = [[NSInputStream alloc] initWithData:thisData];
        [thisStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [thisStream open];
        void (^trigger)(void) = ^{
            [subject sendNext:@(i)];
        };
        [self rcr_expectCompletionFromSignal:[[[[thisStream rcr_readWithSampleSignal:subject]
        doNext:^(NSData *next) {
            XCTAssertNotNil(next);
            XCTAssertTrue(next.length == expectedLength);
            if (next.length == 0) {
                [subject sendCompleted];
                complete = YES;
            } else {
                NSString *nextString = [[NSString alloc] initWithData:next encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects(nextString, [thisString substringWithRange:NSMakeRange(position, expectedLength)]);
                position += next.length;
                remaining -= next.length;
                expectedLength = MIN(i, remaining);
                nexts++;
            }
        }]
        takeUntilBlock:^BOOL(NSData *next) {
            trigger();
            return complete;
        }]
        then:^RACSignal * {
            XCTAssertEqual(nexts, thisData.length / i + (thisData.length % i > 0));
            return [RACSignal empty];
        }]
        timeout:5.0 description:@"read data successfully"];
        [thisStream close];
        [thisStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}


@end
