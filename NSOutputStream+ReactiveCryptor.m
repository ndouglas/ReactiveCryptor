//
//  NSOutputStream+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSOutputStream+ReactiveCryptor.h"
#import "ReactiveCryptor.h"

@implementation NSOutputStream (ReactiveCryptor)

- (RACSignal *)rcr_writeOnce:(NSData *)data {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        RACDisposable *result = nil;
        NSLog(@"Writing data: %@", data);
        NSInteger bytesWritten = [self write:data.bytes maxLength:data.length];
        NSLog(@"Wrote %@ of %@ bytes.", @(bytesWritten), @(data.length));
        if (bytesWritten != data.length) {
            if (self.streamStatus == NSStreamStatusAtEnd || self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
                NSLog(@"Encountered status: %@", @(self.streamStatus));
                if (self.streamError) {
                    [subscriber sendError:self.streamError];
                }
                [subscriber sendCompleted];
            } else {
                NSData *remainingData = bytesWritten > 0 ? [data subdataWithRange:NSMakeRange(bytesWritten, (data.length - bytesWritten))] : data;
                [subscriber sendNext:remainingData];
            }
        } else {
            NSLog(@"Written!");
        }
        [subscriber sendCompleted];
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcr_writeOnce: %@", result.name, data];
}

- (RACSignal *)rcr_write:(NSData *)data {
    @weakify(self)
    RACSignal *result = [[self rcr_writeOnce:data]
    flattenMap:^RACSignal *(NSData *remainingData) {
        @strongify(self)
        return [self rcr_write:remainingData];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_write: %@", result.name, data];
}

- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize {
    RACBehaviorSubject *subject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:@(bufferSize)];
    RACSignal *result = [[[inputStream rcr_readWithSampleSignal:subject]
    takeUntilBlock:^BOOL(NSData *next) {
        return next.length == 0;
    }]
    flattenMap:^RACSignal *(NSData *data) {
        return [[self rcr_write:data]
        doCompleted:^{
            [subject sendNext:@(bufferSize)];
        }];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_processInputStream: %@ bufferSize: %@", result.name, inputStream, @(bufferSize)];    
}

- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream sampleSignal:(RACSignal *)sampleSignal {
    RACSignal *result = [[[inputStream rcr_readWithSampleSignal:sampleSignal]
    takeUntilBlock:^BOOL(NSData *next) {
        return next.length == 0;
    }]
    flattenMap:^RACSignal *(NSData *data) {
        return [self rcr_write:data];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_processInputStream: %@ sampleSignal: %@", result.name, inputStream, sampleSignal];
}

@end
