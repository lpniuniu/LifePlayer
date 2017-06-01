//
//  UploaderViewController.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/31.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "UploaderViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <Masonry.h>

@interface UploaderViewController ()

@property (nonatomic) UILabel* ipLabel;
@property (nonatomic) UILabel* descriptionLabel;

@end

@implementation UploaderViewController

- (NSString *)getIPAddress {
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"上传视频";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.ipLabel = [[UILabel alloc] init];
    [self.view addSubview:self.ipLabel];
    [self.ipLabel setTextColor:[UIColor orangeColor]];
    [self.ipLabel setFont:[UIFont boldSystemFontOfSize:20]];

    NSString* ipAndPort = nil;
    if ([self getIPAddress]) {
        ipAndPort = [NSString stringWithFormat:@"http://%@:80/", [self getIPAddress]];
    } else {
        ipAndPort = @"获取IP失败，请连接wifi";
    }
    [self.ipLabel setText:ipAndPort];
    [self.ipLabel sizeToFit];
    [self.ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-self.ipLabel.frame.size.height*3);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(self.ipLabel.frame.size.width));
        make.height.equalTo(@(self.ipLabel.frame.size.height));
    }];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.descriptionLabel];
    [self.descriptionLabel setText:@"在电脑浏览器地址栏输入上面地址，打开上传页面\n\n 为保证上传不中断，\n本页面已帮您的手机暂时处于激活状态"];
    [self.descriptionLabel setFont:[UIFont systemFontOfSize:14]];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ipLabel.mas_bottom).offset(5);
        make.centerX.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
