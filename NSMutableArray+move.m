//
//  NSMutableArray+move.m
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/08.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import "NSMutableArray+move.h"

@implementation NSMutableArray (move)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}

@end
