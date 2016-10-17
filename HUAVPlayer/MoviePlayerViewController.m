//
//  MoviePlayerViewController.m
//  HUAVPlayer
//
//  Created by huweiya on 16/10/17.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BarrageManager.h"
#import "BarrageView.h"


#define TopViewHeight 55 //头部界面高度
#define BottomViewHeight 72//底部界面高度

#define SetViewWidth 200//底部界面高度

#define KmainWidth [UIScreen mainScreen].bounds.size.width
#define KmainHeight [UIScreen mainScreen].bounds.size.height



@interface MoviePlayerViewController ()


@property (nonatomic, strong) BarrageManager *manager;

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
@property (nonatomic,strong)UILabel *textLabel;//时间展示label

//右侧设置界面
@property (nonatomic, strong) UIView *setView;


/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t gcdTimer;

//判断是否已经进入队列
@property (nonatomic, assign) BOOL isHidenQueue;
//判断是否锁屏
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic, strong) UIButton *lockBtn;//播放


@end

@implementation MoviePlayerViewController



- (void)viewWillDisappear:(BOOL)animated
{
   
    dispatch_cancel(self.gcdTimer);
    
    [self removeObserver:self forKeyPath:@"playInterfaceStyle" context:nil];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"H===%f,-- W===%f",KmainHeight,KmainWidth);

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self prefersStatusBarHidden];
    
    [self shouldAutorotate];
    
    //构造主体播放器
    [self createAVPlayer];
    
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

    
    if (self.hideViewTime  == 0) {
        self.hideViewTime = 3.0;
    }
    
    self.isHidenQueue = YES;
//
//    [self performSelector:@selector(interNormal) withObject:nil afterDelay:self.hideViewTime];
    
    
    [self addObserver:self forKeyPath:@"playInterfaceStyle" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];


}

/** 添加观察者必须要实现的方法 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (self.playBtn.selected && (self.playInterfaceStyle == 1 || self.playInterfaceStyle == 2) && self.isHidenQueue) {
        __weak typeof(self) weakS = self;
        
        self.isHidenQueue = NO;
        
        double delayInSeconds = self.hideViewTime;
        
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakS.setView.frame = CGRectMake(KmainWidth, 0, SetViewWidth, KmainHeight);
            
            weakS.topView.hidden = YES;
            
            weakS.bottomView.hidden = YES;
        
            weakS.isHidenQueue = YES;
        });
        
    }
    
    
}





- (void)createAVPlayer
{
    
    //设置静音状态也可以播放声音
    AVAudioSession *avAudionSession = [AVAudioSession sharedInstance];
    [avAudionSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //获取视频 url
    self.url = [[NSBundle mainBundle] URLForResource:@"chenyifaer" withExtension:@"mp4"];
    
    AVURLAsset *avURLAsset = [AVURLAsset assetWithURL:self.url];
    
    //得到视频总时间

    Float64 duration = CMTimeGetSeconds(avURLAsset.duration);

    self.totalTime = duration;

    self.playerItem = [AVPlayerItem playerItemWithAsset:avURLAsset];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    playerLayer.frame = CGRectMake(0, 0, KmainHeight, KmainWidth);
    
    
    [self.view.layer addSublayer:playerLayer];
    
    //默认上下view央视
    self.playInterfaceStyle = 1;

}

//顶部视图
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
- (void)back{
    //    __weak typeof(self) weakSelf = self;
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        //do someing
    //        [weakSelf.avTimer invalidate];
    //        weakSelf.avTimer = nil;
    //    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark 中间view
- (void)createMidView
{
    UIButton *lockBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, (KmainWidth - 80) / 2, 80, 80)];
    lockBtn.backgroundColor = [UIColor redColor];
    self.lockBtn = lockBtn;
    [lockBtn setTitle:@"锁屏" forState:UIControlStateNormal];
    [lockBtn setTitle:@"已锁" forState:UIControlStateSelected];
    [lockBtn addTarget:self action:@selector(lockBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lockBtn];
}

- (void)lockBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    self.isLock = btn.selected;
    
    if (btn.selected) {
        //锁屏
        self.setView.frame = CGRectMake(KmainWidth, 0, SetViewWidth, KmainHeight);
        
        self.topView.hidden = YES;
        
        self.bottomView.hidden = YES;

        
    }else{
        //解开
        self.topView.hidden = NO;
        
        self.bottomView.hidden = NO;
        
        self.playInterfaceStyle = huSelect;
        

    }
    
}



#pragma mark - 底部View
- (void)createBottomView{
    CGFloat titleLableWidth = 400;
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, KmainWidth - BottomViewHeight, KmainHeight, BottomViewHeight)];
    
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BottomViewHeight, BottomViewHeight)];
    
    _playBtn.backgroundColor  = [UIColor clearColor];
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [_playBtn setTitle:@"暂停" forState:UIControlStateSelected];

    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
    
    _movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(BottomViewHeight + 10, 15, _bottomView.frame.size.width - BottomViewHeight - 20 - 80, 10)];
    _movieProgressSlider.backgroundColor = [UIColor yellowColor];
    
    [_movieProgressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_movieProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
    
    [_movieProgressSlider setThumbImage:[UIImage imageNamed:@"progressThumb.png"] forState:UIControlStateNormal];
    
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin:) forControlEvents:UIControlEventTouchDown];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    //最大时间
    _movieProgressSlider.maximumValue = self.totalTime;
    [_bottomView addSubview:_movieProgressSlider];
    
    //进度条
    UILabel *timeL = [[UILabel alloc] initWithFrame:CGRectMake(KmainHeight - 80, 0, 80, 50)];
    timeL.backgroundColor = [UIColor redColor];
    [_bottomView addSubview:timeL];
    timeL.text = [self getMMSSFromSS:self.totalTime];

    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.height/2-titleLableWidth/2, 30, titleLableWidth, BottomViewHeight - 30)];
    
    _textLabel.backgroundColor = [UIColor redColor];
    //_textLabel.text = @"我是各种操作";
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:_textLabel];
    
    //在totalTimeLabel上显示总时间
    
    self.textLabel.text = [self getMMSSFromSS:CMTimeGetSeconds(_player.currentItem.currentTime)];

    [self.view addSubview:_bottomView];
}

//设置view
- (void)createSetView
{
 
    UIView *setView = [[UIView alloc] initWithFrame:CGRectMake(KmainHeight, 0, SetViewWidth, KmainWidth)];
    setView.backgroundColor = [UIColor redColor];
    setView.userInteractionEnabled = NO;
    [self.view addSubview:setView];
    self.setView = setView;
    
}

- (void)set{
    
//    NSLog(@"H===%f,-- W===%f",KmainHeight,KmainWidth);

    __weak typeof(self) weakS = self;
    
    self.playInterfaceStyle = huSet;
    
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        weakS.setView.frame = CGRectMake(KmainWidth - SetViewWidth, 0, SetViewWidth, KmainHeight);

    } completion:nil];
    
    
}


- (void)barrageView
{
    
    self.manager = [[BarrageManager alloc] init];
    
    self.manager.trajectoryNum = 5;
    
    __weak typeof (self) weakSelf = self;
    
    self.manager.generateViewBlock = ^(BarrageView *view){
        [weakSelf addBarageView:view];
    };
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(200 + BottomViewHeight + 10, 0, BottomViewHeight, BottomViewHeight)];
    
    btn.backgroundColor = [UIColor blueColor];
    
    [btn setTitle:@"开始" forState:0];
    
    [self.bottomView addSubview:btn];
    
    btn.tag = 120;
    
    
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, BottomViewHeight, BottomViewHeight)];
    [self.bottomView addSubview:btn2];
    
    [btn2 setTitle:@"结束" forState:0];
    
    btn2.backgroundColor = [UIColor blueColor];
    
    btn2.tag = 121;
    
    [btn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void)btnAction:(UIButton *)btn
{
    
    switch (btn.tag) {
        case 120:
        {
            //开始
            [self.manager star];
            
        }
            break;
        case 121:
        {
            //暂停
            [self.manager stop];
        }
            break;
            
            
        default:
            break;
    }
    
}



- (void)addBarageView:(BarrageView *)sview {
    
    sview.frame = CGRectMake(KmainWidth, sview.trajectory * 70 , CGRectGetWidth(sview.bounds), 60);

    sview.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:sview];
//    [[UIApplication sharedApplication].keyWindow addSubview:sview];
    
    [sview startAnimation];
    
    
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
        
        __weak typeof(self) weakS = self;
        // 设置回调
        dispatch_source_set_event_handler(self.gcdTimer, ^{
            
            [weakS updataTime];
            
        });
        
        
    }else{
        //播放
        
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
        
    }
    
    return _gcdTimer;
}


#pragma mark 更新实时时间
- (void)updataTime
{
    
    float new = CMTimeGetSeconds(_player.currentItem.currentTime) / CMTimeGetSeconds(_player.currentItem.duration);
    
//    NSLog(@"-------------%f",new);
    
    self.huCurrTime = new * self.totalTime;
    
    self.movieProgressSlider.value = self.huCurrTime;
    
    if (self.huCurrTime == self.totalTime) {
        
        dispatch_suspend(self.gcdTimer);
        
        self.playBtn.selected = NO;
        
        self.movieProgressSlider.value = 0;
        
        self.huCurrTime = 0;
        
        CMTime currentCMTime = CMTimeMake(self.huCurrTime,1);
        
        [self.player seekToTime:currentCMTime];
        

    }
    
    
    self.textLabel.text = [self getMMSSFromSS:self.huCurrTime];

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



//按住滑块
-(void)scrubbingDidBegin:(UISlider *)slider{
//    _ProgressBeginToMove = _movieProgressSlider.value;
}

//释放滑块
-(void)scrubbingDidEnd:(UISlider *)slider{
    
//    [self UpdatePlayer];
    self.huCurrTime = slider.value;
    
    CMTime currentCMTime = CMTimeMake(self.huCurrTime,1);

    self.textLabel.text = [self getMMSSFromSS:slider.value];
    
    [self.player seekToTime:currentCMTime];

}







//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
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



#pragma makr 手势触摸相关
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    //锁屏状态
    if (self.isLock) {
        return;
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    __weak typeof(self) weakS = self;

    if (event.allTouches.count == 1) {

    if (self.playInterfaceStyle == huNormal) {
        //普通界面
        
//        if (!_isHidenQueue) {
//            [weakS performSelector:@selector(interNormal) withObject:nil afterDelay:self.hideViewTime];
//
//        }
        
        weakS.topView.hidden = NO;
        
        weakS.bottomView.hidden = NO;
        
        self.playInterfaceStyle = huSelect;
        
        
    }else if (self.playInterfaceStyle == huSelect) {
        //上下view
        
        if (point.y < TopViewHeight || point.y > KmainHeight - TopViewHeight * 2) {
            
            return;
        }
        
        
        weakS.topView.hidden = YES;
        
        weakS.bottomView.hidden = YES;

        self.playInterfaceStyle = huNormal;
        
    }else if (self.playInterfaceStyle == huSet) {
        //右侧设置
        
        if (point.x > KmainWidth - SetViewWidth) {
            return;
        }

        self.setView.frame = CGRectMake(KmainWidth, 0, SetViewWidth, KmainHeight);
        
        self.playInterfaceStyle = huNormal;
    
    }
        
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
