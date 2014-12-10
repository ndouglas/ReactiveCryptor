//
//  NSStream+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "NSStream+ReactiveCryptor.h"
#import "Sync.h"

@implementation NSStream (ReactiveCryptor)

+ (void)rcr_createStreamPairWithBufferSize:(NSUInteger)bufferSize inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream {
    CFReadStreamRef localInputStream;
    CFWriteStreamRef localOutputStream;
    CFStreamCreateBoundPair(kCFAllocatorDefault, &localInputStream, &localOutputStream, bufferSize);
    if (inputStream) {
        *inputStream = (NSInputStream *)CFBridgingRelease(localInputStream);
    }
    if (outputStream) {
        *outputStream = (NSOutputStream *)CFBridgingRelease(localOutputStream);
    }
}

- (RACSignal *)rcr_openSignal {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        __block void (^checker)(void);
        checker = ^{
            @strongify(self)
            NSStreamStatus streamStatus = [self streamStatus];
            switch (streamStatus) {
                case NSStreamStatusNotOpen:
                case NSStreamStatusOpening:
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), checker);
                    break;
                case NSStreamStatusOpen:
                    [subscriber sendCompleted];
                    break;
                case NSStreamStatusReading:
                case NSStreamStatusWriting:
                case NSStreamStatusAtEnd:
                case NSStreamStatusClosed:
                    break;
                case NSStreamStatusError:
                default:
                    [subscriber sendError:[self streamError]];
                    break;
            }
        };
        checker();
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcr_openSignal", result.name];
}

- (RACSignal *)rcr_openUntil:(RACSignal *)closeSignal {
    @weakify(self)
    [self open];
    RACSignal *result = [closeSignal
    finally:^{
        @strongify(self)
        [self close];
    }];
    return [result setNameWithFormat:@"[%@] -rcr_openUntil: %@", result.name, closeSignal];
}

@end
