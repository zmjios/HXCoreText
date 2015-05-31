//
//  HXCoreTextView.h
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXURLLink.h"

@protocol HXCoreTextViewDelegate;
@interface HXCoreTextView : UIView

@property(nonatomic,strong)NSString *text;
@property(nonatomic,strong)UIFont  *font;            // default is [UIFont systemFontOfSize:15.0]
@property(nonatomic,strong)UIColor *textColor;       // default is [UIColor blackColor]

@property(nonatomic,assign)BOOL highlightBackground; //default is YES
@property(nonatomic,assign)BOOL enableURL;

@property(nonatomic,weak) id<HXCoreTextViewDelegate> delegate;



//获取绘制大小
-(CGSize)sizeAttributedWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end


@protocol HXCoreTextViewDelegate <NSObject>

@optional
- (void)didTouchInCoreTextView:(HXCoreTextView *)coreTextView withUrlLink:(HXURLLink *)link;

@end
