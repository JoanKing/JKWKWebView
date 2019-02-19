//
//  TestViewController.m
//  JKLaunchAd
//
//  Created by 王冲 on 2018/12/18.
//  Copyright © 2018年 JK科技有限公司. All rights reserved.
//

#import "TestViewController.h"
#import <WebKit/WebKit.h>
#define JKstatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height+44
@interface TestViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (weak, nonatomic) CALayer *progresslayer;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic,strong,readwrite) UIBarButtonItem *returnButton;
@property (nonatomic,strong,readwrite) UIBarButtonItem *closeItem;

@end

@implementation TestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = self.returnButton;

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.jd.com"]]];
    // http://pay.ciotimes.com/index.php/Phone/ActivityCharacter/index
    // http://m.jd.com
    /**
     获取 head 头里面的 meta的shareurl值
     https://tps-test-app.99top.vip/index/groupbuy_detail?snm=534078445
     */
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //开了支持滑动返回（这行代码可以是侧滑返回webView的上一级，而不是根控制器 只针对侧滑有效）
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    //进度条
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, JKstatusBarHeight, CGRectGetWidth(self.view.frame), 3)]; progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor blueColor].CGColor;
    [progress.layer addSublayer:layer];
    self.progresslayer = layer;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark 加载进度的监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        self.progresslayer.opacity = 1;
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue])
        {
            return;
            
        }
        
        self.progresslayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], 3);
        
        if ([change[@"new"] floatValue] == 1)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.progresslayer.opacity = 0;
                
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.progresslayer.frame = CGRectMake(0, 0, 0, 3);
                
            });
        }
        
    }else{
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark 移除加载进度
- (void)dealloc{
    
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    
}


// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{//这里修改导航栏的标题，动态改变
    self.title = webView.title;
    
    // 获取html里面的head里面的meta值 0 是因为 shareUrl 在最前面，后面的shareUrl 1、2、3、4依次排序
    [webView evaluateJavaScript:@"document.getElementsByName(\"shareUrl\")[0].content" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"response: %@ error: %@", response, error);
        
    }];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
 
    
    //获取请求的url路径.
    NSString *requestString = navigationResponse.response.URL.absoluteString;
    NSLog(@"requestString:%@",requestString);
    // 遇到要做出改变的字符串
    NSString *subStr = @"";
    if ([requestString rangeOfString:subStr].location != NSNotFound) {
        NSLog(@"这个字符串中有subStr");
        //回调的URL中如果含有百度，就直接返回，也就是关闭了webView界面
        [self.navigationController  popViewControllerAnimated:YES];
    }
    
    
    NSLog(@"webView==%@",webView);
    
    NSLog(@"navigationResponse=%@",navigationResponse);
    
    WKNavigationResponsePolicy actionPolicy = WKNavigationResponsePolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
    
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    self.title = webView.title;
    
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    
    
    if (navigationAction.navigationType==WKNavigationTypeBackForward) {//判断是返回类型
        
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮 这里可以监听左滑返回事件，仿微信添加关闭按钮。
        self.navigationItem.leftBarButtonItems = @[self.returnButton, self.closeItem];
        //可以在这里找到指定的历史页面做跳转
        //        if (webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
        //            DLog(@"%@",webView.backForwardList.backList);
        //            DLog(@"%@",webView.backForwardList.currentItem);
        //            WKBackForwardListItem * item = webView.backForwardList.currentItem;          //得到现在加载的list
        //            for (WKBackForwardListItem * backItem in webView.backForwardList.backList) { //循环遍历，得到你想退出到
        //                //添加判断条件
        //                [webView goToBackForwardListItem:[webView.backForwardList.backList firstObject]];
        //            }
        //        }
    }
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

//显示一个JS的Alert（与JS交互）
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"弹窗alert");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    //[self.view makeToast:message];
    completionHandler();
}

//弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"弹窗输入框");
    NSLog(@"%@",prompt);
    NSLog(@"%@",defaultText);
    NSLog(@"%@",frame);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //这里必须执行不然页面会加载不出来
        completionHandler(@"");
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",
             [alert.textFields firstObject].text);
        completionHandler([alert.textFields firstObject].text);
    }];
    [alert addAction:a1];
    [alert addAction:a2];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"%@",textField.text);
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

//显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"弹窗确认框");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIBarButtonItem *)returnButton {
    if (!_returnButton) {
        _returnButton = [[UIBarButtonItem alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //UIImage *image = [UIImage imageNamed:@"fanhui.png"];
        //[button setImage:image forState:UIControlStateNormal];//这是一张“<”的图片
        [button setTitle:@" 返回" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(respondsToReturnToBack:) forControlEvents:UIControlEventTouchUpInside];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        button.frame = CGRectMake(20, 0, 40, 40);
        _returnButton.customView = button;
    }
    return _returnButton;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(respondsToReturnToFind:)];
    }
    return _closeItem;
}

- (void)respondsToReturnToBack:(UIButton *)sender {
    if ([self.webView canGoBack]) {//判断当前的H5页面是否可以返回
        //如果可以返回，则返回到上一个H5页面，并在左上角添加一个关闭按钮
        [self.webView goBack];
        self.navigationItem.leftBarButtonItems = @[self.returnButton, self.closeItem];
    } else {
        //如果不可以返回，则直接:
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)respondsToReturnToFind:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
