//
//  ViewController.m
//  RACDemo
//
//  Created by 林欣达 on 16/4/15.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
#pragma mark 绑定账户文本信号，并且map成一个NSNumber类型的数据，用来决定密码输入框的enabled属性
    RAC(self.passwordTextField, enabled) = [self.accountTextField.rac_textSignal map: ^id(NSString * text){
        return @(text.length > 3);
    }];
    
#pragma mark 注册文本信号，当文本发生改变的时候回调
    [self.accountTextField.rac_textSignal subscribeNext: ^(NSString * text) {
        if (text.length <= 3) {
            self.passwordTextField.text = @"";
        }
    }];
    
#pragma mark 先将密码文本信号转换成NSNumber，再由NSNumber决定按钮的enabled属性
    [[self.passwordTextField.rac_textSignal map: ^id(NSString * text) {
        return @(text.length > 6);
    }] subscribeNext: ^(NSNumber * passwordVaild) {
        [self.signInButton setEnabled: passwordVaild.boolValue];
    }];
    
#pragma mark 绑定多个信号
    RACSignal * accountVaildSignal = [self.accountTextField.rac_textSignal map: ^id(NSString * text) {
        return @(text.length >= 6);
    }];
    RACSignal * passwordVaildSignal = [self.passwordTextField.rac_textSignal map: ^id(NSString * text) {
        return @(text.length >= 6);
    }];
    RACSignal * signInEnabledSignal = [RACSignal combineLatest: @[accountVaildSignal, passwordVaildSignal]
                                                        reduce: ^id(NSNumber * accountVaild, NSNumber * passwordVaild) {
                                                            return @(accountVaild.boolValue && passwordVaild.boolValue);
                                                        }];
    [signInEnabledSignal subscribeNext: ^(NSNumber * signInEnabled) {
        _signInButton.enabled = signInEnabled.boolValue;
    }];
    
    [[self.signInButton rac_signalForControlEvents: UIControlEventTouchUpInside] subscribeNext: ^(UIButton * sender) {
        NSLog(@"button clicked");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
