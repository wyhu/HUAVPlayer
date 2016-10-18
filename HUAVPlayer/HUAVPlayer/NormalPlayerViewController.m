//
//  NormalPlayerViewController.m
//  HUAVPlayer
//
//  Created by huweiya on 16/10/18.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#define KmainWidth [UIScreen mainScreen].bounds.size.width
#define KmainHeight [UIScreen mainScreen].bounds.size.height
#define playerHeight 220
#define btnViewHeight 44




#import "NormalPlayerViewController.h"
#import "FullScreenPlayerViewController.h"

@interface NormalPlayerViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) UIView *topView;//头
@property (nonatomic, strong) UIView *bottomView;//尾



@end

@implementation NormalPlayerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.playerLayer removeFromSuperlayer];
    [self.topView removeFromSuperview];
    [self.bottomView removeFromSuperview];
    
    
    self.playerLayer.frame = CGRectMake(0, 64, KmainWidth, playerHeight);
    
    [self.view.layer addSublayer:self.playerLayer];
    
    [self.view addSubview:self.topView];
    
    [self.view addSubview:self.bottomView];
    
    

    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"一级播放";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    
}

- (AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        
        //设置静音状态也可以播放声音
        AVAudioSession *avAudionSession = [AVAudioSession sharedInstance];
        [avAudionSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        AVURLAsset *avURLAsset = [AVURLAsset assetWithURL:self.url];
        
        //得到视频总时间
        
        //    Float64 duration = CMTimeGetSeconds(avURLAsset.duration);
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avURLAsset];
        
        
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        
        _playerLayer  = [AVPlayerLayer playerLayerWithPlayer:player];
        
        _playerLayer.borderWidth = 2.0;
        
        _playerLayer.borderColor = [UIColor redColor].CGColor;
        

        
    }
    
    return _playerLayer;
}


- (UIView *)topView
{
    if (!_topView) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KmainWidth, btnViewHeight)];
        _topView.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [backBtn setImage:[UIImage imageNamed:@"collection_topbar_icon_back_pressed"] forState:0];
        [_topView addSubview:backBtn];
        [backBtn addTarget:self action:@selector(backBntA) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _topView;
}

- (void)backBntA{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + playerHeight - btnViewHeight, KmainWidth, btnViewHeight)];
        _bottomView.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [playBtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
        [playBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_bottomView addSubview:playBtn];
        [playBtn addTarget:self action:@selector(playBtnA:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *fullBtn = [[UIButton alloc] initWithFrame:CGRectMake(KmainWidth - 44, 0, 44, 44)];
        [fullBtn setImage:[UIImage imageNamed:@"player_icon_lock"] forState:UIControlStateNormal];
        [_bottomView addSubview:fullBtn];
        [fullBtn addTarget:self action:@selector(fullBtn) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _bottomView;
}

- (void)playBtnA:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        //播放
        [self.playerLayer.player play];
    }else{
        //暂停
        [self.playerLayer.player pause];
        
    }
    
}

- (void)fullBtn{
    FullScreenPlayerViewController *fullVC = [[FullScreenPlayerViewController alloc] init];
    
    fullVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    fullVC.playerLayer = self.playerLayer;
    
    fullVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:fullVC animated:YES completion:nil];
    
    
}

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + playerHeight, KmainWidth, KmainHeight - 64 - playerHeight) style:0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
