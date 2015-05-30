//
//  ViewController.m
//  HXCoreText
//
//  Created by 曾明剑 on 15/5/30.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "ViewController.h"
#import "HXCoreTextView.h"
#import "CoreText.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    HXCoreTextView *textView = [[HXCoreTextView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 400)];
    textView.text = @"我爱你，真的好[难过]啊，详情,谁能拯救我们,[流汗][流泪][流弊],这么说基督教的呵呵呵的很多很多 \n womendehttp://isilic.iteye.com/blog/1741918";
    [self.view addSubview:textView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
