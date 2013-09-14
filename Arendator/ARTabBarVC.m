//
//  ARTabBarVC.m
//  Arendator
//
//  Created by Yury Nechaev on 13.09.13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import "ARTabBarVC.h"
#import "ARSearchViewController.h"
#import "ARSearchesViewController.h"
#import "ARAboutViewcontroller.h"

@interface ARTabBarVC ()

@end

@implementation ARTabBarVC

static ARTabBarVC *instanceTabBarVC = nil;

+ (ARTabBarVC *)sharedInstance {
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceTabBarVC = [[ARTabBarVC alloc] init];
    });
    return instanceTabBarVC;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ARSearchesViewController *searchCon = [[ARSearchesViewController alloc] init];
        UINavigationController *navCon1 = [[UINavigationController alloc] initWithRootViewController:searchCon];

        ARAboutViewcontroller *aboutCon = [[ARAboutViewcontroller alloc] init];
        UINavigationController *navCon2 = [[UINavigationController alloc] initWithRootViewController:aboutCon];
        
        [self setViewControllers:@[navCon1, navCon2]];

        
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
