//
//  HXCoreTextManager.h
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXCoreTextManager : NSObject


+ (instancetype)sharedInstance;


//获取所有符号表情的图片名称
- (NSArray *)getAllImageNameList;


//根据表情文字找到映射的图片
- (NSString *)findImageWithFaceText:(NSString *)faceText;


@end
