//
//  HXCoreTextView.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "HXCoreTextView.h"
#import <CoreText/CoreText.h>
#import "NSTextCheckingResult+HXLinkType.h"
#import "HXCoreTextManager.H"
#import "HXURLLink.h"

#define URLREG @"(((http|ftp|https)\\://)|(www\\.|WWW\\.))[^\\[\\]\u4e00-\u9fa5\\s]*"

/* Callbacks */
static void deallocCallback( void* ref ){
    CFRelease(ref);
}
static CGFloat ascentCallback( void *ref ){
    return [[(__bridge NSDictionary*)ref objectForKey:@"ascent"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}


@interface HXCoreTextView ()

@property(nonatomic, strong) NSMutableArray *links;   //所有的url的链接
@property(nonatomic, strong) NSMutableArray *images;  //图片表情数组

@property(nonatomic,strong)NSMutableAttributedString *attrString;

@property(nonatomic, strong)NSString *forCopyText;
@property(nonatomic, strong)NSString *forTruncating;

@end



@implementation HXCoreTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        self.backgroundColor=[UIColor clearColor];
        self.font = [UIFont systemFontOfSize:15.0];
        self.textColor = [UIColor blackColor];
        self.highlightBackground = YES;
        
        self.userInteractionEnabled=YES;
        
//        UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed)];
//        [self addGestureRecognizer:longPress];
        
        self.enableURL = YES;
        self.images = [NSMutableArray array];
        self.links = [NSMutableArray array];

    }
    
    
    return self;
}


-(void)setFont:(UIFont *)font
{
    _font=font;
    [self setNeedsDisplay];
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor=textColor;
    [self setNeedsDisplay];
}


-(void)setText:(NSString *)str
{
    _text=str;
    self.backgroundColor=[UIColor clearColor];
    [self setNeedsDisplay];
}


- (void)generateAttributedString
{
    [self.images removeAllObjects];
    [self.links removeAllObjects];
    
    if (!_text) {
        self.attrString=nil;
        self.forTruncating=nil;
        return;
    }
    
    NSDictionary *fontcolorDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (id)self.textColor.CGColor,(NSString *)kCTForegroundColorAttributeName,
                                  nil];
    
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc]initWithString:@""];
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"\\[(.*?)\\]"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    
    NSArray *chunksImages=[regex matchesInString:_text options:0 range:NSMakeRange(0, _text.length)];
    
    regex = [[NSRegularExpression alloc]
             initWithPattern:URLREG
             options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
             error:nil];
    NSArray *chunksLinks=[regex matchesInString:_text options:0 range:NSMakeRange(0, _text.length)];
    
    [chunksLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSTextCheckingResult *r=obj;
        r.urlLink = YES;
    }];
    
    
    NSMutableArray *chunks = [NSMutableArray arrayWithArray:chunksImages];
    [chunks addObjectsFromArray:chunksLinks];
    //排序
    [chunks sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSTextCheckingResult *res1=obj1;
        NSTextCheckingResult *res2=obj2;
        return res1.range.location-res2.range.location;
        
    }];
    
    NSLog(@"chunks = %@",chunks);
    
    @try
    {
        CFIndex index = 0;
        NSArray *allImages = [[HXCoreTextManager sharedInstance] getAllImageNameList];
        
        for (NSTextCheckingResult *r in chunks)
        {
            [temp appendAttributedString:[[NSAttributedString alloc]initWithString:[_text substringWithRange:NSMakeRange(index, r.range.location-index)] attributes:fontcolorDic]];
            __block NSNumber *ascent;
            __block NSNumber *descent;
            __block NSNumber *width;
            __block NSNumber *height;
            
            NSString *fileName = @"";
            
            // Character to use as recommended by kCTRunDelegateAttributeName documentation.
            // use " " will lead to wrong width in CTFramesetterSuggestFrameSizeWithConstraints
            unichar objectReplacementChar = 0xFFFC;
            NSString * objectReplacementString = [NSString stringWithCharacters:&objectReplacementChar length:1];
            
            if (r.urlLink)
            {
                ascent = @13;
                descent = @2;
                width = @62;
                height = @15;
                fileName = @"link.png";
                
                HXURLLink *link = [[HXURLLink alloc] init];
                link.range = NSMakeRange(temp.length, 1);
                NSString *url=[_text substringWithRange:r.range];
                if (![url hasPrefix:@"http://"]&&![url hasPrefix:@"https://"]) {
                    url =[NSString stringWithFormat:@"http://%@",url];
                }
                link.url = [NSURL URLWithString:url];
                [_links addObject:link];
            }else
            {
                ascent = [NSNumber numberWithFloat:self.font.ascender];
                descent = [NSNumber numberWithFloat:-self.font.descender];
                width = [NSNumber numberWithFloat:self.font.ascender-self.font.descender];
                height = [NSNumber numberWithFloat:self.font.ascender-self.font.descender];
                
                //图片用 “[“微笑”]”识别
                NSString *faceText = [_text substringWithRange:NSMakeRange(r.range.location, r.range.length)];
                fileName = [[HXCoreTextManager sharedInstance] findImageWithFaceText:faceText];
                
                
                if (![allImages containsObject:fileName])
                {
                    [temp appendAttributedString:[[NSAttributedString alloc] initWithString:[_text substringWithRange:r.range]attributes:fontcolorDic]];
                    index = r.range.location + r.range.length;
                    continue;
                }
            }
            
            [self.images addObject:@{@"width":width,
                                     @"height":height,
                                     @"fileName":fileName,
                                     @"location":[NSNumber numberWithInteger:temp.length]}
             ];
            
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            callbacks.dealloc = deallocCallback;
            
            NSDictionary *imgAttr = @{@"width":width,
                                      @"ascent":ascent,
                                      @"descent":descent
                                      };
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)imgAttr);
            NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    //set the delegate
                                                    (__bridge id)runDelegate, (NSString*)kCTRunDelegateAttributeName,
                                                    (id)[UIColor clearColor].CGColor,(NSString *)kCTForegroundColorAttributeName,
                                                    nil];
            
            //add a space to the text so that it can call the delegate
            [temp appendAttributedString:[[NSAttributedString alloc] initWithString:objectReplacementString attributes:attrDictionaryDelegate]];
            CFRelease(runDelegate);
            index = r.range.location + r.range.length;
        }
        
        [temp appendAttributedString:[[NSAttributedString alloc] initWithString:[_text substringFromIndex:index]attributes:fontcolorDic]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"!!!!NSATTRIBUTESTRING ERROR");
    }
    @finally {
        
    }
    
    //设置字体
    CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    [temp addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:NSMakeRange(0,temp.length)];
    CFRelease(aFont);
    
    CTTextAlignment alighment=kCTLeftTextAlignment;
    CGFloat linespace=1;
    CGFloat lineHeight=self.font.lineHeight;
    CTParagraphStyleSetting settings[5]={
        {kCTParagraphStyleSpecifierAlignment,sizeof(alighment),&alighment},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&linespace},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &lineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &lineHeight},
        //{kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&linebreakmode}
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(settings[0]));
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)paragraphStyle,(__bridge NSString *)kCTParagraphStyleAttributeName, nil];
    
    [temp addAttributes:attrDictionary range:NSMakeRange(0, [temp length])];
    CFRelease(paragraphStyle);
    
    self.attrString = temp;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //翻转坐标系
    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
//    [self.backgroundColor set];
//    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    [self generateAttributedString];
    if (!self.attrString) {
        return;
    }
    
    // 准备CGPath，用于CTFrame的构造
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    
    // 构造CTFrame
    CTFramesetterRef framersetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attrString);
    CFRange fitRange;
    
    //限制frame
    CTFramesetterSuggestFrameSizeWithConstraints(framersetter, CFRangeMake(0, 0), NULL, rect.size, &fitRange);
    CTFrameRef ctframe = CTFramesetterCreateFrame(framersetter, CFRangeMake(0, self.attrString.length), path, NULL);
    CTFrameDraw(ctframe, context);
    
    // 得到Frame中的每一行，装在一个CFArray里
    NSArray *lines=(NSArray *)CTFrameGetLines(ctframe);
    
    // 得到每一行的Line Origin（行原点），用以计算每一行的图片位置，注意，得到的点是以CTFrame为坐标系的坐标
    CGPoint lineOrigins[[lines count]];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), lineOrigins);
    
    if (self.images && self.images.count)
    {
        int imageIndex = 0;
        NSDictionary *image = [self.images objectAtIndex:imageIndex];
        int imgLocation = [[image objectForKey:@"location"] intValue];
        
        NSUInteger lineIndex = 0;
        
        // 下面遍历Frame中的每一行，逐行绘制图片
        for (id lineObj in lines)
        {
            CTLineRef line=(__bridge CTLineRef)lineObj;
            // 得到这行中的所有CTRun，状态一个CFArray里
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            
            for (CFIndex j = 0; j < CFArrayGetCount(runs); j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                CFRange runRange = CTRunGetStringRange(run);
                if (runRange.location <= imgLocation && runRange.location + runRange.length > imgLocation) {
                    
                    CGRect imageRunBounds;
                    CGFloat ascent;
                    CGFloat descent;
                    CGPoint lineOrigin = lineOrigins[j];
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                    
                    imageRunBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    imageRunBounds.size.height = ascent + descent;
                    imageRunBounds.origin.x = lineOrigin.x + xOffset;
                    imageRunBounds.origin.y = lineOrigin.y;
                    
//                    imageRunBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &ascent, &descent, NULL);
//                    imageRunBounds = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - descent, imageRunBounds.size.width, ascent + descent);
                    
                    UIImage *drawImage = [UIImage imageNamed:[image objectForKey:@"fileName"]];
                    
                    if (drawImage) {
                         // 注意：画图时由于是在当前View的Context中，因此我们要根据CTFrame坐标系中的imageRunBounds，转换成在View坐标系的imageDrawRect
                        CGRect imageDrawRect;
                        
                        imageDrawRect.origin.x = imageRunBounds.origin.x;
                        imageDrawRect.origin.y = imageRunBounds.origin.y;
                        //imageDrawRect.origin.y -= descent;
                        imageDrawRect.size = imageRunBounds.size;
                        
//                        imageDrawRect.origin.x = imageRunBounds.origin.x + lineOrigin.x;
//                        imageDrawRect.origin.y = lineOrigin.y;
                        
                        //开始绘图
                        CGContextDrawImage(context, imageDrawRect, drawImage.CGImage);
                    }
            
                    imageIndex++;
                    if (imageIndex < self.images.count) {
                        image = [self.images objectAtIndex:imageIndex];
                        imgLocation = [[image objectForKey:@"location"] intValue];
                        
                    }else{
                        break;
                    }
                }
                
            }
            lineIndex++;
        }
        
    }
    
    
    CGContextDrawImage(context, CGRectMake(320, 50, 60, 30), [UIImage imageNamed:@"link"].CGImage);
    
    
    
    
    CFRelease(ctframe);
    CFRelease(path);
    CFRelease(framersetter);

}




@end
