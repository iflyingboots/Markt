//
//  MKFileManager.h
//  Markt
//
//  Created by Xin Wang on 5/14/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKFileManager : NSObject
- (id)initWithFileName:(NSString *)filename;
- (BOOL)write:(NSString *)content append:(BOOL)append;
- (NSString *)readAll;
@end
