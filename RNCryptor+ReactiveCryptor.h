//
//  RNCryptor+ReactiveCryptor.h
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCRDefinitions.h"
#import "RNCryptor.h"

@interface RNCryptor (ReactiveCryptor)
- (RACSignal *)rcr_connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
- (RACSignal *)rcr_afterOpeningStream:(NSStream *)openingStream connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize;
- (RACSignal *)rcr_processOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
@end
