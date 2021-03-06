//
//  NSStream+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCRDefinitions.h"

@interface NSStream (ReactiveCryptor)

/**
 Creates a bound pair of streams with the specified buffer size.
 
 @param bufferSize The size of the buffer to use.
 @param inputStream The input stream.
 @param outputStream The output stream.
 */

+ (void)rcr_createStreamPairWithBufferSize:(NSUInteger)bufferSize inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream;

/**
 Indicates when the stream has opened, using polling.
 
 @return A signal that completes when the stream is opened.
 */

- (RACSignal *)rcr_openSignal;

/**
 Opens the stream and closes it when the specified signal completes or errors.
 
 @return A signal that opens and closes the receiver.
 */

- (RACSignal *)rcr_openUntil:(RACSignal *)closeSignal;

@end
