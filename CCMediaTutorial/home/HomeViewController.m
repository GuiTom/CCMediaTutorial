//
//  HomeViewController.m
//  CCKit
//
//  Created by CC on 2020/1/16.
//  Copyright © 2020 CC. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeDataSource.h"
#import "TriangleViewController.h"
#import "ImageViewController.h"
#import "RectangleViewController.h"
#import "MVPTransfromVC.h"
#import "VideoCaptureViewController.h"
//#include "libavformat/avformat.h"
#import "SingleFilterVC.h"
#import "ImageFilterChainVC.h"
#import "MyVideoPlayerVC.h"
#import "ParticleViewController.h"
@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *table;

@end

@implementation HomeViewController
static NSString *cellId = @"cellID";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
   
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    [self.view addSubview:self.table];
}
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [HomeDataSource shareInstance].dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *cells = [[HomeDataSource shareInstance].dataSource objectAtIndex:section][@"cells"];
    
    return cells.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSDictionary *cellData = [HomeDataSource shareInstance].dataSource[indexPath.section][@"cells"][indexPath.row];
    cell.textLabel.text = cellData[@"title"];
    cell.textLabel.numberOfLines = 0;
    return cell;
}
#pragma mark UIScrollViewDelegate
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [UILabel new];
    NSString *headerTitle = [HomeDataSource shareInstance].dataSource[section][@"header"];
    label.text = headerTitle;
    return label;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 60.0f;
    }else {
        return 44.0f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   NSDictionary *sectiondata = [HomeDataSource shareInstance].dataSource[indexPath.section];
   NSArray *cellDatas = sectiondata[@"cells"];
   NSDictionary *cellData = cellDatas[indexPath.row];
   NSString *title = cellData[@"title"];
   NSString *header = sectiondata[@"header"];
    if([header isEqualToString:@"opengl ES"]){
        if([title isEqualToString:@"绘制一个三角形"]){
            [self.navigationController pushViewController:[TriangleViewController new] animated:YES];
        }else if([title isEqualToString:@"绘制一个矩形"]){
             [self.navigationController pushViewController:[RectangleViewController new] animated:YES];
        }else if([title isEqualToString:@"透视投影变换"]){
             [self.navigationController pushViewController:[MVPTransfromVC new] animated:YES];
        }
        else if([title isEqualToString:@"加载一张图片"]){
            [self.navigationController pushViewController:[ImageViewController new] animated:YES];
        }else if([title isEqualToString:@"视频采集变换"]){
            [self.navigationController pushViewController:[VideoCaptureViewController new] animated:YES];
        }else if([title isEqualToString:@"图片滤镜(单滤镜)"]){
            [self.navigationController pushViewController:[SingleFilterVC new] animated:YES];
        }else if([title isEqualToString:@"图片滤镜(流水线)"]){
            [self.navigationController pushViewController:[ImageFilterChainVC new] animated:YES];
        }else if([title isEqualToString:@"粒子系统"]){
            [self.navigationController pushViewController:[ParticleViewController new] animated:YES];
        }
    }else if([header isEqualToString:@"音视频编解码"]){
        if([title isEqualToString:@"视频播放器"]){
            [self.navigationController pushViewController:[MyVideoPlayerVC new] animated:YES];
        }
    }
    
}


@end
