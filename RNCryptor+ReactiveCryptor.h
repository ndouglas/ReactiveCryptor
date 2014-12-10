//
//  RNCryptor+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCRDefinitions.h"
#import "RNCryptor.h"

@interface RNCryptor (ReactiveCryptor)

/**
 Reads data from the input stream and writes it to the output stream in bufferSize-sized chunks.
 
 @param inputStream An input stream.
 @param outputStream An output stream.
 @param bufferSize The size of the chunks that should be used for the data.
 @return A signal that completes when the write does or sends an error if one is encountered.
 @discussion This method will take care of opening and closing the streams.
 @discussion bufferSize needs to be at least the size of the header block.
 */

- (RACSignal *)rcr_connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;

/**
 Reads data from the input stream and writes it to the output stream in bufferSize-sized chunks after a stream is opened.
 
 @param openingStream A stream whose status should be polled.
 @param inputStream An input stream.
 @param outputStream An output stream.
 @param bufferSize The size of the chunks that should be used for the data.
 @return A signal that completes when the write does or sends an error if one is encountered.
 */

- (RACSignal *)rcr_afterOpeningStream:(NSStream *)openingStream connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;

- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize;

- (RACSignal *)rcr_processOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;

@end
