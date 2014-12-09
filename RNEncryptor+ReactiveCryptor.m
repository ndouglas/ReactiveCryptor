//
//  RNEncryptor+ReactiveCryptor.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNEncryptor+ReactiveCryptor.h"
#import "ReactiveCryptor.h"
#import "RNEncryptor.h"

@implementation RNEncryptor (ReactiveCryptor)

+ (RACSignal *)rcr_encryptData:(NSData *)data password:(NSString *)password {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
        if (encryptedData) {
            [subscriber sendNext:encryptedData];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return result;
}

@end

