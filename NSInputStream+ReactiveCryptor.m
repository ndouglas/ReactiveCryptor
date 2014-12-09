//
//  NSInputStream+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/9/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSInputStream+ReactiveCryptor.h"
#import "ReactiveCouchbaseLite.h"

@implementation NSInputStream (ReactiveCryptor)

- (RACSignal *)rcr_readWithBufferSize:(NSUInteger)bufferSize {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSMutableData *buffer = [NSMutableData dataWithCapacity:bufferSize];
        NSInteger bytesRead = [self read:[buffer mutableBytes] maxLength:bufferSize];
        if (bytesRead < 0) {
            [subscriber sendError:[self streamError]];
        } else {
            [buffer setLength:bytesRead];
            [subscriber sendNext:buffer];
        }
        [subscriber sendCompleted];
        return nil;
   }];
    return [result setNameWithFormat:@"[%@] -rcr_readWithBufferSize: %@", result.name, @(bufferSize)];
}

@end
