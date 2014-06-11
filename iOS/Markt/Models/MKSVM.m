//
//  MKSVM.m
//  Markt
//
//  Created by Xin Wang on 6/4/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKSVM.h"
#include "svm.h"
#include <stdlib.h>

@implementation MKSVM

struct svm_model *model;
struct svm_node *x;

- (id)init
{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rssi" ofType:@"model"];
        char const *pathStr = [fileManager fileSystemRepresentationWithPath:filePath];
        model = svm_load_model(pathStr);
        x = (struct svm_node *) malloc(4 * sizeof(struct svm_node));
        if (model == 0) {
            NSLog(@"Loading model error");
        }
    }
    return self;
}

- (NSInteger)predict:(NSArray *)probs
{
    NSAssert([probs count] == 3, @"The probablity array should contain 3 elements");

    x[0].index = 1;
    x[0].value = [probs[0] doubleValue];
    
    x[1].index = 2;
    x[1].value = [probs[1] doubleValue];
    
    x[2].index = 3;
    x[2].value = [probs[2] doubleValue];
    
    x[3].index = -1;
    
    return (NSInteger)svm_predict(model, x);
}

- (void)freeModel
{
    svm_free_and_destroy_model(&model);
    free(x);
}

@end
