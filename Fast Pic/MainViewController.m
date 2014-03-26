//
//  MainViewController.m
//  Fast Pic
//
//  Created by Andrew Schreiber on 3/7/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()


- (AVCaptureDevice*)rearCamera;
- (void)captureImage;
-(void)returnPauseToWhite;
-(void)timerCapture:(NSTimer *)timer;


- (void)animatePhoto;

@property (nonatomic,strong)UIButton *pauseButton;
@property (nonatomic, strong)UIImageView *backgroundView;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong)AVCaptureConnection *stillImageConnection;
@property (nonatomic,strong)NSTimer *captureTimer;

@property (nonatomic)int photosTaken;


@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.takingPhotos=YES;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Called view did load");
    [self startCamera];
    NSLog(@"Finished view did load");
    
    
	// Do any additional setup after loading the view.
}
-(int)photosTaken
{
    if(!_photosTaken)
    {
        _photosTaken = 0;
    }
    return  _photosTaken;
}
-(UIButton *)pauseButton
{
    if(!_pauseButton)
    {
        _pauseButton = [[UIButton alloc]init];
        UIImage *image = [UIImage imageNamed:@"pauseWhiteCircle"];
        NSLog(@"image exists? %@",image);
        _pauseButton.frame=CGRectMake(130, 410, 60, 60);
        [_pauseButton setBackgroundImage:image forState:UIControlStateNormal];
        
        [_pauseButton addTarget:self
                         action:@selector(pauseButtonPress:)
               forControlEvents:UIControlEventTouchUpInside];
        
        NSLog(@"finished making pauseButton");
    }
    return _pauseButton;
    
    
    
}

-(UIImageView *)backgroundView
{
    if (!_backgroundView) {
        
        CGRect iPhone4SCam=  CGRectMake(self.view.frame.origin.x-30, self.view.frame.origin.y, 360, self.view.frame.size.height);
        
        _backgroundView = [[UIImageView alloc]initWithFrame:iPhone4SCam];
        _backgroundView.clipsToBounds=YES;
        NSLog(@"Finished making backgroundView");
    }
    return _backgroundView;
    
}

-(void)pauseButtonPress:(UIButton *)pauseButton
{
    [self pause];
    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"playWhiteCircle"] forState:UIControlStateNormal];

    
    
}

-(void)pause
{
    self.takingPhotos=!self.takingPhotos;
    NSLog(@"Pushed pause button. Taking photos is now %i",self.takingPhotos);
    self.photosTaken=0;

}

-(NSMutableArray *)images
{
    if (!_images) {
        _images= [[NSMutableArray alloc]init];
    }
    return _images;
}

-(void)animatePhoto
{
    NSLog(@"Called animatePhoto");
    dispatch_async(dispatch_get_main_queue(), ^{

    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseColorCircle"] forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(returnPauseToWhite) userInfo:nil repeats:NO];
    });
    
}

-(void)returnPauseToWhite
{
    NSLog(@"Called returnPauseToWhite");
    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"pauseWhiteCircle"] forState:UIControlStateNormal];
}


-(void)viewDidAppear:(BOOL)animated
{
    self.takingPhotos=YES;
    NSLog(@"Finished view did appear");
    
}



- (AVCaptureDevice *)rearCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}



- (void)startCamera
{
    //capture session setup
    
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.rearCamera error:nil];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.stillImageOutput automaticallyEnablesStillImageStabilizationWhenAvailable];
    
    
    
     self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    
    [self.captureSession addInput:newVideoInput];
    
    [self.captureSession addOutput:self.stillImageOutput];
 
    
    // -startRunning will only return when the session started (-> the camera is then ready)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self.captureSession startRunning];
        NSLog(@"finished start running");
        [self makeConnection];
        
    });
    
}

-(void)makeConnection
{
    NSArray *connections = [self.stillImageOutput connections];
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
                NSLog(@"Found connection %@",connection);
				self.stillImageConnection = connection;
                break;
			}
		}
	}
    
    [self captureImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self startCaptureLoop];
    });
    
    
}

-(void)startCaptureLoop
{
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.pauseButton];
    
    self.captureTimer= [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(timerCapture:) userInfo:nil repeats:YES];
    // [[NSRunLoop mainRunLoop] addTimer:self.captureTimer forMode:NSRunLoopCommonModes];
    
}

-(void)timerCapture:(NSTimer *)timer
{
    if(self.takingPhotos)
    {
        
        [self captureImage];
        /*
         if(self.pauseButton.backgroundColor == [UIColor whiteColor])
         {
         self.pauseButton.backgroundColor = [UIColor redColor];
         
         }
         else
         {
         self.pauseButton.backgroundColor = [UIColor whiteColor];
         
         }*/
        
    }
    
}

- (void)captureImage
{
    // NSLog(@"called captureImage");
    //Before we can take a snapshot, we need to determine the specific connection to be used
    
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.stillImageConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           if (imageDataSampleBuffer != NULL) {
                                                               // as for now we only save the image to the camera roll, but for reusability we should consider implementing a protocol
                                                               // that returns the image to the object using this view
                                                               
                                                               if(self.takingPhotos){
                                                                   NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                   
                                                                   
                                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                       
                                                                       
                                                                       NSLog(@"Took photo: %i",self.photosTaken);
                                                                       
                                                                       UIImage *newPicture = [UIImage imageWithData:imgData];
                                                                       if(self.photosTaken % 10==0 || self.photosTaken<3)
                                                                       {
                                                                           NSLog(@"Saved photo: %i",self.photosTaken);
                                                                           [self animatePhoto];


                                                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                                                           

                                                                              
                                                                               [self.images addObject:newPicture];
                                                                              
                                                                             //  UIImageWriteToSavedPhotosAlbum(newPicture, nil, nil, nil);
                                                                               
                                                                        });
                                                                           
                                                                       }
                                                                       
                                                                       
                                                                       [self setImageAsBackground:newPicture: self.photosTaken];
                                                                       self.photosTaken++;
                                                                       
                                                                       
                                                                   });
                                                                   
                                                               }
                                                               
                                                           }
                                                           else
                                                           {
                                                               NSLog(@"Error: %@", [error localizedDescription]);
                                                           }
                                                           
                                                       }];
    
}

-(void)setImageAsBackground: (UIImage *)backgroundImage : (int)photosTaken
{
    
    //  NSLog(@"default image size = %@",NSStringFromCGSize( backgroundImage.size));
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.backgroundView.image=backgroundImage;
            NSLog(@"updated background: %i",photosTaken);

    
        
    });
    
    
    //NSLog(@"background image rect = %@", NSStringFromCGRect(self.backgroundView.frame));
    
}



- (void)didReceiveMemoryWarning
{
    NSLog(@"%@", [self description]);
    [super didReceiveMemoryWarning];
}


@end
