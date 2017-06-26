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
#import "UploaderViewController.h"
#import "PlayerBarView.h"
#import "TopBarView.h"
#import "AppDelegate.h"

#import <GCDWebUploader.h>
#import <Bulb.h>
#import <AVFoundation/AVFoundation.h>
#import <PINCache.h>
#import <Masonry.h>

@implementation BulbFileNameSignal


@end

@implementation BulbV6Url

@end

static NSString* cellIdentifiler = @"cellIdentifiler";
static NSString* kLastMovieCahce = @"kLastMovieCahce";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, GCDWebUploaderDelegate>

@property (nonatomic) GCDWebUploader* webServer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // start server
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    self.webServer.header = @"念念Player";
    self.webServer.prologue = @"拖放文件到此窗口上或使用“上传文件...”按钮";
    self.webServer.delegate = self;
    [self.webServer start];
    
    self.title = @"本地视频";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[PlayerTableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    [[Bulb bulbGlobal] registerSignal:[[BulbOpenUrlSignal signalDefault] pickOffFromHungUp] block:^BOOL(NSURL* url, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSError* error = nil;
        NSString* destPath = [documentsPath stringByAppendingPathComponent:[url lastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtURL:[url filePathURL] toURL:[NSURL fileURLWithPath:destPath] error:&error];
        NSLog(@"copy open url error %@", error);
        NSString* fileInInbox = [[documentsPath stringByAppendingPathComponent:@"Inbox"] stringByAppendingPathComponent:[url lastPathComponent]];
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:fileInInbox] error:&error];
        [self.tableView reloadData];
        return YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary* dict = [[PINCache sharedCache] objectForKey:kLastMovieCahce];
    if (!dict) {
        [self.continueBtn setTitle:@""];
    } else {
        [self.continueBtn setTitle:@"继续上次收看"];
    }

}
- (IBAction)continue:(id)sender {
    NSDictionary* dict = (NSDictionary *)[[[PINCache sharedCache] diskCache] objectForKey:kLastMovieCahce];
    if (dict) {
        NSString* path = [dict objectForKey:@"path"];
        NSNumber* time = [dict objectForKey:@"time"];
        
        if (path && time) {
            [[self getFilenamelist] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([path containsString:obj]) {
                    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[Bulb bulbGlobal] fire:[BulbChangeTimeSignal signalDefault] data:time];
                    });

                    *stop = YES;
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSMutableArray *)getFilenamelist
{
    NSMutableArray *filenamelist = [NSMutableArray array];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    
    for (NSString *filename in fileList) {
        if ([filename isEqualToString:@"Inbox"]) {
            continue ;
        }
        [filenamelist  addObject:filename];
    }
    return filenamelist;
}

# pragma marks data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.width/655.0 * 333.0;
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
    
    cell.backImageView.image = [UIImage imageNamed:@"video_placeholder"];
    return cell;
}

- (IBAction)upload:(id)sender {
    UploaderViewController* uploader = [[UploaderViewController alloc] init];
    [self.navigationController pushViewController:uploader animated:YES];
}

- (IBAction)refresh:(id)sender {
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
    
    [[Bulb bulbGlobal] registerSignal:[BulbNextSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        
        NSInteger row = tableView.indexPathForSelectedRow.row;
        
        if (row >= [self getFilenamelist].count - 1) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionTop];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Bulb bulbGlobal] fire:[BulbTopBarViewDissmissSignal signalDefault] data:nil];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Bulb bulbGlobal] fire:[BulbTopBarViewDissmissSignal signalDefault] data:^(){
                    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionTop];
                    [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]];
                }];
            });
        }
        return NO;
    }];
}

// 左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* path = [documentsPath stringByAppendingPathComponent:[[self getFilenamelist] objectAtIndex:indexPath.row]];
    
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    NSLog(@"removeItemAtPath error %@", error);
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma marks GCDWebUploaderDelegate methods
/**
 *  This method is called whenever a file has been downloaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDownloadFileAtPath:(NSString*)path
{
    [self.tableView reloadData];
}

/**
 *  This method is called whenever a file has been uploaded.
 */
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path
{
    [self.tableView reloadData];
}

/**
 *  This method is called whenever a file or directory has been moved.
 */
- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath
{
    [self.tableView reloadData];
}

/**
 *  This method is called whenever a file or directory has been deleted.
 */
- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path
{
    [self.tableView reloadData];
}

- (void)webServerDidCompleteBonjourRegistration:(GCDWebServer*)server
{
    [[Bulb bulbGlobal] hungUp:[BulbV6Url signalDefault] data:server.bonjourServerURL];
}

@end
