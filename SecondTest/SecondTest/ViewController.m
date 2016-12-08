//
//  ViewController.m
//  SecondTest
//
//  Created by qianfeng on 16/12/6.
//  Copyright © 2016年 qianfeng. All rights reserved.
//

#import "ViewController.h"
#import "BJAlertView.h"

@interface ViewController () <BJAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
}

- (void)createView{
    NSString * urlStr = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg";
    NSString * filePath = [NSString stringWithFormat:@"%@/Documents/QQ.dmg",NSHomeDirectory()];
    NSLog(@"filePath = %@",filePath);
    BJAlertView * alert = [[BJAlertView alloc]initWithFrame:[UIScreen mainScreen].bounds];
   // [alert initWithTitle:@"提示: 系统应用升级" messages:@[@"1. 我很好 ",@"2. 你好吗 ",@"3, 好久不见"] delegate:self withUrl:urlStr toFilePath:filePath cancelButtonTitle:@"取消" otherButtonTitles:@"立即下载"];
    // 这个是不带 下载条的方法
    [alert initWithTitle:@"提示: 系统应用升级" messages:@[@"1. 我很好 有人说无论你是追求天上的月亮，还是追求地上的六便士，每种生活方式没有绝对的好坏，只要让你感到快乐的生活方式就是好的。而我更想说，只有在马斯洛需求层次理论，每一层都逐步满足时，才可能真正的抵达自我实现，斯特里克兰如果没有经历衣食无忧的日子，而是一直处于温饱边缘徘徊，很难想象他会抛妻弃子，如飞蛾扑火追逐梦想……但，美好生活有时候也会让人产生惰性，抹灭那股挑战未知的敏锐感，因此，终究，我是欣赏斯特里克 ",@"2. 你好吗 而我更想说，只有在马斯洛需求层次理论，每一层都逐步满足时，才可能真正的抵达自我实现，斯特里克兰如果没有经历衣食无忧的日子，而是一直处于温饱边缘徘徊，很难想象他会抛妻弃子，如飞蛾扑火追逐梦想……但，美好生活有时候也会让人产生惰性，抹灭那股挑战未知的敏锐感，因此，终究，我是欣赏斯特里克",@"3, 好久不见"] cancelButtonTitle:@"取消"];
    [self.view addSubview:alert];
}

- (void)didClickButtonAtIndex:(NSInteger)index AlertView:(BJAlertView *)alertView{
    NSLog(@"index = %ld",index);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



























