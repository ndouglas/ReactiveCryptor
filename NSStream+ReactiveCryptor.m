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
        RACDisposable *result = [[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]
        scheduleRecursiveBlock:^(void (^reschedule)(void)) {
            @strongify(self)
            NSStreamStatus streamStatus = [self streamStatus];
            switch (streamStatus) {
                case NSStreamStatusNotOpen:
                case NSStreamStatusOpening:
                    reschedule();
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
                    [subscriber sendError:self.streamError];
                    break;
            }
           
        }];
        return result;
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
