//
//  ViewController.m
//  HUAVPlayer
//
//  Created by huweiya on 16/10/17.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)playerBtnA:(UIButton *)sender {
    
    
    MoviePlayerViewController *vc = [[MoviePlayerViewController alloc] init];
    vc.hideViewTime = 5.0;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
