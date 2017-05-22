//
//  ViewController.m
//  LifePlayer
//
//  Created by familymrfan on 2017/5/15.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import <GCDWebUploader.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

static NSString* cellIdentifiler = @"cellIdentifiler";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) GCDWebUploader* webServer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
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
    
    // start server
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    [self.webServer start];
    
    self.title = [self getIPAddress];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSArray *)getFilenamelist
{
    NSMutableArray *filenamelist = [NSMutableArray array];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    
    for (NSString *filename in fileList) {
        [filenamelist  addObject:filename];
    }
    return filenamelist;
}

# pragma marks data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getFilenamelist] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler];
    [[cell textLabel] setText:[[self getFilenamelist] objectAtIndex:indexPath.row]];;
    return cell;
}

- (IBAction)reloadList:(id)sender {
    [self.tableView reloadData];
}

# pragma marks table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* path = [documentsPath stringByAppendingPathComponent:[[self getFilenamelist] objectAtIndex:indexPath.row]];

    PlayerViewController* vc = [[PlayerViewController alloc] initWithPath:path];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
