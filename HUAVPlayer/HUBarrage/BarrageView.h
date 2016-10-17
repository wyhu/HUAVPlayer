//
//  BarrageView.h
//  BarrageDemo
//
//  Created by huweiya on 16/7/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MoveStatus){
    
    Start,//刚刚进入
    Enter,//完全进入
    End//完全离开
    
};


typedef void(^moveStatusBlock)(MoveStatus);


@interface BarrageView : UIView


//用户姓名
@property (nonatomic, copy) NSString *userName;
//用户头像
@property (nonatomic, copy) NSString *userHeadPic;


@property (nonatomic, assign) int trajectory; //弹道

//声明
@property (nonatomic, copy) moveStatusBlock moveStatusBlock;//弹幕状态回调









//初始化弹幕
- (instancetype)initWithComment:(NSString *)comment;

//开始动画
- (void)startAnimation;

//结束动画
- (void)stopAnimation;



@end
