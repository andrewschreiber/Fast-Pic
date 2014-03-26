//
//  AppDelegate.h
//  Fast Pic
//
//  Created by Andrew Schreiber on 3/7/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property( nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property ( strong, nonatomic)MainViewController *controller;

@property (nonatomic)int savedPhotos;

@end
