//
//  AppDelegate.m
//  Fast Pic
//
//  Created by Andrew Schreiber on 3/7/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.controller = [[MainViewController alloc]init];
    
    self.window.rootViewController = self.controller;
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"will resign active");
    self.controller.takingPhotos=NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"did enter background");
    [self saveImages];
    
    
}

- (void) saveImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self beginBackgroundUpdateTask];
        
        NSLog(@"Entered Background. Saving %lu images", (unsigned long)self.controller.images.count);
        
       // NSMutableArray *images = self.controller.images;
      //  self.library = [[ALAssetsLibrary alloc]init];
     //   self.savedPhotos=0;
        
        NSArray *images = [NSArray arrayWithArray:self.controller.images];
        
        for(UIImage *photo in images)
        {
          //  if([self.controller.images indexOfObject:photo]< self.controller.images.count-4) //Discard post home button press images
                UIImageWriteToSavedPhotosAlbum(photo, nil, @selector(updateSavedCount), nil);
            [self updateSavedCount];
            
        }
      //  [self endBackgroundUpdateTask];

        
    //    [self saveToLibrary:self.controller.images];
        NSLog(@"Wrote photos to drive");
        
        
    });
}
/*
-(void)saveToLibrary: (NSMutableArray *)images
{
    NSLog(@"started save to library");
    
    __weak ALAssetsLibrary *lib =  self.library;
    //  NSLog(@"Called save to library with library: %@",self.library);
    __weak AppDelegate *appDelegate = self;
    
    
    [self.library addAssetsGroupAlbumWithName:@"Fast Pic" resultBlock:^(ALAssetsGroup *group) {
        NSLog(@"In Block");
        NSLog(@"Group is editable? %hhd",            group.isEditable);
        
        ///checks if group previously created
        if(group == nil){
            NSLog(@"Group already exists");
            //enumerate albums
            [lib enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:^(ALAssetsGroup *g, BOOL *stop)
             {
                 //if the album is equal to our album
                 if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Fast Pic"]) {
                     
                     //save image
                     
                     for (NSData *photo in images)
                     {
                         [lib writeImageDataToSavedPhotosAlbum:photo metadata:nil
                                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                                   
                                                   [appDelegate updateSavedCount];
                                                   
                                               }];
                     }
                     
                 }
             }failureBlock:^(NSError *error){
                 NSLog(@"error in saving to library 2");
                 
             }];
            
        }else{
            // save image directly to library
            NSLog(@"New group");
            
            
            for (NSData *photo in images)
            {
                [lib writeImageDataToSavedPhotosAlbum:photo metadata:nil
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          
                                          [appDelegate updateSavedCount];
                                          
                                      }];
            }
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Error in saving to library");
    }];
    NSLog(@"finished save to library;");
}
 */

-(void)updateSavedCount
{
    self.savedPhotos++;
    NSLog(@"New saved count is %i", self.savedPhotos);
    if(self.savedPhotos == self.controller.images.count)
    {
        self.controller.images=nil;
        [self endBackgroundUpdateTask];
        
    }
}
- (void) beginBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    NSLog(@"End background update");
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Will enter foreground");
    self.controller.takingPhotos=YES;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
