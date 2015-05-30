//
//  HXCoreTextManager.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "HXCoreTextManager.h"

@interface HXCoreTextManager ()


@property (nonatomic, strong) NSDictionary *imagesDic;
@property (nonatomic, strong) NSDictionary *mapDic;

@end

@implementation HXCoreTextManager

+ (instancetype)sharedInstance
{
    static HXCoreTextManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HXCoreTextManager alloc] init];
    });
    
    return manager;
}



- (instancetype)init
{
    if (self = [super init])
    {
        
        NSString *plistPath1 = [[NSBundle mainBundle] pathForResource:@"HXTextImages" ofType:@"plist"];
        NSString *plistPath2 = [[NSBundle mainBundle] pathForResource:@"HXImageTextMap" ofType:@"plist"];
        self.imagesDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath1];
        self.mapDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath2];
        
    }
    
    return self;
}


//获取所有符号表情的图片名称
- (NSArray *)getAllImageNameList
{
    NSMutableArray *allImages = [NSMutableArray array];
    
    for (NSString *key in self.imagesDic.allKeys) {
        id obj = [self.imagesDic objectForKey:key];
        if ([obj isKindOfClass:[NSArray class]]) {
            [allImages addObjectsFromArray:obj];
        }
    }
    
    return [NSArray arrayWithArray:allImages];
}


//根据表情文字找到映射的图片
- (NSString *)findImageWithFaceText:(NSString *)faceText
{
    for (NSString *key in self.mapDic.allKeys) {
        NSString *findText = [self.mapDic objectForKey:key];
        if ([findText isEqualToString:faceText]) {
            return key;
        }
    }
    
    
    return nil;
}




@end
