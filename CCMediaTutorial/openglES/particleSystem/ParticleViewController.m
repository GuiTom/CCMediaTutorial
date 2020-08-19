//
//  ParticleViewController.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/8/16.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "ParticleViewController.h"
#import "ParticleView.h"
@interface ParticleViewController ()

@end

@implementation ParticleViewController
-(void)loadView{
    self.view = [ParticleView new];
     NSLog(@"%s",__FUNCTION__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CADisplayLink *link  = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplay:)];
      [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)onDisplay:(id)sender{
    [((ParticleView*)self.view) renderLayer];
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
