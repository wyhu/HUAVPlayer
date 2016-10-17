//
//  MoviePlayerViewController.h
//  HUAVPlayer
//
//  Created by huweiya on 16/10/17.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlayInterfaceStyle) {
    huNormal = 0,//什么都没有
    huSelect = 1,//上下view
    huSet = 2,//左侧设置
};


@interface MoviePlayerViewController : UIViewController


//视频url地址
@property (nonatomic, copy) NSURL *url;

//进入 huNormal 状态时间
@property (nonatomic, assign) CGFloat hideViewTime;



@end
