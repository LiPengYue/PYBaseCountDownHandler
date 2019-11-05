//
//  PYViewController.m
//  PYBaseCountDownHandler
//
//  Created by LiPengYue on 08/13/2019.
//  Copyright (c) 2019 LiPengYue. All rights reserved.
//

#import "PYViewController.h"

@interface PYViewController ()
/// UIViewController
@property (nonatomic,strong) UIButton *button;
@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.button];
    self.button.frame = CGRectMake(100, 100, 300, 100);
    self.button.layer.borderColor = UIColor.redColor.CGColor;
    self.button.layer.borderWidth = 1;
    self.button.layer.cornerRadius = 6;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// button
- (UIButton *) button {
    if (!_button) {
        _button = [UIButton new];
        [_button setTitle:@"跳转到CountDown" forState:UIControlStateNormal];
        
        [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        [_button addTarget:self action:@selector(click_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (void) click_buttonAction:(UIButton *)button {
    UIViewController *vc = [NSClassFromString(@"PYCountDownViewController") new];
    [self presentViewController:vc animated:true completion:nil];
}
@end
