//
//  MyVideoPlayerVC.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/7/23.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "MyVideoPlayerVC.h"
#import "VideoPlayerViewController.h"
NSString * const MIN_BUFFERED_DURATION = @"Min Buffered Duration";
NSString * const MAX_BUFFERED_DURATION = @"Max Buffered Duration";
@interface MyVideoPlayerVC ()<PlayerStateDelegate>
@property(nonatomic,strong)VideoPlayerViewController *player;
@end

@implementation MyVideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupSubviews];
}
-(void)setupSubviews{
    NSDictionary *requestHeaser = @{
        MIN_BUFFERED_DURATION:@(2.0f),
        MAX_BUFFERED_DURATION:@(4.0f)
    };

    NSString *fileUrl = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.flv"];
    self.player = [[VideoPlayerViewController alloc] initWithContentPath:fileUrl contentFrame:self.view.frame usingHWCodec:NO playerStateDelegate:self parameters:requestHeaser];
    [self.view addSubview:self.player.view];
    self.player.view.backgroundColor = [UIColor redColor];
}
- (IBAction)onClickPlayButton:(id)sender {
    [self.player play];
}
- (IBAction)onSwitcherChanged:(UISwitch *)sender {
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
