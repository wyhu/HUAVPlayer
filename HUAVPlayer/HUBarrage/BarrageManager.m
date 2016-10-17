//
//  BarrageManager.m
//  BarrageDemo
//
//  Created by huweiya on 16/7/27.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "BarrageManager.h"
#import "BarrageView.h"

@interface BarrageManager()

//数据源
@property (nonatomic, strong) NSMutableArray *dataSource;
//弹幕时候过程中数组变量
@property (nonatomic, strong) NSMutableArray *bulletComments;
//存储弹幕view的数组变量
@property (nonatomic, strong) NSMutableArray *bulletViews;

@property (nonatomic, assign) BOOL isStop;


@end
@implementation BarrageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //刚开始是暂停状态
        self.isStop = YES;
    }
    return self;
}
//弹幕开始
- (void)star{
    
    if (!_isStop) {
        return;
    }
    _isStop = NO;
        
    [self.bulletComments removeAllObjects];
    [self.bulletComments addObjectsFromArray:self.dataSource];
    
    [self initBulletComment];
    
}


//弹幕结束
- (void)stop{
    
    if (_isStop) {
        return;
    }
    _isStop = YES;
    
    [self.bulletViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BarrageView *view = obj;
        
        [view stopAnimation];
        
        view = nil;
        
    }];
    
    [self.bulletViews removeAllObjects];
    
    
    
    
}


//初始化弹幕，随机分配弹道
- (void)initBulletComment
{
    NSMutableArray *trajectorys = [NSMutableArray array];
    
    if (_trajectoryNum == 0) {
        _trajectoryNum = 3;
    }
    
    
    for (int i = 0; i < _trajectoryNum; i++) {
        
        NSString *str = [NSString stringWithFormat:@"%d",i];
        
        [trajectorys addObject:str];
        
    }
    
    
    
    
    for (int i = 0; i < _trajectoryNum; i++) {
        
        if (self.bulletComments.count > 0) {
            //通过随机数获取弹幕的轨迹
            NSInteger index = arc4random()%trajectorys.count;
            
            int trajectory = [[trajectorys objectAtIndex:index] intValue];
            
            [trajectorys removeObjectAtIndex:index];
            
            //从弹幕中 逐一的取出弹幕数据
            NSString *comment = [self.bulletComments firstObject];
            
            if (comment > 0) {
                [self createBulletView:comment trajectory:trajectory];
                
                [self.bulletComments removeObjectAtIndex:0];

            }
            

        }
        
    }
    
    
    
}


- (void)createBulletView:(NSString *)comment trajectory:(int)trac
{
    
    if (_isStop) {
        return;
    }
    
    BarrageView *view = [[BarrageView alloc] initWithComment:comment];
    
    view.userName = self.userName;
    
    view.userHeadPic = self.userHeadPic;
    
    view.trajectory = trac;
    
    __weak typeof (view) weakView = view;
    
    __weak typeof (self) weakSelf = self;


    view.moveStatusBlock = ^(MoveStatus status){
        //不同状态
        
        if (weakSelf.isStop) {
            return;
        }

        switch (status) {
            case Start: {
                //开始时
                [weakSelf.bulletViews addObject:weakView];
                
                break;
            }
            case Enter: {
                //完全进入后，判断是否还有别的评论,并加入
                NSString *nextComment = [weakSelf nextComment];
                
                if (nextComment) {
                    
                    [weakSelf createBulletView:nextComment trajectory:trac];
                    
                }
                
                break;
            }
            case End: {
                [weakView stopAnimation];
                
                if ([weakSelf.bulletViews containsObject:weakView]) {
                    [weakSelf.bulletViews removeObject:weakView];
                }
                
                if (weakSelf.bulletViews.count == 0) {
                    //说明屏幕上已经没有弹幕了
                    self.isStop = YES;
                    [weakSelf star];
                }
                
                
                
                break;
            }
        }
        
        
        
    };
    
    //创建view的回调
    if (self.generateViewBlock) {
        self.generateViewBlock(weakView);
    }
    
}

#pragma mark 获取下一条弹幕信息
- (NSString *)nextComment
{
    if (self.bulletComments.count > 0) {
        
        NSString *nextComment = [self.bulletComments firstObject];
        
        [self.bulletComments removeObjectAtIndex:0];
        
        return nextComment;
        
    }
    
    return nil;
    
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithObjects:
                       @"弹幕1",
                       @"弹幕22",
                       @"弹幕333",
                       @"弹幕444",
                       @"弹幕5555",
                       @"弹幕66666",
                       @"弹幕777777",
                       @"弹幕8888888",
                       @"弹幕99999999",
                       @"弹幕100000000",
                       @"弹幕1",
                       @"弹幕22",
                       @"弹幕333",
                       @"弹幕444",
                       @"弹幕5555",
                       @"弹幕66666",
                       @"弹幕777777",
                       @"弹幕8888888",
                       @"弹幕99999999",
                       @"弹幕100000000",
                       @"弹幕1",
                       @"弹幕22",
                       @"弹幕333",
                       @"弹幕444",
                       @"弹幕5555",
                       @"弹幕66666",
                       @"弹幕777777",
                       @"弹幕8888888",
                       @"弹幕99999999",
                       @"弹幕100000000",
                       @"弹幕1",
                       @"弹幕22",
                       @"弹幕333",
                       @"弹幕444",
                       @"弹幕5555",
                       @"弹幕66666",
                       @"弹幕777777",
                       @"弹幕8888888",
                       @"弹幕99999999",
                       @"弹幕100000000",
                       @"弹幕1111111111", nil];
    }
    return _dataSource;
}

- (NSMutableArray *)bulletComments
{
    if (!_bulletComments) {
        _bulletComments = [NSMutableArray array];
    }
    return _bulletComments;
}

- (NSMutableArray *)bulletViews
{
    if (!_bulletViews) {
        _bulletViews = [NSMutableArray array];
    }
    return _bulletViews;
}




@end
