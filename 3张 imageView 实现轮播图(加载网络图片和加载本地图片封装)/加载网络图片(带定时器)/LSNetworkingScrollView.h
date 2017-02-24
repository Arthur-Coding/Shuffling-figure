//
//  LSNetworkingScrollView.h
//
//  Created by ArthurShuai on 16/4/14.
//  Copyright © 2016年 ArthurShuai. All rights reserved.
/*
 1.此轮播图为支持加载网络视频图片实现轮播图(带定时器播放)
 2.使用此 scrollView 类,必须确保工程中添加的有SDWebImage第三方库(或用 cocoaPods 添加),也建议添加SDWebImage第三方库,可以优化因加载网络图片造成的界面卡顿与延迟等问题
 3.此 scrollView 类提供的有向其他工程类传递当前显示图片索引的 block 块接口,可根据实际情况灵活调用
 4.此 scrollView 类封装了一个类似于 UITableView 的 reloadData 刷新数据的方法,可以刷新轮播图中数据
 */

#import <UIKit/UIKit.h>

@interface LSNetworkingScrollView : UIScrollView
@property (nonatomic,strong)NSArray *imageArr;//图片数组,里面存放的图片的链接地址字符串
@property (nonatomic,copy)void(^pageIndexBlk)(NSInteger pageIndex);//传递当前显示的图片的索引
@property (nonatomic,strong) NSTimer *timer;//定时器
//初始化对象方法
- (instancetype)initWithFrame:(CGRect)frame and:(NSArray *)imgArr andPlaceholderImage:(NSString *)imageName;
//初始化类方法
+ (instancetype)scrollViewWithFrame:(CGRect)frame and:(NSArray *)imgArr andPlaceholderImage:(NSString *)imageName;
//刷新数据方法
- (void)reloadData;
@end
