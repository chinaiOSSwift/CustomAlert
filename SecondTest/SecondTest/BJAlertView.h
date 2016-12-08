//
//  BJAlertView.h
//  SecondTest
//
//  Created by qianfeng on 16/12/6.
//  Copyright © 2016年 qianfeng. All rights reserved.

//- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

//- (id)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
//- (nullable instancetype) initWithCoder:(nonnull NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

//@property(nullable,nonatomic,weak) id /*<UIAlertViewDelegate>*/ delegate;
//@property(nonatomic,copy) NSString *title;
//@property(nullable,nonatomic,copy) NSString *message;


#import <UIKit/UIKit.h>
//#import "ZipArchive.h"
@class BJAlertView;
@protocol BJAlertViewDelegate <NSObject>
@optional
// 代理方法没有什么意义, 建议不要指定代理
- (void)didClickButtonAtIndex:(NSInteger) index AlertView:(BJAlertView *) alertView;// button的tag值
- (void)passResule:(BOOL)isSuccess;
@end

@interface BJAlertView : UIView<NSURLSessionDownloadDelegate>



- (void)initWithTitle:( NSString *)title messages:(NSArray *)messagesArr delegate:(id) delegate withUrl:(NSString * )urlStr toFilePath:(NSString *)filePath cancelButtonTitle:( NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle;


- (void) initWithTitle:(NSString *)title messages:(NSArray *) messagesArr cancelButtonTitle:(NSString *)cancelTitle;


@end


















