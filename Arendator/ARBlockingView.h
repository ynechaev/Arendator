//
//  ARBlockingView.h
//  Arendator
//
//  Created by Grig Uskov on 14/9/13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ARBlockingView : UIView

+ (void)showWithTitle:(NSString *)title;
+ (void)setTitle:(NSString *)title;
+ (void)hide;

@end