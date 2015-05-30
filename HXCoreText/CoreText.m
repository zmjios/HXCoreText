//
//  CoreText.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/31.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "CoreText.h"
#import <CoreText/CoreText.h>


#pragma mark - CTRunDelegate

void deallocCallback(void* ref) {
    CFBridgingRelease(ref);
}

CGFloat ascentCallback(void *ref) {
    
    NSDictionary *attr = (__bridge NSDictionary *)ref;
    NSLog(@"%@", attr[@"key"]);
    
    return 32;
}

CGFloat descentCallback(void* ref) {
    return 0;
}

CGFloat widthCallback(void* ref) {
    return 32;
}

@implementation CoreText

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)drawBorder:(CGRect)rect inContext:(CGContextRef)context {
    CGPathRef rectBorderPath = CGPathCreateWithRect(rect, NULL);
    [[UIColor redColor] setStroke];
    CGContextAddPath(context, rectBorderPath);
    CGContextDrawPath(context, kCGPathStroke);
    CFRelease(rectBorderPath);
}

- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context {
    CGContextFillRect(context, CGRectMake(point.x, point.y, 2, 2));
}

// 先转换坐标系再画点
- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context inRect:(CGRect)rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor yellowColor];
    [self addSubview:view];
    CGPoint pointInSelf = [self convertPoint:point fromView:view];
    [view removeFromSuperview];
    [self drawPoint:pointInSelf inContext:context];
}



- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 可以在翻转坐标系之前也画个红绿色块来对比坐标系Y轴翻转的效果
    CGContextSetRGBFillColor (context, 1, 0, 0, 1);
    CGContextFillRect (context, CGRectMake (100, 100, 100, 100 ));
    CGContextSetRGBFillColor (context, 0, 1, 0, .5);
    CGContextFillRect (context, CGRectMake (150, 205, 100, 100));
    
    // 准备CGPath，用于CTFrame的构造
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat frameOffsetX = 20.0f;
    CGFloat frameOffsetY = 20.0f;
    CGRect textFrame = CGRectInset(self.bounds, frameOffsetX, frameOffsetY);
    CGPathAddRect(path, NULL, textFrame);
    
    [self drawBorder:textFrame inContext:context];
    
    // 装文字的AttributedString
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Our destiny offers not the cup of despair, but the chalice of opportunity. So let us seize it, not in fear, but in gladness.——R.M. Nixon" attributes:@{NSForegroundColorAttributeName: [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:22]}];
    
    // 构造CTRunDelegate，用以给占着图片位置的空字符的CTRun作为Delegate，提供这些Run的宽、上下高等
    NSDictionary *attrs = @{@"key": @"vars.me"};
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = deallocCallback;
    imageCallbacks.getDescent = descentCallback;
    imageCallbacks.getAscent = ascentCallback;
    imageCallbacks.getWidth = widthCallback;
    // http://stackoverflow.com/a/12919404/1108052
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (void *)CFBridgingRetain(attrs)); // 第二个参数就是传给callBack函数的void *类型的参数
    
    // 随机构造几个装有图片占位符的AttributedString，插入到上面装文字的AttributedString中
    unichar space = 0xFFFC; // 图片占位符，为什么用0xFFFC下述详情
    NSString *spaceStr = [NSString stringWithCharacters:&space length:1];
    // 装有图片占位符的AttributedString，注意，其属性中有一个@"imageName"属性，这是我们区别一个Run是否是图片Run的标识，见下面遍历每行Run部分
    NSMutableAttributedString *imageStr = [[NSMutableAttributedString alloc] initWithString:spaceStr attributes:@{(NSString *)kCTRunDelegateAttributeName: (__bridge id)runDelegate, @"imageName": @"link.png"}];
    [str insertAttributedString:imageStr atIndex:5];
    [str insertAttributedString:imageStr atIndex:55];
    [str insertAttributedString:imageStr atIndex:75];
    [str insertAttributedString:imageStr atIndex:105];
    [str insertAttributedString:imageStr atIndex:135];
    
    // 构造CTFrame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)str);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, str.length), path, NULL);
    
    // 得到Frame中的每一行，装在一个CFArray里
    CFArrayRef lines = CTFrameGetLines(frame);
    
    // 得到每一行的Line Origin（见上述知识储备部分），用以计算每一行的图片位置，注意，得到的点是以CTFrame为坐标系的坐标
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    // 下面遍历Frame中的每一行，逐行绘制图片
    for (CFIndex i = 0; i < CFArrayGetCount(lines); ++i) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
       // [self drawPoint:lineOrigins[i] inContext:context inRect:textFrame];
        
        // 得到这行中的所有CTRun，状态一个CFArray里
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        // 遍历这行所有Run
        for (CFIndex j = 0; j < CFArrayGetCount(runs); ++j) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *attrs = (NSDictionary *)CTRunGetAttributes(run);
            
            // 如果某个Run的@"imageName"属性不为空，则说明这个Run是图片占位符，开始计算这个Run的位置，用CG画图
            NSString *imageName = attrs[@"imageName"];
            if (imageName) {
                CGPoint lineOrigin = lineOrigins[i];
                
                CGRect imageRunBounds; // 注意：得到的imageRun的bounds，也是在CTFrame坐标系中
                CGFloat imageRunAsent, imageRunDecent;
                imageRunBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &imageRunAsent, &imageRunDecent, NULL);
                imageRunBounds.size.height = imageRunAsent + imageRunDecent;
                imageRunBounds.origin.x = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                imageRunBounds.origin.y = lineOrigin.y;
                
                // 开始画图
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    // 注意：画图时由于是在当前View的Context中，因此我们要根据CTFrame坐标系中的imageRunBounds，转换成在View坐标系的imageDrawRect
                    CGRect imageDrawRect;
                    imageDrawRect.origin.x = imageRunBounds.origin.x + lineOrigin.x + frameOffsetX;
                    imageDrawRect.origin.y = imageRunBounds.origin.y +  frameOffsetY;
                    imageDrawRect.size = imageRunBounds.size;
                    
                    // 用CG画图
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                    
                    [self drawBorder:imageDrawRect inContext:context];
                }
            }
        }
    }
    
    
    CGContextDrawImage(context, CGRectMake(30, 50, 60, 30), [UIImage imageNamed:@"link"].CGImage);
    
    CTFrameDraw(frame, context);
    
    CFRelease(runDelegate);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
