//
//  BJAlertView.m
//  SecondTest
//
//  Created by qianfeng on 16/12/6.
//  Copyright © 2016年 qianfeng. All rights reserved.
//

#import "BJAlertView.h"
#import "MBProgressHUD.h"
#import "Masonry.h"

#define SCR_W [UIScreen mainScreen].bounds.size.width
#define SCR_H [UIScreen mainScreen].bounds.size.height
#define LabelW .9f
#define LabelH 20
#define LabelTextColor [UIColor colorWithRed:166 / 255.0 green:166 / 255.0 blue:166 / 255.0 alpha:1.0]
#define MessageLableLeftSpace 15
#define AlertViewLeftApace 45
#define btnW  SCR_W * 0.2
#define btnH  btnW * 0.45


@interface BJAlertView()
@property (nonatomic, strong) UIView * blackView; // 背景层
@property (nonatomic, strong) UIView * alertView; // 添加在背景层,的弹出框
@property (nonatomic, weak, nullable)id<BJAlertViewDelegate> delegate;
@property (nonatomic, strong) UIProgressView * progressV; // 下载进度条
@property (nonatomic, strong) UILabel * progressLable; // 下载百分比
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * cancelTitle;
@property (nonatomic, copy) NSString * otherTitle;
@property (nonatomic, strong) NSArray * messagesArr;
@property (nonatomic, copy) NSString * urlStr; // 下载路径
@property (nonatomic, copy) NSString * filePath; // 文件路径
@property (nonatomic, assign) CGFloat offSetY; // 记录 Y 的值
@property (nonatomic, assign) BOOL isExist; // 是否存在下载进度条


// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask * downLoadTask;
// 记录下载的位置
@property (nonatomic, strong) NSData * resumeData;
// session
@property (nonatomic, strong) NSURLSession * session;

@end

@implementation BJAlertView

/*
 #pragma mark - 懒加载
 - (NSURLSession *)session{
 if (!_session) {
 NSURLSessionConfiguration * cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
 _session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
 }
 return _session;
 }
 */
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建遮罩层
        _blackView = [[UIView alloc]init];
        _blackView.backgroundColor = [UIColor blackColor];
        _blackView.alpha = 0.5;
        [self addSubview:_blackView];
        [_blackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        _alertView = [[UIView alloc]init];
        _alertView.backgroundColor = [UIColor redColor];
        _alertView.layer.cornerRadius = 15;
        _alertView.layer.masksToBounds = true;
        [_blackView addSubview:_alertView];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.left.equalTo(self.mas_left).with.offset(AlertViewLeftApace);
            make.right.equalTo(self.mas_right).with.offset(-AlertViewLeftApace);
            //make.height.equalTo(self.mas_height).with.multipliedBy(0.2f); // 下面会自动更新高度
            [self exChangeOut:self.alertView dur:0.6];
        }];
        _offSetY = 0.0;
        //UIAlertView * aler = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        NSLog(@"frame");
    }
    return self;
}







#pragma mark - 添加动画效果
- (void)exChangeOut:(UIView *)alertView dur:(CFTimeInterval)dur{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur; // 单词动画所占用的时间
    animation.removedOnCompletion = false; //默认为YES，代表动画执行完毕后就从图层上移除，图形会恢复到动画执行前的状态。如果想让图层保持显示动画执行后的状态，那就设置为NO，不过还要设置fillMode为kCAFillModeForwards
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [alertView.layer addAnimation:animation forKey:nil];
}

- (void)initWithTitle:(NSString *)title messages:(NSArray *)messagesArr delegate:(id)delegate withUrl:(NSString *)urlStr toFilePath:(NSString *)filePath cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle{
    _title = title;
    //_title = @"提示: 系统应用升级";
    _messagesArr = messagesArr;
    _delegate = delegate;
    _urlStr = urlStr;
    _filePath = filePath;
    _cancelTitle = cancelButtonTitle;
    _otherTitle = otherButtonTitle;
    _isExist = true; // 存在下载进度条
    NSLog(@"initWith");
}

- (void)initWithTitle:(NSString *)title messages:(NSArray *)messagesArr cancelButtonTitle:(NSString *)cancelTitle{
    _title = title;
    _messagesArr = messagesArr;
    _cancelTitle = cancelTitle;
    _isExist = false; // 不存在
    NSLog(@"initWith");
}


- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    // 标题提示
    UILabel * tipLable = [[UILabel alloc]init];
    tipLable.text = self.title;
    tipLable.backgroundColor = [UIColor clearColor];
    tipLable.textAlignment = NSTextAlignmentLeft;
    tipLable.textColor = [UIColor whiteColor];
    tipLable.font = [UIFont systemFontOfSize:20]; // 字体大小
    [self.alertView addSubview:tipLable];
    [tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertView.mas_top).with.offset(10);
        make.left.equalTo(self.alertView.mas_left).with.offset(10);
        make.right.equalTo(self.alertView.mas_right).with.offset(-10);
        make.height.mas_equalTo(@25);
    }];
    self.offSetY = 40;
    //    NSLog(@"第一次offSetY %f",self.offSetY);
    // 提示信息
    for (int i = 0; i < self.messagesArr.count; i ++) {
        NSString * message = self.messagesArr[i];
        CGSize size = CGSizeMake(SCR_W - (2 *(AlertViewLeftApace + MessageLableLeftSpace)), 99999); // 需要人为的计算 宽度
        CGRect rect = [message boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil];
        CGFloat lableH = rect.size.height;
        UILabel * label = [[UILabel alloc]init];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:17];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = LabelTextColor;
        label.text = message;
        [self.alertView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.alertView.mas_left).with.offset(MessageLableLeftSpace);
            make.right.equalTo(self.alertView.mas_right).with.offset(-MessageLableLeftSpace);
            make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY += 5);
            make.height.mas_equalTo(lableH);
            self.offSetY += lableH;
        }];
    }
    //NSLog(@"第二次:%f",self.offSetY);
    if (self.isExist) {
        // 添加进度条
        self.progressV = [[UIProgressView alloc]init];
        self.progressV.progress = 0;
        self.progressV.progressTintColor = [UIColor greenColor];
        self.progressV.tintColor = [UIColor redColor];
        [self.alertView addSubview:self.progressV];
        [self.progressV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY += 10);
            make.left.equalTo(self.alertView.mas_left).with.offset(10);
            make.right.equalTo(self.alertView.mas_right).with.offset(-70);
            make.height.equalTo(@3);
        }];
        self.offSetY += 3;
        // 添加下载百分比
        self.progressLable = [[UILabel alloc]init];
        self.progressLable.font = [UIFont systemFontOfSize:15];
        self.progressLable.numberOfLines = 0;
        self.progressLable.textColor = LabelTextColor;
        self.progressLable.text = @"0.00%";
        self.progressLable.textAlignment = NSTextAlignmentCenter;
        self.progressLable.backgroundColor = [UIColor clearColor];
        [self.alertView addSubview:self.progressLable];
        [self.progressLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressV.mas_right).with.offset(5);
            make.right.equalTo(self.alertView.mas_right).with.offset(-10);
            make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY - 12); // 为了与 progressV 居中对齐
            make.height.equalTo(@20);
        }];
    }

    // button
    if (self.cancelTitle) { // 有取消按钮
        UIButton * cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setTitle:self.cancelTitle forState:UIControlStateNormal];
        [cancel setTitle:self.cancelTitle forState:UIControlStateHighlighted];
        [cancel setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
        cancel.titleLabel.font = [UIFont systemFontOfSize:18];
        cancel.tag = 100;
        [cancel addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        cancel.backgroundColor = [UIColor brownColor];
        [self.alertView addSubview:cancel];
        [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY += 10);
            make.right.equalTo(self.alertView.mas_right).with.offset(-MessageLableLeftSpace);
            make.width.mas_equalTo(btnW);
            make.height.mas_equalTo(btnH);
        }];
        if (self.otherTitle) { // 有其他按钮
            UIButton * otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [otherBtn setTitle:self.otherTitle forState:UIControlStateNormal];
            [otherBtn setTitle:self.otherTitle forState:UIControlStateHighlighted];
            [otherBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            [otherBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
            otherBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            otherBtn.tag = 101;
            [otherBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            otherBtn.backgroundColor = [UIColor brownColor];
            [self.alertView addSubview:otherBtn];
            [otherBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY);
                make.right.equalTo(self.alertView.mas_right).with.offset(-(MessageLableLeftSpace + btnW + 10));
                make.width.mas_equalTo(btnW);
                make.height.mas_equalTo(btnH);
            }];
        }
    }

    if (!self.cancelTitle){ //没有取消按钮
        if (self.otherTitle) { // 有其他按钮
            UIButton * otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [otherBtn setTitle:self.otherTitle forState:UIControlStateNormal];
            [otherBtn setTitle:self.otherTitle forState:UIControlStateHighlighted];
            [otherBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            [otherBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
            otherBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            otherBtn.tag = 101;
            otherBtn.backgroundColor = [UIColor brownColor];
            [otherBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.alertView addSubview:otherBtn];
            [otherBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.alertView.mas_top).with.offset(self.offSetY += 10);
                make.right.equalTo(self.alertView.mas_right).with.offset(-MessageLableLeftSpace);
                make.width.mas_equalTo(btnW);
                make.height.mas_equalTo(btnH);
            }];
        }else{

        }
    }
    self.offSetY += btnH ;
    [self.alertView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.offSetY += 10);
    }];


}



- (void)clickButton:(UIButton *)button{
    switch (button.tag) {
        case 100:
            [self cancelView];
            break;
        default:{
            //NSLog(@"tag = %ld %@",button.tag,button.currentTitle);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickButtonAtIndex:AlertView:)]) {
                [self.delegate didClickButtonAtIndex:button.tag AlertView:self];
            }
            NSURL * url = [NSURL URLWithString:self.urlStr];
            NSLog(@"url = %@",url);
            NSURLRequest * request = [NSURLRequest requestWithURL:url];
            if ([button.currentTitle isEqualToString:@"继续"] || [button.currentTitle isEqualToString:@"立刻下载"]) {
                [button setTitle:@"暂停下载" forState:UIControlStateNormal];
                [button setTitle:@"暂停下载" forState:UIControlStateHighlighted];
                // 开始要下载了 或者 继续下载
                if (!_session) {
                    NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"downloadID"];
                    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                }
                if (self.resumeData != nil) {
                    // 在上一次下载的基础上下载
                    _downLoadTask = [self.session downloadTaskWithResumeData:self.resumeData];
                }else{
                    // 开始新建任务
                    _downLoadTask = [_session downloadTaskWithRequest:request];
                }
                // 启动任务
                [_downLoadTask resume];
            }else{ //if ([button.currentTitle isEqualToString:@"暂停下载"])
                [button setTitle:@"继续" forState:UIControlStateNormal];
                [button setTitle:@"继续" forState:UIControlStateHighlighted];
                [self pauseLoad];
            }
        }
            break;
    }
}

- (void)pauseLoad{
    __weak typeof(self) weakSelf = self;
    [_downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        [weakSelf.session invalidateAndCancel];
        weakSelf.session = nil;
    }];
}





#pragma mark - 点击取消按钮
- (void)cancelView{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        weakSelf.alertView = nil;
    }];
}




#pragma mark - 下载协议方法
// 已经开始从某一偏移量的位置下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"已经开始下载, 开始的偏移量  %lld",fileOffset);
}

// 下载过程中
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //下载过程中我们是得不到所下载的数据的，我们只能更新下载进度
    //计算当前的下载进度
    // bytesWritten: 本次写入的数据长度
    // totalBytesWritten: 已经下载的数据总长度
    // totalBytesExpectedToWrite 数据的总长度
    // 进度 =（bytesWritten + totalBytesWritten）÷ totalBytesExpectedToWrite
    CGFloat progress = (bytesWritten + totalBytesWritten)* 1.0/ totalBytesExpectedToWrite * 1.0 ;
    //更新进度条显示的进度值
    dispatch_async(dispatch_get_main_queue(), ^{
        //更UI相关的更新，要在主线程中完成
        self.progressV.progress = progress;
        self.progressLable.text = [NSString stringWithFormat:@"%.2f%%",progress * 100];
    });
}

// 下载结束
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    // 消失提示框 下载窗口消失
    [self cancelView];
    NSLog(@"下载完成");

    NSFileManager * fm = [NSFileManager defaultManager];
    // 将要移动的目标位置, 沙盒路径中的存放位置
    NSError * error = nil;
    [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.filePath] error:&error];
    if (!error) {
        NSLog(@"移动成功,可以到沙盒路径下查看下载的文件 %@",self.filePath);
    }
    /*
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [self.filePath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    // 将临时文件剪切或者复制...文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    [mgr moveItemAtPath:location.path toPath:file error:nil];
    //zip文件
    NSString *zipPath = file;  // 添加了后缀
    //zip解压缩后的位置
    NSString *destinationPath = self.filePath;
    NSLog(@"zip文件位置 =  %@",zipPath);
    NSLog(@"解压缩文件位置 = %@",self.filePath);

    MBProgressHUD *mbph = [[MBProgressHUD alloc] init];
    mbph.labelText = @"下载完成 正在解压 ... 这个还需要调整   ";
    [self.superview addSubview:mbph];
    [mbph show:YES];
     */

    /*
    ZipArchive *unzip = [[ZipArchive alloc] init];
    BOOL succes ;
    //打开需要解压缩的文件 ../xxx.zip
    if ([unzip UnzipOpenFile:zipPath]) {
        //将解压缩后的文件放入 ../
        succes = [unzip UnzipFileTo:destinationPath overWrite:YES];
        if (succes) {
            [unzip UnzipCloseFile];

            mbph.labelText = @"解压成功";
            [mbph hide:YES];
            //删掉下载文件
            [mgr removeItemAtPath:zipPath error:nil];
            if ([self.delegate respondsToSelector:@selector(passResult:)]) {
                [self.delegate passResult:succes];
            }
        }else{
            mbph.labelText = @"解压错误";
            [mbph hide:YES afterDelay:1];
            NSLog(@"解压错误");
        }
    }else{
        mbph.labelText = @"文件打开错误";
        [mbph hide:YES afterDelay:1];
        NSLog(@"文件打开错误");
    }

     */


}







@end




























