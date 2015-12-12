//
//  ViewController.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Just a subtle background color
    [self.view setBackgroundColor:
     [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
    
    // A simple button to launch the demo
    UIButton *launchDialog = [UIButton buttonWithType:UIButtonTypeCustom];
    [launchDialog
     setFrame:CGRectMake(10, 30, self.view.bounds.size.width - 20, 50)];
    [launchDialog addTarget:self
                     action:@selector(launchDialog2:)
           forControlEvents:UIControlEventTouchDown];
    [launchDialog setTitle:@"Launch Dialog" forState:UIControlStateNormal];
    [launchDialog setBackgroundColor:[UIColor whiteColor]];
    [launchDialog setTitleColor:[UIColor blueColor]
                       forState:UIControlStateNormal];
    [launchDialog.layer setBorderWidth:0];
    [launchDialog.layer setCornerRadius:5];
    [self.view addSubview:launchDialog];
}

- (IBAction)launchDialog:(id)sender {
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    //    [alertView setContainerView:[self createDemoView]];
    [alertView setIcon:[UIImage imageNamed:@"WeChat"]];
    [alertView setTitle:@"请"
     @"耐心等待请耐心等待请耐心等待请耐心等待"];
    [alertView setSubTitle:@"服"
     @"务器故障服务器故障服务器故障服务器故障服务器故障服"
     @"务器故障服务器故障服务器故障服务器故障故障服务器故"
     @"障服务器故障服务器故障服务器"];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray
                                arrayWithObjects:@"关闭订单",
                                @"顾客已付款", nil]];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView,
                                          int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.",
              buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

- (IBAction)launchDialog2:(id)sender {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc]
                                     initWithTitle:@"请耐心等待"
                                     icon:[UIImage imageNamed:@"WeChat"]
                                     subTitle:@"服"
                                     @"务器故障服务器故障服务器故障服务器故障服务器故障"
                                     @"服务器故障服务器故障服务器故障服务器故障故障服务"
                                     @"器故障服务器故障服务器故障服务器"
                                     buttonTitles:[NSMutableArray arrayWithObjects:@"关闭订单",
                                                   @"顾客已付款",
                                                   nil]
                                     onButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                                         NSLog(@"Block: Button at position %d is clicked on alertView %d.",
                                               buttonIndex, (int)[alertView tag]);
                                         [alertView close];
                                     }];
    
    // And launch the dialog
    [alertView show];
}
- (UIView *)createDemoView {
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    
    //    demoView.backgroundColor = [UIColor whiteColor];
    //    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
    //    [imageView setImage:[UIImage imageNamed:@"demo"]];
    //    [demoView addSubview:imageView];
    
    return demoView;
}

@end
