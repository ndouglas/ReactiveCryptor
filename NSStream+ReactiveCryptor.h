//
//  NSStream+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <Foundation/Foundation.h>
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

@end
