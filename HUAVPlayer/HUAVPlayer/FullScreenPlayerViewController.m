//
//  FullScreenPlayerViewController.m
//  HUAVPlayer
//
//  Created by huweiya on 16/10/18.
//  Copyright © 2016年 5i5j. All rights reserved.
//
#define KmainWidth [UIScreen mainScreen].bounds.size.width
#define KmainHeight [UIScreen mainScreen].bounds.size.height

#define TopViewHeight 55 //头部界面高度
#define BottomViewHeight 55//底部界面高度
#define SetViewWidth 200//底部界面高度

#import "FullScreenPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BarrageManager.h"
#import "BarrageView.h"



@interface FullScreenPlayerViewController ()

@property (nonatomic, strong) BarrageManager *barageManager;

//界面状态
@property (nonatomic, assign) PlayInterfaceStyle playInterfaceStyle;

//视频总时长
@property (nonatomic, assign) CGFloat totalTime;
//当前时间点
@property (nonatomic, assign) CGFloat huCurrTime;



//播放器躯干
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;


//头部界面
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backBtn;//返回
@property (nonatomic, strong) UILabel *titleLabel;//标题
@property (nonatomic, strong) UIButton *setBtn;//设置


//底部界面
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *playBtn;//播放
@property (nonatomic,strong)UISlider *movieProgressSlider;//进度条
@property (nonatomic,strong)UILabel *totalLabel;//总时间展示label



//右侧设置界面
@property (nonatomic, strong) UIView *setView;


/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t gcdTimer;

//判断是否锁屏
@property (nonatomic, strong) UIButton *lockBtn;//播放


@property (nonatomic, assign) CGFloat barAlpage;//播放


@end

@implementation FullScreenPlayerViewController

//关闭定时器，移除通知

- (void)dealloc
{
    //销毁定时器
    dispatch_cancel(self.gcdTimer);
    self.gcdTimer = nil;
    
    //停止弹幕
    [self.barageManager stop];
    
    [self removeObserver:self forKeyPath:@"playInterfaceStyle" context:nil];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.playerLayer.frame = CGRectMake(0, 0, KmainHeight, KmainWidth);
    [self.view.layer addSublayer:_playerLayer];
    self.barAlpage = 1.0;
    self.player = self.playerLayer.player;
    self.playerItem = self.player.currentItem;
    
    //获取总时间
    self.totalTime = (Float64)CMTimeGetSeconds(self.playerLayer.player.currentItem.duration);
    //当前时间
    float rate = CMTimeGetSeconds(self.playerItem.currentTime) / CMTimeGetSeconds(self.playerItem.duration);
    self.huCurrTime = rate * self.totalTime;

    //构造主体播放器
    self.playInterfaceStyle = 1;
    
    
    //头部view
    [self createTopView];
    
    //中间view
    [self createMidView];
    
    
    //底部view
    [self createBottomView];
    
    //设置view
    [self createSetView];
    
    //弹幕view
    [self barrageView];
    
    [self dealWith];

    [self addObserver:self forKeyPath:@"playInterfaceStyle" options:NSKeyValueObservingOptionNew context:nil];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"playInterfaceStyle"]) {
//        huNormal = 0,//什么都没有
//        huSelect = 1,//上下view
//        huSet = 2,//左侧设置
//        huLocken = 3//锁屏状态

        
        switch (self.playInterfaceStyle) {
            case 0:
            {
                //什么都没有
                self.topView.hidden = YES;
                self.lockBtn.hidden = YES;
                self.bottomView.hidden = YES;
                
                self.setView.frame = CGRectMake(KmainWidth, 0, SetViewWidth, KmainHeight);
                
            }
                break;
            case 1:
            {
                //上下view
                
                self.topView.hidden = NO;
                self.lockBtn.hidden = NO;
                self.bottomView.hidden = NO;
                                
            }
                break;
            case 2:
            {
                //左侧设置
                __weak typeof(self) weakS = self;
                
                self.topView.hidden = YES;
                self.bottomView.hidden = YES;
                self.lockBtn.hidden = YES;
                
                [UIView animateWithDuration:0.3 animations:^{
                    weakS.setView.frame = CGRectMake(KmainWidth - SetViewWidth, 0, SetViewWidth, KmainHeight);
                    
                } completion:nil];
                

            }
                break;
            case 3:
            {
                //锁屏状态
                self.topView.hidden = YES;
                
                self.bottomView.hidden = YES;
                
                self.setView.frame = CGRectMake(KmainWidth, 0, SetViewWidth, KmainHeight);

            }
                break;

                
            default:
                break;
        }
        
        
        
    }
    
}

- (void)dealWith{
    
    
    if (self.hideViewTime  == 0) {
        self.hideViewTime = 3.0;
    }
    
    
    self.playBtn.selected = self.player.rate;
    
    self.movieProgressSlider.value = self.huCurrTime;
    
    if (self.player.rate == 1) {
        //正在播放,启动定时器
        dispatch_resume(self.gcdTimer);
    }
    
    
}

#pragma mark 顶部
- (void)createTopView
{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KmainHeight, TopViewHeight)];
    self.topView.backgroundColor = [UIColor yellowColor];
    
    UIButton *backB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TopViewHeight, TopViewHeight)];
    [backB setTitle:@"返回" forState:0];
    backB.backgroundColor = [UIColor lightGrayColor];
    [backB addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backB setTitleColor:[UIColor redColor] forState:0];
    [_topView addSubview:backB];
    self.backBtn = backB;
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake((KmainHeight - KmainWidth) / 2, 0, KmainWidth, TopViewHeight)];
    titleL.text = @"这里是标题";
    titleL.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:titleL];
    self.titleLabel = titleL;
    self.titleLabel.backgroundColor = [UIColor orangeColor];
    
    UIButton *setB = [[UIButton alloc] initWithFrame:CGRectMake(KmainHeight - TopViewHeight, 0, TopViewHeight, TopViewHeight)];
    [_topView addSubview:setB];
    [setB setTitleColor:[UIColor redColor] forState:0];
    [setB setTitle:@"设置" forState:0];
    setB.backgroundColor = [UIColor lightGrayColor];
    self.setBtn = setB;
    [setB addTarget:self action:@selector(set) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_topView];
    
    
}

//设置view
- (void)set
{
    
    self.playInterfaceStyle = huSet;
    

}

- (void)back{
 
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark 中间view
- (void)createMidView
{
    UIButton *lockBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, (KmainWidth - 80) / 2, 50, 50)];
    lockBtn.backgroundColor = [UIColor clearColor];
    self.lockBtn = lockBtn;
    [lockBtn setImage:[UIImage imageNamed:@"player_icon_unlock.png"] forState:0];
    [lockBtn setImage:[UIImage imageNamed:@"player_icon_lock.png"] forState:UIControlStateSelected];
//    [lockBtn setBackgroundColor:[UIColor lightTextColor]];
    [lockBtn addTarget:self action:@selector(lockBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lockBtn];
}

- (void)lockBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        self.playInterfaceStyle = huLocken;
    }else{
        self.playInterfaceStyle = huSelect;

    }
    
}



#pragma mark - 底部View
- (void)createBottomView{
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, KmainWidth - BottomViewHeight, KmainHeight, BottomViewHeight)];
    
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BottomViewHeight, BottomViewHeight)];

    
    [_playBtn setImage:[UIImage imageNamed:@"player_play.png"] forState:0];
    [_playBtn setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateSelected];

    
    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
    
    _movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(BottomViewHeight, (BottomViewHeight -10) / 2, KmainHeight - 250, 10)];
    
    [_movieProgressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_movieProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
    
    [_movieProgressSlider setThumbImage:[UIImage imageNamed:@"gamecenter_point"] forState:UIControlStateNormal];
    
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin:) forControlEvents:UIControlEventTouchDown];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    //最大时间
    _movieProgressSlider.maximumValue = self.totalTime;
    [_bottomView addSubview:_movieProgressSlider];
    
    //总时间
    UILabel *timeL = [[UILabel alloc] initWithFrame:CGRectMake(BottomViewHeight + 10 + KmainHeight - 250 , 0, 65, BottomViewHeight)];
    timeL.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:timeL];
    self.totalLabel = timeL;
    timeL.text = [self getTimeStr];
    timeL.font = [UIFont systemFontOfSize:10];
    timeL.textColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    
    UISwitch *danMuSwich = [[UISwitch alloc] initWithFrame:CGRectMake(KmainHeight - 70, (BottomViewHeight - 31) / 2, BottomViewHeight, BottomViewHeight)];
    danMuSwich.backgroundColor = [UIColor clearColor];
    [danMuSwich addTarget:self action:@selector(swi:) forControlEvents:UIControlEventValueChanged];
    [_bottomView addSubview:danMuSwich];
    
}


- (void)swi:(UISwitch *)swi
{
    
    if (swi.on) {
        [self.barageManager star];
        
    }else{
        
        [self.barageManager stop];
        
    }
}


//获取显示时间
- (NSString *)getTimeStr
{
    NSString *total = [self getMMSSFromSS:self.totalTime];
    
    NSString *nowT = [self getMMSSFromSS:self.huCurrTime];
    
    NSString *str = [NSString stringWithFormat:@"%@/%@",nowT,total];
    
    return str;
    
}


//传入 秒  得到  xx分钟xx秒
-(NSString *)getMMSSFromSS:(CGFloat)totalTime{
    
    NSString *toT = [NSString stringWithFormat:@"%f",totalTime];
    
    NSInteger seconds = [toT integerValue];
    
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%ld",seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%ld",seconds%60];
    //format of time
    if ([str_minute integerValue] < 10) {
        str_minute = [NSString stringWithFormat:@"0%ld",seconds/60];
    }
    
    if ([str_second integerValue] < 10) {
        str_second = [NSString stringWithFormat:@"0%ld",seconds%60];
    }
    
    
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
}


#pragma mark 播放&暂停
- (void)playClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    self.playInterfaceStyle = huSelect;
    
    
    if (btn.selected) {
        //暂停
        CMTime currentCMTime = CMTimeMake(self.huCurrTime,1);
        
        [self.player seekToTime:currentCMTime];
        
        [self.player play];
        
        // 启动定时器
        dispatch_resume(self.gcdTimer);
        
        
    }else{
        //播放
        //暂停定时器
        dispatch_suspend(self.gcdTimer);
        
        [self.player pause];
        
        
    }
    
}


- (dispatch_source_t)gcdTimer
{
    if (!_gcdTimer) {
        
        // 获得队列
        dispatch_queue_t queue = dispatch_get_main_queue();
        
        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        
        uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);//周期
        
        dispatch_source_set_timer(_gcdTimer, start, interval, 0);
        
//        __weak typeof(self) weakS = self;
        // 设置回调
        dispatch_source_set_event_handler(self.gcdTimer, ^{
            
            [self updataTime];
            
        });

        
    }
    
    return _gcdTimer;
}


#pragma mark 更新实时时间
- (void)updataTime
{
    float new = CMTimeGetSeconds(self.playerItem.currentTime) / CMTimeGetSeconds(self.playerItem.duration);
    
    self.huCurrTime = new * self.totalTime;
    
    NSLog(@"%f",self.huCurrTime);
    
    self.movieProgressSlider.value = self.huCurrTime;
    
    if (self.huCurrTime == self.totalTime) {
        
        dispatch_suspend(self.gcdTimer);
        
        self.playBtn.selected = NO;
        
        self.movieProgressSlider.value = 0;
        
        self.huCurrTime = 0;
        
        //回到起点
        [self.player seekToTime:kCMTimeZero];
        
    }
    self.totalLabel.text = [self getTimeStr];
    
}



#pragma mark 设置view
- (void)createSetView
{
    
    UIView *setView = [[UIView alloc] initWithFrame:CGRectMake(KmainHeight, 0, SetViewWidth, KmainWidth)];
    setView.backgroundColor = [UIColor redColor];
    setView.userInteractionEnabled = YES;
    [self.view addSubview:setView];
    self.setView = setView;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 50, SetViewWidth, 50)];
    slider.maximumValue = 1.0;
    slider.minimumValue = 0.3;
    slider.value = self.barAlpage;
    [setView addSubview:slider];
    
    [slider addTarget:self action:@selector(scrEnd:) forControlEvents:UIControlEventValueChanged];

    NSArray *title = @[@"上",@"中",@"下"];
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50 * i + 10, 150, 40, 40)];
        btn.backgroundColor = [UIColor darkGrayColor];
        [btn setTitle:title[i] forState:0];
        [btn addTarget:self action:@selector(hehe:) forControlEvents:UIControlEventTouchUpInside];
        [setView addSubview:btn];
        btn.tag = 230 + i;
    }
    
    
}

- (void)hehe:(UIButton *)btn
{
    switch (btn.tag) {
        case 230:
        {
            int s = ( KmainHeight / 2 ) / 40;
            
//            NSLog(@"%d",s);
            
            self.barageManager.trajectoryNum = s;
            self.barageManager.dataSource = [self dataSource:s];

            
        }
            break;
        case 231:
        {
            int s =  KmainHeight  / 40;

            
            self.barageManager.trajectoryNum = s;

            self.barageManager.dataSource = [self dataSource:s];


        }
            break;
        case 232:
        {
            int s = ( KmainHeight / 2 ) / 40;
            
            self.barageManager.trajectoryNum = s;
            self.barageManager.dataSource = [self dataSource:s];


        }
            break;

            
        default:
            break;
    }
}
- (void)scrEnd:(UISlider *)slider
{
    self.barAlpage = slider.value;
    
    
}


#pragma mark 弹幕
- (void)barrageView
{
    
    self.barageManager = [[BarrageManager alloc] init];
    
    self.barageManager.trajectoryNum = 5;
    
    __weak typeof (self) weakSelf = self;
    
    self.barageManager.dataSource = [self dataSource:1];
    
    self.barageManager.generateViewBlock = ^(BarrageView *view){
        
        [weakSelf addBarageView:view];
        
    };
    
    
}


- (NSMutableArray *)dataSource:(int)num
{
    NSMutableArray *data = [NSMutableArray array];
    
    for (int i = 0; i < 50; i++) {
        
        [data addObject:[NSString stringWithFormat:@"数据：%d",i * num]];
    }
    
    
    return data;
}



- (void)addBarageView:(BarrageView *)sview {
     
    sview.frame = CGRectMake(KmainWidth,15 + sview.trajectory * 40 , CGRectGetWidth(sview.bounds), 30);
    sview.backgroundColor = [UIColor lightGrayColor];
    sview.alpha = self.barAlpage;
    [self.view addSubview:sview];
    [self.view insertSubview:sview belowSubview:self.setView];
    [sview startAnimation];
    
}

#pragma mark 滑动条相关
//按住滑块
-(void)scrubbingDidBegin:(UISlider *)slider{
    //    _ProgressBeginToMove = _movieProgressSlider.value;
}

//释放滑块
-(void)scrubbingDidEnd:(UISlider *)slider{
    
    self.huCurrTime = slider.value;
    
    CMTime currentCMTime = CMTimeMake(self.huCurrTime,1);
    
    [self.player seekToTime:currentCMTime];
    
    self.totalLabel.text = [self getTimeStr];

    
}






#pragma makr 手势触摸相关
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    //锁屏状态
    if (self.playInterfaceStyle == huLocken) {
        return;
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    
    if (event.allTouches.count == 1) {
        
        if (self.playInterfaceStyle == huNormal) {
            //普通界面
            
            
            self.playInterfaceStyle = huSelect;
            
            
        }else if (self.playInterfaceStyle == huSelect) {
            //上下view
            
            if (point.y < TopViewHeight || point.y > KmainHeight - TopViewHeight * 2) {
                
                return;
            }
            
            
            self.playInterfaceStyle = huNormal;
            
        }else if (self.playInterfaceStyle == huSet) {
            //右侧设置
            if (point.x > KmainWidth - SetViewWidth) {
                return;
            }
            
            self.playInterfaceStyle = huNormal;
            
        }
        
        
    }
    
    
}






//允许横屏旋转
- (BOOL)shouldAutorotate{
    return YES;
}

//支持左右旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
}

//默认为右旋转
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

@end
