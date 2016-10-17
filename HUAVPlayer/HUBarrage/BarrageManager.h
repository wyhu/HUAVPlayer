//
//  BarrageManager.h
//  BarrageDemo
//
//  Created by huweiya on 16/7/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BarrageView;


typedef void(^generateViewBlock)(BarrageView *view);



@interface BarrageManager : NSObject


//用户姓名
@property (nonatomic, copy) NSString *userName;
//用户头像
@property (nonatomic, copy) NSString *userHeadPic;

@property (nonatomic, assign) int trajectoryNum; //弹道数


@property (nonatomic , copy) generateViewBlock generateViewBlock;



//弹幕开始
- (void)star;

//弹幕结束
- (void)stop;








@end
