//
//  BarrageView.m
//  BarrageDemo
//
//  Created by huweiya on 16/7/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "BarrageView.h"
#define padding 10 //间距
#define duration 8.0f//弹幕速度
#define kWidth [UIScreen mainScreen].bounds.size.width

@interface BarrageView()

@property (nonatomic, copy) UILabel *lbCommet;//评论label

@property (nonatomic, strong) UIImageView *headImgView;//头像

@property (nonatomic, copy) UILabel *userNmae;//用户label


@end


@implementation BarrageView

//初始化弹幕
- (instancetype)initWithComment:(NSString *)comment
{
    
    
    if (self =[super init]) {
        self.backgroundColor = [UIColor clearColor];
        //计算内容宽度
        NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        
        CGFloat width = [comment sizeWithAttributes:attr].width;
        
        
        self.lbCommet.text = comment;
        
        self.lbCommet.frame = CGRectMake(padding  + 60, 30, width, 30);
        
        self.lbCommet.text = comment;
        
        self.headImgView.frame = CGRectMake(padding, 0, 60, 60);
        
        self.userNmae.backgroundColor = [UIColor yellowColor];
        
        self.userNmae.frame = CGRectMake(padding  + 60, 0, width, 30);
        
        self.lbCommet.backgroundColor = [UIColor greenColor];
        
        //弹幕所在view的frame
    
        self.bounds = CGRectMake(0, 0, width + 3 * padding + CGRectGetWidth(self.headImgView.bounds) , 60);

    }
    
    return self;
}

//开始动画
- (void)startAnimation
{
    //根据 弹幕长度执行动画效果
    
    CGFloat totalWidth = kWidth + CGRectGetWidth(self.bounds);
        
    //v = s / t; t = s / v;
    
    CGFloat v = totalWidth / duration;
    
    CGFloat t = CGRectGetWidth(self.bounds) / v;
    
    //判断进入状态
    [self performSelector:@selector(enter) withObject:nil afterDelay:t];
    
    
    __block CGRect frame = self.frame;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (self.moveStatusBlock) {
            //开始进入
            self.moveStatusBlock(Start);
            
        }
        
        frame.origin.x -= totalWidth;
        
        self.frame = frame;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        if (self.moveStatusBlock) {
            //离开
            self.moveStatusBlock(End);
            
        }
        
    }];
    
    
}

- (void)enter{
    if (self.moveStatusBlock) {
        //完全进入
        self.moveStatusBlock(Enter);
        
    }

}


//结束动画
- (void)stopAnimation
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.layer removeAllAnimations];
    
    [self removeFromSuperview];
}


- (UILabel *)lbCommet
{
    if (!_lbCommet) {
        _lbCommet = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _lbCommet.font = [UIFont systemFontOfSize:14];
        
        _lbCommet.textColor = [UIColor blackColor];
        
        _lbCommet.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lbCommet];
        
    }
    
    return _lbCommet;
}

- (UILabel *)userNmae
{
    if (!_userNmae) {
        _userNmae = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _userNmae.font = [UIFont systemFontOfSize:12];
        
        _userNmae.textColor = [UIColor blackColor];
        
        _userNmae.text = @"用户1";
        
        _userNmae.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_userNmae];
        
    }
    
    return _userNmae;
}


- (UIImageView *)headImgView{
    
    
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        
        _headImgView.layer.masksToBounds = YES;
        
        _headImgView.layer.cornerRadius = 30;
        
        _headImgView.image = [UIImage imageNamed:@"chatBar_colorMore_locationSelected"];
        
        [self addSubview:_headImgView];
    }
    return _headImgView;
}

@end
