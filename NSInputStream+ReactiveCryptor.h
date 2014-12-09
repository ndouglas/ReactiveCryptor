//
//  NSInputStream+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCRDefinitions.h"
#import "NSStream+ReactiveCryptor.h"

@interface NSInputStream (ReactiveCryptor)

/**
 Reads some amount of data into a buffer.
 
 @param bufferSize The amount of data that should be read.
 @return A signal that returns an amount of data (possibly zero-length), completes when the read finishes, and returns 
 an error if one occurred.
 */

- (RACSignal *)rcr_readWithBufferSize:(NSUInteger)bufferSize;

/**
 Reads some amount of data into the buffer whenever a next is received from the sample signal.
 
 @param sampleSignal A signal controlling the reading.  Each `next` should be an NSNumber<NSUInteger> specifying the
 amount of data to read.
 @return A signal that returns an amount of data, completes when the read finishes, and returns an error if one 
 occurred.
 */

- (RACSignal *)rcr_readWithSampleSignal:(RACSignal *)sampleSignal;

@end
