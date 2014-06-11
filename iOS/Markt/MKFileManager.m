//
//  MKFileManager.m
//  Markt
//
//  Created by Xin Wang on 5/14/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKFileManager.h"

@interface MKFileManager ()
@property (strong, nonatomic) NSString *filePath;
@end


@implementation MKFileManager

- (id)initWithFileName:(NSString *)filename
{
    self = [super init];
    if (self) {
        NSError *error;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        
        if (![fileManager fileExistsAtPath:documentsDirectory]) {
            [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        if (error) {
            NSLog(@"Create directory error: %@", error.localizedDescription);
        }
        
        self.filePath = [documentsDirectory stringByAppendingPathComponent:filename];
        NSLog(@"%@", self.filePath);
    }
    return self;
}

- (BOOL)write:(NSString *)content append:(BOOL)append
{
    NSAssert(self.filePath != nil, @"filePath must exist");
    NSError *error;
    if (append) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
        [handle seekToEndOfFile];
        [handle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        [content writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    if (error) {
        NSLog(@"Write error: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

- (NSString *)readAll
{
    NSAssert(self.filePath != nil, @"filePath must exist");
    NSError *error;
    NSString *dataString = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Read file error: %@", error.localizedDescription);
    }
    return dataString;
}


@end
