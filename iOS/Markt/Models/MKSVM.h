//
//  MKSVM.h
//  Markt
//
//  Created by Xin Wang on 6/4/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKSVM : NSObject
- (NSInteger)predict:(NSArray *)probs;
@end
