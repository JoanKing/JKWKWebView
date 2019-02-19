//
//  ViewController.m
//  JKWKWebView
//
//  Created by 王冲 on 2018/12/18.
//  Copyright © 2018年 JK科技有限公司. All rights reserved.
//

#import "ViewController.h"

#import "TestViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    TestViewController *testViewController = [TestViewController new];
    [self.navigationController pushViewController:testViewController animated:YES];
}

@end
