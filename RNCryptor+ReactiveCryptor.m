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
    NSLog(@"Connecting input stream to output stream.");
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [inputStream open];
        [outputStream open];
        NSLog(@"Creating subject.");
        RACBehaviorSubject *subject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:@(bufferSize)];
        self.handler = ^(RNCryptor *cryptor, NSData *data) {
            NSLog(@"Handling data: %@", data);
            [[outputStream rcr_write:data]
            subscribeError:^(NSError *error) {
                NSLog(@"Writer received error: %@", error);
                [subscriber sendError:error];
            } completed:^{
                NSLog(@"Writer received completed.");
                if (!cryptor.isFinished) {
                    NSLog(@"Signaling reader.");
                    [subject sendNext:@(bufferSize)];
                } else {
                    NSLog(@"Closing output stream.");
                    [outputStream close];
                    NSLog(@"Completing subject.");
                    [subject sendCompleted];
                    NSLog(@"Completing subscriber.");
                    [subscriber sendCompleted];
                }
            }];
        };
        NSLog(@"Creating reader.");
        [[[inputStream rcr_readWithSampleSignal:subject]
        takeUntilBlock:^BOOL(NSData *data) {
            NSLog(@"Reader received (possibly zero-length) data: %@", data);
            return data.length == 0;
        }]
        subscribeNext:^(NSData *data) {
            NSLog(@"Reader received data: %@", data);
            @strongify(self)
            [self addData:data];
        } error:^(NSError *error) {
            NSLog(@"Reader received error: %@", error);
            [subscriber sendError:error];
        } completed:^{
            NSLog(@"Reader received completed.");
            @strongify(self)
            NSLog(@"Closing input stream.");
            [inputStream close];
            NSLog(@"Finishing cryptor.");
            [self finish];
        }];
        RACDisposable *result = [RACDisposable disposableWithBlock:^{
            @strongify(self)
            NSLog(@"Disposing.");
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

- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize {
    NSInputStream *resultStream = nil;
    NSOutputStream *outputStream = nil;
    [NSStream rcr_createStreamPairWithBufferSize:bufferSize inputStream:&resultStream outputStream:&outputStream];
    RACSignal *result = [[RACSignal return:resultStream]
    concat:[self rcr_afterOpeningStream:resultStream connectInputStream:inputStream outputStream:outputStream bufferSize:bufferSize]];
    return [result setNameWithFormat:@"[%@] -rcr_processInputStream: %@ bufferSize: %@", result.name, inputStream, @(bufferSize)];
}

- (RACSignal *)rcr_processOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize {
    NSInputStream *inputStream = nil;
    NSOutputStream *resultStream = nil;
    [NSStream rcr_createStreamPairWithBufferSize:bufferSize inputStream:&inputStream outputStream:&resultStream];
    RACSignal *result = [[RACSignal return:resultStream]
    concat:[self rcr_afterOpeningStream:resultStream connectInputStream:inputStream outputStream:outputStream bufferSize:bufferSize]];
    return [result setNameWithFormat:@"[%@] -rcr_processOutputStream: %@ bufferSize: %@", result.name, outputStream, @(bufferSize)];
}

@end
