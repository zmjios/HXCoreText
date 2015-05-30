//
//  NSTextCheckingResult+HXLinkType.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "NSTextCheckingResult+HXLinkType.h"
#import <objc/runtime.h>

@implementation NSTextCheckingResult (HXLinkType)

static char hxLinkType;

-(BOOL)urlLink
{
    NSNumber *isUrlLink =  objc_getAssociatedObject(self, &hxLinkType);
    return [isUrlLink boolValue];
}

-(void)setUrlLink:(BOOL)urlLink
{
    objc_setAssociatedObject(self, &hxLinkType, [NSNumber numberWithBool:urlLink], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
