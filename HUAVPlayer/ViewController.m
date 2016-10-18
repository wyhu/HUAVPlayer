//
//  ViewController.m
//  HUAVPlayer
//
//  Created by huweiya on 16/10/17.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "ViewController.h"
#import "NormalPlayerViewController.h"
#import "FullScreenPlayerViewController.h"


@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}



- (IBAction)playerBtnA:(UIButton *)sender {
    
    switch (sender.tag) {
        case 200:
        {
            NormalPlayerViewController *normalVC = [[NormalPlayerViewController alloc] init];
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"chenyifaer" withExtension:@"mp4"];
            normalVC.url = url;
            [self.navigationController pushViewController:normalVC animated:YES];
//            return;
//            
//            
//            MoviePlayerViewController *vc = [[MoviePlayerViewController alloc] init];
//            vc.hideViewTime = 5.0;
//            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 201:
        {
//            FullScreenViewController *fullVC = [[FullScreenViewController alloc] init];
//            
//            fullVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            
//            fullVC.playerLayer = _playerLayer;
//            
//            fullVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//         
//            
//            [self presentViewController:fullVC animated:YES completion:nil];

            
        }
            break;

            
        default:
            break;
    }
    
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
