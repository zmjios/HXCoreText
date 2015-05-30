//
//  HXCoreTextView.h
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HXCoreTextView : UIView

@property(nonatomic,strong)NSString *text;
@property(nonatomic,strong)UIFont  *font;            // default is [UIFont systemFontOfSize:15.0]
@property(nonatomic,strong)UIColor *textColor;       // default is [UIColor blackColor]

@property(nonatomic,assign)BOOL highlightBackground; //default is YES
@property(nonatomic,assign)BOOL enableURL;



//获取绘制大小
-(CGSize)sizeAttributedWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end
