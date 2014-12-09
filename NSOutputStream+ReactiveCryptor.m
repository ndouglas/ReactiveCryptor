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
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable *result = nil;
        NSInteger bytesWritten = [self write:data.bytes maxLength:data.length];
        if (bytesWritten != data.length) {
            if (self.streamStatus == NSStreamStatusAtEnd || self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
                [subscriber sendError:self.streamError];
            } else {
                NSData *remainingData = bytesWritten > 0 ? [data subdataWithRange:NSMakeRange(bytesWritten, (data.length - bytesWritten))] : data;
                [subscriber sendNext:remainingData];
            }
        } else {
            [subscriber sendCompleted];
        }
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcr_writeOnce: %@", result.name, data];
}

- (RACSignal *)rcr_write:(NSData *)data {
    RACSignal *result = [[self rcr_writeOnce:data]
    flattenMap:^RACSignal *(NSData *remainingData) {
        return [self rcr_write:remainingData];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_write: %@", result.name, data];
}

@end