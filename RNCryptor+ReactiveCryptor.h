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

- (RACSignal *)rcr2_connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
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

/**
 Connects the input stream to an output stream and returns a new input stream that will be appropriately processed.
 
 @param inputStream The input stream to process.
 @param bufferSize The size of the buffer to use in processing.
 @return A signal that will return a new input stream and complete or send an error when the processing has succeeded or failed.
 @discussion Processing will begin when the returned input stream is opened.
 */

- (RACSignal *)rcr_processedInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize;

/**
 Connects the ouput stream to an input stream and returns a new output stream that will be appropriately processed.
 
 @param outputStream The output stream to process.
 @param bufferSize The size of the buffer to use in processing.
 @return A signal that will return a new output stream and complete or send an error when the processing has succeeded or failed.
 @discussion Processing will begin when the returned output stream is opened.
 */

- (RACSignal *)rcr_processedOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;

@end
