//
//  ImageFilterChainVC.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/30.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "ImageFilterChainVC.h"
#import "FilterChainView.h"
@interface ImageFilterChainVC ()

@end

@implementation ImageFilterChainVC
-(void)loadView{
    self.view = [FilterChainView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    ((FilterChainView*)self.view).sauration = 1.0f;
    ((FilterChainView*)self.view).temperature = 1.0f;
    // Do any additional setup after loading the view.
    [self setUpSubViews];
}
-(void)setUpSubViews{
    UISlider *slider = [[UISlider alloc] init];
    slider.frame = CGRectMake(20, 100, 300, 30);
    slider.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(onSlide:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = 1;
    slider.minimumValue = 0;
    slider.tag = 1;
    slider.value = 1;
    UISlider *slider2 = [[UISlider alloc] init];
    slider2.frame = CGRectMake(20, 200, 300, 30);
    slider2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:slider2];
    [slider2 addTarget:self action:@selector(onSlide:) forControlEvents:UIControlEventValueChanged];
    slider2.maximumValue = 1;
    slider2.minimumValue = 0;
    slider2.tag = 2;
    slider2.value = 1;
}
-(void)onSlide:(UISlider*)slider{
    if(slider.tag==1){
        [((FilterChainView*)self.view) setSauration:slider.value];
    }else {
       [((FilterChainView*)self.view) setTemperature:slider.value];
    }
    [((FilterChainView*)self.view) renderLayer];
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
