//
//  FullScreenPlayerViewController.h
//  HUAVPlayer
//
//  Created by huweiya on 16/10/18.
//  Copyright © 2016年 5i5j. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, PlayInterfaceStyle) {
    huNormal = 0,//什么都没有
    huSelect = 1,//上下view
    huSet = 2,//左侧设置
    huLocken = 3//锁屏状态
};



@interface FullScreenPlayerViewController : UIViewController
//视频url地址
@property (nonatomic, copy) NSURL *url;

/**
 主播放器
 */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


//进入 huNormal 状态时间
@property (nonatomic, assign) CGFloat hideViewTime;


@end
