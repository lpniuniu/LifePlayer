//
//  ViewController.m
//  LifePlayer
//
//  Created by familymrfan on 2017/5/15.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "PlayerTableViewCell.h"

#import <GCDWebUploader.h>
#import <Bulb.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <AVFoundation/AVFoundation.h>

@implementation BulbFileNameSignal


@end

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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[PlayerTableViewCell class] forCellReuseIdentifier:cellIdentifiler];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getFilenamelist] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerTableViewCell* cell = (PlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    [[cell titleLabel] setText:[[self getFilenamelist] objectAtIndex:indexPath.row]];
    
    if ([cell isSelected]) {
        [cell.titleLabel setTextColor:[UIColor orangeColor]];
    } else {
        [cell.titleLabel setTextColor:[UIColor whiteColor]];
    }
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* path = [documentsPath stringByAppendingPathComponent:[[self getFilenamelist] objectAtIndex:indexPath.row]];
    cell.backImageView.image = [self getThumbnailImage:path];
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
    [[Bulb bulbGlobal] hungUp:[BulbFileNameSignal signalDefault] data:[path lastPathComponent]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIImage *)getThumbnailImage:(NSString *)videoPath {
    if (videoPath) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath: videoPath] options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        // 设定缩略图的方向
        // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的
        gen.appliesPreferredTrackTransform = YES;
        // 设置图片的最大size(分辨率)
        gen.maximumSize = CGSizeMake(300, 169);
        CMTime time = CMTimeMakeWithSeconds(5.0, 600); //取第5秒，一秒钟600帧
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            UIImage *placeHoldImg = [UIImage imageNamed:@"video_placeholder"];
            return placeHoldImg;
        }
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    } else {
        UIImage *placeHoldImg = [UIImage imageNamed:@"posters_default_horizontal"];
        return placeHoldImg;
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
