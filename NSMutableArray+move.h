//
//  NSMutableArray+move.h
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/08.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (move)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end
