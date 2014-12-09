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
#import "ReactiveCryptor.h"

@implementation RNCryptor (ReactiveCryptor)

- (void)rcr_createStreamPairWithBufferSize:(NSUInteger)bufferSize inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream {
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

@end
