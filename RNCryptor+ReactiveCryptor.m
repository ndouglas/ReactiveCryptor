//
//  RNCryptor+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Based on Ari Weinstein's suggested improvements to RNCryptor.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNCryptor+ReactiveCryptor.h"
#import "RNCryptor+Private.h"
#import "ReactiveCryptor.h"

@implementation RNCryptor (ReactiveCryptor)

- (void)rcr_setOutputStream:(NSOutputStream *)outputStream dataRequestHandler:(void (^)(RNCryptor *cryptor))dataRequestHandler endOfStreamHandler:(void (^)(NSError *error))endOfStreamHandler {
    [outputStream open];
    @weakify(self)
    void (^completionHandler)(NSError *) = ^(NSError *error) {
        [outputStream close];
        if (endOfStreamHandler) {
            endOfStreamHandler(error);
        }
        self.handler = nil;
    };
    self.handler = ^(RNCryptor *cryptor, NSData *data) {
        @strongify(self)
        NSInteger bytesWritten = [outputStream write:data.bytes maxLength:data.length];
        if (bytesWritten != data.length) {
            NSStreamStatus streamStatus = outputStream.streamStatus;
            if (streamStatus == NSStreamStatusAtEnd || streamStatus == NSStreamStatusClosed || streamStatus == NSStreamStatusError) {
                return completionHandler(outputStream.streamError);
            }
            NSData *remainingData = bytesWritten > 0 ? [data subdataWithRange:NSMakeRange(bytesWritten, (data.length - bytesWritten))] : data;
            dispatch_async(self.responseQueue, ^{
                self.handler(cryptor, remainingData);
            });
        } else {
            if (cryptor.isFinished) {
                completionHandler(nil);
            } else if (dataRequestHandler) {
                dataRequestHandler(self);
            }
        }
    };
    if (dataRequestHandler) {
        dataRequestHandler(self);
    }
}

- (void)rcr_startProcessingStream:(NSInputStream *)inputStream intoDestinationStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize endOfStreamHandler:(void (^)(NSError *error))endOfStreamHandler {
    [inputStream open];
    void (^completionHandler)(NSError *) = ^(NSError *error) {
        [inputStream close];
        if (endOfStreamHandler) {
            endOfStreamHandler(error);
        }
    };
    NSMutableData *buffer = [NSMutableData dataWithCapacity:bufferSize];
    void (^dataRequestHandler)(RNCryptor *cryptor) = ^(RNCryptor *cryptor) {
        [buffer setLength:bufferSize];
        NSInteger bytesRead = [inputStream read:buffer.mutableBytes maxLength:bufferSize];
        if (bytesRead < 0) {
            completionHandler([inputStream streamError]);
        } else if (bytesRead == 0) {
            [cryptor finish];
        } else {
            [buffer setLength:bytesRead];
            [cryptor addData:buffer];
        }
    };
    [self rcr_setOutputStream:outputStream dataRequestHandler:dataRequestHandler endOfStreamHandler:endOfStreamHandler];
}

- (RACSignal *)rcr_connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self rcr_startProcessingStream:inputStream intoDestinationStream:outputStream bufferSize:bufferSize endOfStreamHandler:^(NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcr2_connectInputStream: %@ outputStream: %@ bufferSize: %@", result.name, inputStream, outputStream, @(bufferSize)];
}

- (RACSignal *)rcr_afterOpeningStream:(NSStream *)openingStream connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize {
    RACSignal *result = [[openingStream rcr_openSignal]
    then:^RACSignal *{
        return [self rcr_connectInputStream:inputStream outputStream:outputStream bufferSize:bufferSize];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_afterOpeningStream: %@ connectInputStream: %@ sampleSignal: %@", result.name, openingStream, inputStream, outputStream];
}

- (RACSignal *)rcr_processedInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize {
    NSInputStream *resultStream = nil;
    NSOutputStream *outputStream = nil;
    [NSStream rcr_createStreamPairWithBufferSize:bufferSize inputStream:&resultStream outputStream:&outputStream];
    RACSignal *result = [[RACSignal return:resultStream]
    concat:[self rcr_afterOpeningStream:resultStream connectInputStream:inputStream outputStream:outputStream bufferSize:bufferSize]];
    return [result setNameWithFormat:@"[%@] -rcr_processInputStream: %@ bufferSize: %@", result.name, inputStream, @(bufferSize)];
}

- (RACSignal *)rcr_processedOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize {
    NSInputStream *inputStream = nil;
    NSOutputStream *resultStream = nil;
    [NSStream rcr_createStreamPairWithBufferSize:bufferSize inputStream:&inputStream outputStream:&resultStream];
    RACSignal *result = [[RACSignal return:resultStream]
    concat:[self rcr_afterOpeningStream:resultStream connectInputStream:inputStream outputStream:outputStream bufferSize:bufferSize]];
    return [result setNameWithFormat:@"[%@] -rcr_processOutputStream: %@ bufferSize: %@", result.name, outputStream, @(bufferSize)];
}

@end
