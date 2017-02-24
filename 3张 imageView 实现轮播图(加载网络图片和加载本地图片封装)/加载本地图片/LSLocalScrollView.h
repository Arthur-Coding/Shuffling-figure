//
//  LSLocalScrollView.h
//
//  Created by ArthurShuai on 16/4/14.
//  Copyright © 2016年 ArthurShuai. All rights reserved.
/*
 1.此轮播图为支持加载本地图片实现轮播图
 2.此 scrollView 类提供的有向其他工程类传递当前显示图片索引的 block 块接口,可根据实际情况灵活调用
 3.此 scrollView 类封装了一个类似于 UITableView 的 reloadData 刷新数据的方法,可以刷新轮播图中数据
 */

#import <UIKit/UIKit.h>

@interface LSLocalScrollView : UIScrollView
@property (nonatomic,strong)NSArray *imageArr;//图片数组,里面存放的图片的路径地址字符串
@property (nonatomic,copy)void(^pageIndexBlk)(NSInteger pageIndex);//传递当前显示的图片的索引
//初始化对象方法
- (instancetype)initWithFrame:(CGRect)frame and:(NSArray *)imgArr;
//初始化类方法
+ (instancetype)scrollViewWithFrame:(CGRect)frame and:(NSArray *)imgArr;//这里的 imageType 即为照片的后缀类型, png或jpg 等
//刷新数据方法
- (void)reloadData;
@end
