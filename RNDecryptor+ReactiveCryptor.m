//
//  RNDecryptor+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNDecryptor+ReactiveCryptor.h"
#import "ReactiveCryptor.h"

@implementation RNDecryptor (ReactiveCryptor)

+ (RACSignal *)rcr_decryptData:(NSData *)data password:(NSString *)password {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSData *decryptedData = [RNDecryptor decryptData:data withPassword:password error:&error];
        if (decryptedData) {
            [subscriber sendNext:decryptedData];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return result;
}

@end
