//
//  SingleFilterVC.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/30.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "SingleFilterVC.h"
#import "OneFilterImageView.h"
@interface SingleFilterVC ()

@end

@implementation SingleFilterVC
-(void)loadView{
    self.view = [OneFilterImageView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    ((OneFilterImageView*)self.view).sauration = 1.0f;
    // Do any additional setup after loading the view.
    [self setUpSubViews];
}
-(void)setUpSubViews{
    UISlider *slider = [[UISlider alloc] init];
    slider.frame = CGRectMake(0, 100, 300, 30);
    slider.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(onSlide:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = 1;
    slider.minimumValue = 0;
    
}
-(void)onSlide:(UISlider*)slider{
    
    [((OneFilterImageView*)self.view) setSauration:slider.value];
    [((OneFilterImageView*)self.view) renderLayer];
}

@end
