//
//  ImageViewController.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/12.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "ImageViewController.h"

#import "CCImageView.h"
@interface ImageViewController ()

@end

@implementation ImageViewController
-(void)loadView{
    self.view = [CCImageView new];
     NSLog(@"%s",__FUNCTION__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
