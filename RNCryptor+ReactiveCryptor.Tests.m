//
//  RNCryptor+ReactiveCryptor.Tests.m
//  ReactiveCryptor
//
//  Created by Nathan Douglas on 12/8/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "ReactiveCryptor.h"
#import "RCRTestDefinitions.h"

@interface RNCryptor_ReactiveCryptorTests : XCTestCase {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *testString;
    NSData *testData;
}

@end

@implementation RNCryptor_ReactiveCryptorTests

- (void)setUp {
	[super setUp];
    testString = [[NSUUID UUID] UUIDString];
    testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    inputStream = [[NSInputStream alloc] initWithData:testData];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
    outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStream open];
}

- (void)tearDown {
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    inputStream = nil;
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    outputStream = nil;
	[super tearDown];
}

- (NSData *)dataInOutputStream:(NSOutputStream *)anOutputStream {
    return [anOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

- (void)testTrivialFunctionality {
	[outputStream write:testData.bytes maxLength:testData.length];
    XCTAssertEqualObjects([self dataInOutputStream:outputStream], testData);
    NSError *error = nil;
    NSData *synchronouslyEncryptedData = [RNEncryptor encryptData:testData withSettings:kRNCryptorAES256Settings password:@"password" error:&error];
    NSData *synchronouslyDecryptedData = [RNDecryptor decryptData:synchronouslyEncryptedData withPassword:@"password" error:NULL];
    XCTAssertEqualObjects(synchronouslyDecryptedData, testData, @"Error: %@", error);
}

- (void)testConnectInputStreamOutputStreamBufferSize {
    RNEncryptor *encryptor = [[RNEncryptor alloc] initWithSettings:kRNCryptorAES256Settings password:@"password" handler:^(RNCryptor *cryptor, NSData *data) { }];
    NSInputStream *inputStreamA = [[NSInputStream alloc] initWithData:testData];
    [inputStreamA scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStreamA open];
    NSOutputStream *outputStreamA = [NSOutputStream outputStreamToMemory];
    [outputStreamA scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStreamA open];
    [[encryptor rcr_connectInputStream:inputStreamA outputStream:outputStreamA bufferSize:32 * 1024]
    subscribeNext:^(id x) {
        NSLog(@"Next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Error: %@", error);
    } completed:^{
        NSLog(@"Completed!");
    }];
    [self rcr_expectCondition:^BOOL {
        return [[self dataInOutputStream:outputStreamA] length] > 0;
    } beforeTimeout:5.0 interval:0.1 description:@"data was encrypted"];
    XCTAssertEqualObjects([RNDecryptor decryptData:[self dataInOutputStream:outputStreamA] withPassword:@"password" error:NULL], testData);
}

- (void)testConnectInputStreamOutputStreamBufferSize2 {
    NSData *synchronouslyEncryptedData = [RNEncryptor encryptData:testData withSettings:kRNCryptorAES256Settings password:@"password" error:NULL];
    __block NSData *decryptedData = nil;
    RNDecryptor *decryptor = [[RNDecryptor alloc] initWithPassword:@"password" handler:^(RNCryptor *cryptor, NSData *data) { }];
    NSInputStream *inputStreamB = [[NSInputStream alloc] initWithData:synchronouslyEncryptedData];
    [inputStreamB scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStreamB open];
    NSOutputStream *outputStreamB = [[NSOutputStream alloc] initToMemory];
    [outputStreamB scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStreamB open];
    [[decryptor rcr_connectInputStream:inputStreamB outputStream:outputStreamB bufferSize:32 * 1024]
    subscribeNext:^(id x) {
        NSLog(@"Decryptor received next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Decryptor received error: %@", error);
    } completed:^{
        NSLog(@"Decryptor completed!");
    }];
    [self rcr_expectCondition:^BOOL {
        decryptedData = [self dataInOutputStream:outputStreamB];
        return decryptedData.length > 0;
    } beforeTimeout:5.0 interval:0.1 description:@"data was decrypted"];
    XCTAssertEqualObjects([[NSString alloc] initWithData:[self dataInOutputStream:outputStreamB] encoding:NSUTF8StringEncoding], testString);
}

- (void)testConnectInputStreamOutputStreamBufferSize3 {
    __block NSData *encryptedData = nil;
    RNEncryptor *encryptor = [[RNEncryptor alloc] initWithSettings:kRNCryptorAES256Settings password:@"password" handler:^(RNCryptor *cryptor, NSData *data) { }];
    NSInputStream *inputStreamA = [[NSInputStream alloc] initWithData:testData];
    [inputStreamA scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStreamA open];
    NSOutputStream *outputStreamA = [[NSOutputStream alloc] initToMemory];
    [outputStreamA scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStreamA open];
    [[encryptor rcr_connectInputStream:inputStreamA outputStream:outputStreamA bufferSize:32 * 1024]
    subscribeNext:^(id x) {
        NSLog(@"Encryptor received next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Encryptor received error: %@", error);
    } completed:^{
        NSLog(@"Encryptor completed!");
    }];
    [self rcr_expectCondition:^BOOL {
        encryptedData = [self dataInOutputStream:outputStreamA];
        return encryptedData.length > 0;
    } beforeTimeout:5.0 interval:0.1 description:@"data was encrypted"];
    __block NSData *decryptedData = nil;
    RNDecryptor *decryptor = [[RNDecryptor alloc] initWithPassword:@"password" handler:^(RNCryptor *cryptor, NSData *data) { }];
    NSInputStream *inputStreamB = [[NSInputStream alloc] initWithData:encryptedData];
    [inputStreamB scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStreamB open];
    NSOutputStream *outputStreamB = [[NSOutputStream alloc] initToMemory];
    [outputStreamB scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStreamB open];
    [[decryptor rcr_connectInputStream:inputStreamB outputStream:outputStreamB bufferSize:32 * 1024]
    subscribeNext:^(id x) {
        NSLog(@"Decryptor received next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Decryptor received error: %@", error);
    } completed:^{
        NSLog(@"Decryptor completed!");
    }];
    [self rcr_expectCondition:^BOOL {
        decryptedData = [self dataInOutputStream:outputStreamB];
        return decryptedData.length > 0;
    } beforeTimeout:5.0 interval:0.1 description:@"data was decrypted"];
    XCTAssertEqualObjects([[NSString alloc] initWithData:[self dataInOutputStream:outputStreamB] encoding:NSUTF8StringEncoding], testString);
}

- (void)testAfterOpeningStreamConnectionInputStreamOutputStreamBufferSize {
    
}

@end

/**
- (RACSignal *)rcr_afterOpeningStream:(NSStream *)openingStream connectInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
- (RACSignal *)rcr_processInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize;
- (RACSignal *)rcr_processOutputStream:(NSOutputStream *)outputStream bufferSize:(NSUInteger)bufferSize;
*/
