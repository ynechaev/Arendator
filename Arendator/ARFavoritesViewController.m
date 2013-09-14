//
//  ARFavoritesViewController.m
//  Arendator
//
//  Created by Grig Uskov on 14/9/13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import "ARFavoritesViewController.h"

@implementation ARFavoritesViewController

- (id)init {
    self = [super init];
    
    self.title = NSLocalizedString(@"tabBarFavorites", @"");
    self.tabBarItem.image = [UIImage imageNamed:@"tbFavorites"];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.hidden = YES;
}

@end