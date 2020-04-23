//
//  ViewController.m
//  CrashCollectDemo
//
//  Created by LIUSONG on 2020/4/23.
//  Copyright © 2020 LIUSONG. All rights reserved.
//

#import "ViewController.h"
#import "CrashManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[CrashManager shareInstance] uploadLogInfo];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	
	// 构造crash
	[self performSelector:@selector(testCrashAction)];
}

@end
