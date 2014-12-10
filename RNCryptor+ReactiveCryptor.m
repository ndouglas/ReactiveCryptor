//
//  RNCryptor+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Inspired by Ari Weinstein's suggested improvements to RNCryptor.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNCryptor+ReactiveCryptor.h"
#import "RNCryptor+Private.h"
#import "ReactiveCryptor.h"

@implementation RNCryptor (ReactiveCryptor)

- (RACSignal *)rcr_connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [inputStream open];
        [outputStream open];
        RACSubject *subject = [RACSubject subject];
        self.handler = ^(RNCryptor *cryptor, NSData *data) {
            NSError *error = nil;
            if (![[outputStream rcr_write:data] waitUntilCompleted:&error]) {
                [subscriber sendError:error];
            } else if (!cryptor.isFinished) {
                [subject sendNext:@(bufferSize)];
            } else {
                [outputStream close];
                [subject sendCompleted];
                [subscriber sendCompleted];
            
            }
        };
        [[[inputStream rcr_readWithSampleSignal:[subject startWith:@(bufferSize)]]
        takeUntilBlock:^BOOL(NSData *data) {
            return data.length == 0;
        }]
        subscribeNext:^(NSData *data) {
            @strongify(self)
            [self addData:data];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            @strongify(self)
            [inputStream close];
            [self finish];
        }];
        RACDisposable *result = [RACDisposable disposableWithBlock:^{
            @strongify(self)
            self.handler = nil;
        }];
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcr_connectInputStream: %@ outputStream: %@ bufferSize: %@", result.name, inputStream, outputStream, @(bufferSize)];
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
