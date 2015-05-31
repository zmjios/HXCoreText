//
//  ViewController.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "ViewController.h"
#import "HXCoreTextView.h"

@interface ViewController ()<HXCoreTextViewDelegate>


@property (nonatomic, strong) HXCoreTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    self.textView = [[HXCoreTextView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 400)];
    self.textView.text = @"我爱你，真的好[难过]啊，详情,谁能拯救我们,[流汗][流泪][流弊],这么说基督教的呵呵呵的很多很多 \n womendehttps://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html,Beautiful Soup 是一个可以从HTML或XML文件中提取数据的Python库.它能够通过你喜欢的转换器实现惯用的文档导航,查找,修改文档的方式.Beautiful Soup会帮你节省数小时甚至数天的工作时间.这篇文档介绍了BeautifulSoup4中所有主要特性,并且有小例子.让我来向你展示它适合做什么,如何工作,怎样使用,如何达到你想要的效果,和处理异常情况.文档中出现的例子在Python2.7和Python3.2中的执行结果相同你可能在寻找 Beautiful Soup3 的文档,Beautiful Soup 3 目前已经停止开发,我们推荐在现在的项目中使用Beautiful Soup 4, 移植到BS4";
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.textView];
    
    
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGSize size = [self.textView sizeThatFits:self.textView.frame.size];
        CGRect textFrame = self.textView.frame;
        textFrame.size = size;
        self.textView.frame = textFrame;
        [self.textView setNeedsDisplay];
    });
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didTouchInCoreTextView:(HXCoreTextView *)coreTextView withUrlLink:(HXURLLink *)link
{
    if (link.url.absoluteString && link.url.absoluteString.length) {
        [[UIApplication sharedApplication] openURL:link.url];
    }
}

@end
