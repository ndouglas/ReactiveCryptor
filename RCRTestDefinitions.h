//
//  RCRTestDefinitions.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveCryptor.h"

@interface XCTestCase (ReactiveCryptor)

/**
 Subscribes to the signal and succeeds if the signal then sends a completion before the specified timeout.
 
 @param signal A signal to test.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-completion values are treated as failures.
 */

- (void)rcr_expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Subscribes to the signal and succeeds if the signal then sends a new value before the specified timeout.
 
 @param nextHandler A block that can test the next value further.
 @param signal A signal to test.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-next values are treated as failures.
 */

- (void)rcr_expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Subscribes to the signal and succeeds if the signal then sends an error before the specified timeout.
 
 @param errorHandler A block that can test the error further.
 @param signal A signal to test.
 @param timeout A timeout within which the signal must send an error.
 @param description A description of this test.
 @discussion Any non-error values are treated as failures.
 */

- (void)rcr_expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Tests that the specified condition succeeded before the timeout.
 
 @param block A block that must evaluate to YES before the timeout.
 @param timeout The timeout.
 @param interval The interval between tests.
 @param description A description of this test.
 */

- (void)rcr_expectCondition:(BOOL (^)(void))block beforeTimeout:(NSTimeInterval)timeout interval:(NSTimeInterval)interval description:(NSString *)description;

@end
