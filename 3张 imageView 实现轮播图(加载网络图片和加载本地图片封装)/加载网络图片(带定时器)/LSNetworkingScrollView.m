//
//  LSNetworkingScrollView.m
//
//  Created by ArthurShuai on 16/4/14.
//  Copyright © 2016年 ArthurShuai. All rights reserved.
//

#import "LSNetworkingScrollView.h"
#import "UIImageView+WebCache.h"

@interface LSNetworkingScrollView ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView *leftImg;//左边imageView
@property (nonatomic,strong) UIImageView *middleImg;//当前 imageView, 即中间显示的 imageView
@property (nonatomic,strong) UIImageView *rightImg;//右边imageView
@property (nonatomic       ) NSInteger   currentIndex;//当前图片索引
@property (nonatomic       ) NSInteger direction;//滑动方向标识,0为无滑动,1为左滑动,2为右滑动

@property (nonatomic,strong) NSString *phImageName;

@end
@implementation LSNetworkingScrollView
- (instancetype)initWithFrame:(CGRect)frame and:(NSArray *)imgArr andPlaceholderImage:(NSString *)imageName{
    if (self = [super initWithFrame:frame]) {
        self.imageArr = imgArr;
        self.phImageName = imageName;
        self.contentSize = CGSizeMake(CGRectGetWidth(frame) * 3, CGRectGetHeight(frame));
        self.pagingEnabled = YES;// 打开分页允许
        self.bounces = NO;//关闭弹性
        //关闭水平和垂直方向的滚动指示条
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        //设置初始偏移,默认显示中间的图片
        self.contentOffset = CGPointMake(CGRectGetWidth(frame), 0);
        //设置代理
        self.delegate = self;
        //加载图片占位
        [self loadImageForScrollViewWithFrame:frame];
        
        //对方向的改变添加 KVO 监听
        [self addObserver:self forKeyPath:@"direction" options:NSKeyValueObservingOptionNew context:nil];
        
        //设置定时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(pageChangeWithTimer) userInfo:nil repeats:YES];
    }
    return self;
}
+ (instancetype)scrollViewWithFrame:(CGRect)frame and:(NSArray *)imgArr andPlaceholderImage:(NSString *)imageName{
    return [[self alloc] initWithFrame:frame and:imgArr andPlaceholderImage:imageName];
}
//初始加载3个 imageView 进行占位并赋初值
- (void)loadImageForScrollViewWithFrame:(CGRect)frame{
    if (self.imageArr.count == 0) return;//防止数组为空
    _leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    _leftImg.userInteractionEnabled = YES;//打开用户交互是为与工程的其他功能实现进行配合,比如新闻轮播图,点击图片可以跳转对应的新闻界面,当然,也可以不设置,既是用默认的 NO
    [self addSubview:_leftImg];
    _middleImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    _middleImg.userInteractionEnabled = YES;
    [self addSubview:_middleImg];
    _rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)*2, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    _rightImg.userInteractionEnabled = YES;
    [self addSubview:_rightImg];
    
    UIImage *image = [UIImage imageNamed:self.phImageName];
    
    if (self.imageArr.count == 1) {//防止网上请求到的图片数据只有一个而因索引不存在崩溃
        [_leftImg removeFromSuperview];
        [_rightImg removeFromSuperview];
        [_middleImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[0]] placeholderImage:image];
        self.scrollEnabled = NO;
    }
    if (self.imageArr.count>1) {
        [_leftImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[self.imageArr.count-1]] placeholderImage:image];
        [_middleImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[0]]placeholderImage:image];
        [_rightImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[1]] placeholderImage:image];
    }
}
#pragma mark UIScrollViewDelegate andKVO andNSTimerControl
//时刻监听方向的改变,给方向属性赋值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    self.direction = offsetX > CGRectGetWidth(self.frame) ? 1 : offsetX < CGRectGetWidth(self.frame) ? 2 : 0;
}
//KVO event
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (self.imageArr.count == 0) return;//防止数组为空
    NSInteger direction = [change[NSKeyValueChangeNewKey] integerValue];
    if (direction == 0) return;
    NSInteger rightIndex = (_currentIndex+1)% self.imageArr.count;//判断索引合法
    NSInteger leftIndex = (_currentIndex-1)<0 ? self.imageArr.count-1 : _currentIndex-1;//判断索引合法
    
    UIImage *image = [UIImage imageNamed:self.phImageName];
    
    [_leftImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[leftIndex]] placeholderImage:image];
    [_rightImg sd_setImageWithURL:[NSURL URLWithString:self.imageArr[rightIndex]] placeholderImage:image];
}
- (void)pageChange{
    if (self.imageArr.count == 0) return;//防止数组为空
    //    if (self.direction == 0) return;//无滑动直接返回
    else if (self.direction == 1) _currentIndex = (_currentIndex+1)% self.imageArr.count;//改变当前索引,并判断索引合法
    else if (self.direction == 2) _currentIndex = (_currentIndex-1)<0 ? self.imageArr.count-1 : _currentIndex-1;//改变当前索引,并判断索引合法

    UIImage *image = [UIImage imageNamed:self.phImageName];
    [_middleImg sd_setImageWithURL[NSURL URLWithString:self.imageArr[_currentIndex]] placeholderImage:image];
    self.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);//再次设置偏移
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self pageChange];
    if (_pageIndexBlk) _pageIndexBlk(_currentIndex);//如果其他工程中调用此 block 块,就可以将当前图片的索引传递出去
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(pageChangeWithTimer) userInfo:nil repeats:YES];
}
//MSTimer control
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.timer invalidate];
}
//NSTimer event
- (void)pageChangeWithTimer{
    CGFloat offsetX = self.contentOffset.x + CGRectGetWidth(self.frame);
    [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    [self pageChange];
    if (_pageIndexBlk) _pageIndexBlk((_currentIndex+1)% self.imageArr.count);
}

//reloadData
- (void)reloadData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _currentIndex = 0;
    if (_pageIndexBlk) _pageIndexBlk(_currentIndex);
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(pageChangeWithTimer) userInfo:nil repeats:YES];
    [self loadImageForScrollViewWithFrame:self.frame];
}

//结束程序后,销毁 KVO 监听与定时器
- (void)dealloc{
    [self removeObserver:self forKeyPath:@"direction" context:nil];
    [self.timer invalidate];
}

@end
