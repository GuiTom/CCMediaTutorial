//
//  TriangleViewController.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/11.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "TriangleViewController.h"

#import "TriangleView.h"
@interface TriangleViewController ()

@end

@implementation TriangleViewController
-(void)loadView{
    self.view = [TriangleView new];
     NSLog(@"%s",__FUNCTION__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     NSLog(@"%s",__FUNCTION__);
    self.view.backgroundColor = [UIColor lightGrayColor];
    

}

@end
