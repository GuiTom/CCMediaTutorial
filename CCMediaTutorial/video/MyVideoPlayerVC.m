//
//  MyVideoPlayerVC.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/7/23.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "MyVideoPlayerVC.h"
#import "VideoPlayerViewController.h"
@interface MyVideoPlayerVC ()<PlayerStateDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playStatusButton;
@property(nonatomic,assign)BOOL useHardWareDecoder;
@end

@implementation MyVideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)swicher:(UISwitch *)sender {
    NSDictionary *params = @{};
    VideoPlayerViewController *pvc = [[VideoPlayerViewController alloc] initWithContentPath:nil contentFrame:self.view.frame usingHWCodec:self.useHardWareDecoder playerStateDelegate:self parameters:params];
    [self.navigationController pushViewController:pvc animated:YES];
}
#pragma mark PlayerStateDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
