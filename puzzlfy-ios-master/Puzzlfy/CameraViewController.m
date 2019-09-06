//
//  CameraViewController.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/7/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "CameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Constants.h"
#import "SegueNames.h"
#import "AVCamPreviewView.h"
#import "StickersViewController.h"
#import "SoundUtilities.h"
#import "ViewUtilities.h"
#import "EventsManager.h"
#import "Notifications.h"
#import "PuzzlfyUIApplication.h"
#import "DBManager.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *switchCameraMode;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;

//- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)changeCameraMode:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic) BOOL isVideoMode;
@property (strong, nonatomic) NSObject *camAsset;
@property (nonatomic) int assetType;
@property (strong, nonatomic) IBOutlet UIView *vRecordingIndicator;
@property (strong, nonatomic) IBOutlet UIView *vRecordingIndicatorContainer;
@property (nonatomic) BOOL cancelSave;
@property (nonatomic) BOOL stillRecording;
@property (nonatomic) BOOL canStartRecording;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSInteger fileNumber;
@property (nonatomic) BOOL resetSession;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) IBOutlet UIImageView *vLibraryPermissionImageView;
@property (strong, nonatomic) IBOutlet UIImageView *vMicPermissionImageView;
@property (nonatomic) BOOL showMicPermissionImage;
@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)playLoopSound
{
    [SoundUtilities stopMainSound];
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterForegroundNotification) name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    
    //Adding round corners to Recording Indicator view
    [[self.vRecordingIndicator layer]setCornerRadius:self.vRecordingIndicator.frame.size.width/2];
    
    if (![[DBManager getInstance]getMicPermission]) {
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Puzzlfy" message:MIC_PERMISSION_TXT delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [self.alertView show];
    }
    else {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"granted");
            }
            else {
                self.showMicPermissionImage = YES;
                NSLog(@"denied");
            }
        }];
        [self setupSession];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self setupSession];
    [self setupSessionWillAppear];
    [[DBManager getInstance]setMicPermission:YES];
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (void)dismissAlertView
{
    if(self.alertView && !self.alertView.hidden)
    {
        [self.alertView dismissWithClickedButtonIndex:1 animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self dismissAlertView];
}

- (void)setupSession
{
    // Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetMedium];
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
                
                //                [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setMasksToBounds:YES];
                [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setFrame:self.previewView.frame];
                [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setCornerRadius:30.0f];
			});
		}
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:audioDeviceInput])
		{
			[session addInput:audioDeviceInput];
		}
		
		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([session canAddOutput:movieFileOutput])
		{
			[session addOutput:movieFileOutput];
			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
			if ([connection isVideoStabilizationSupported])
				[connection setEnablesVideoStabilizationWhenAvailable:YES];
			[self setMovieFileOutput:movieFileOutput];
		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
}

- (void)shutdownSession
{
    if (self.session) {
        [self.session stopRunning];
        self.session = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.closeButton setEnabled:YES];
    if ([[DBManager getInstance]getMicPermission]) {
        [self setupSessionWillAppear];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.showMicPermissionImage) {
        [self micPermissionAnimation];
    }
}

- (void)micPermissionAnimation
{
    [self.vMicPermissionImageView setAlpha:0.1];
    [self.vMicPermissionImageView setHidden:NO];
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.vMicPermissionImageView setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:1.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.vMicPermissionImageView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.vMicPermissionImageView setHidden:YES];
        }];
    }];
}

- (void)setupSessionWillAppear
{
    self.canStartRecording = YES;
    [self.vRecordingIndicatorContainer setHidden:YES];
    [self playLoopSound];
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak CameraViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			CameraViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
			});
		}]];
		[[self session] startRunning];
	});
}


- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    if (self.sessionQueue) {
        dispatch_async([self sessionQueue], ^{
            [[self session] stopRunning];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
            [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        });
    }
}

- (void)recieveApplicationWillEnterBackgroundNotification
{
    self.canStartRecording = YES;
    self.stillRecording = NO;
    [self stopVideoRecording];
}

- (void) recieveApplicationWillEnterForegroundNotification
{
    self.canStartRecording = YES;
    self.cancelSave = NO;
    if (self.resetSession) {
        [self shutdownSession];
        [self setupSession];
        [self setupSessionWillAppear];
        [[self session] startRunning];
        [self.stillButton setEnabled:YES];
        [[self cameraButton] setEnabled:YES];
        [[self switchCameraMode] setEnabled:YES];
    }
    
    self.startTime = [NSDate new];
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == RecordingContext)
	{
		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRecording)
			{
				[[self cameraButton] setEnabled:NO];
				[[self switchCameraMode] setEnabled:NO];
			}
			else
			{
//                [[self stillButton] setEnabled:NO];
				[[self cameraButton] setEnabled:YES];
				[[self switchCameraMode] setEnabled:YES];
			}
		});
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
				[[self switchCameraMode] setEnabled:YES];
				[[self stillButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
				[[self switchCameraMode] setEnabled:NO];
//				[[self stillButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

- (double)getTimeInterval
{
    if (self.startTime) {
        return [[NSDate new]timeIntervalSinceDate:self.startTime];
    }
    else {
        return 0;
    }
}

- (void)toggleMovieRecording
{
    if ((!self.startTime || [self getTimeInterval] > 1 ) && [self.vLibraryPermissionImageView isHidden]) {
        dispatch_async([self sessionQueue], ^{
            if (![[self movieFileOutput] isRecording] && self.canStartRecording)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.vRecordingIndicatorContainer setHidden:NO];
                    self.startTime = [NSDate new];
                    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] stopIdleTime];
                });
                self.canStartRecording = NO;
                self.stillRecording = YES;
                
                [self setLockInterfaceRotation:YES];
                
                if ([[UIDevice currentDevice] isMultitaskingSupported])
                {
                    // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                    [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
                
                // Turning OFF flash for video recording
                [CameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
                
                // Start recording to a temporary file.
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString stringWithFormat:@"movie_%d",self.fileNumber] stringByAppendingPathExtension:@"mov"]];
                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                self.fileNumber++;
            }
            else if (self.stillRecording)
            {
                self.stillRecording = NO;
                dispatch_sync(dispatch_get_main_queue(), ^{

                    [EventsManager reportEventWithType:EVENT_CAMERA_VIDEO_SELECTED withParameters:nil];
                    [self.vRecordingIndicatorContainer setHidden:YES];
                    [self.stillButton setEnabled:NO];
                    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] resetIdleTimer];
                });
                [[self movieFileOutput] stopRecording];
            }
        });
    }
}

- (IBAction)changeCamera:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
	[[self cameraButton] setEnabled:NO];
	[[self switchCameraMode] setEnabled:NO];
	[[self stillButton] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
			[[self switchCameraMode] setEnabled:YES];
			[[self stillButton] setEnabled:YES];
		});
	});
}

- (IBAction)snapStillImage:(id)sender
{
   // [SoundUtilities playSoundWithName:@"puzzlfy-button-takeaphoto" andFormat:SOUND_TYPE_MP3];
    if (!self.isVideoMode) {
        [self.closeButton setEnabled:NO];
        [self.stillButton setEnabled:NO];

        [EventsManager reportEventWithType:EVENT_CAMERA_IMAGE_SELECTED withParameters:nil];

        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            [CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    [ViewUtilities saveImageToPhotoLibrary:image];
                    
                    self.camAsset = image;
                    self.assetType = PUZZLE_MEDIA_TYPE_IMAGE_CAMERA;
                    
                    [self performSegueWithIdentifier:SEGUE_GOTO_STICKERS sender:self];
                }
            }];
        });
    }
    else {
        [self toggleMovieRecording];
    }
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (IBAction)changeCameraMode:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    if (self.isVideoMode) {
        [self.vLibraryPermissionImageView setHidden:YES];
        [self.switchCameraMode setImage:[UIImage imageNamed:CAMERA_BTN] forState:UIControlStateNormal];
        self.isVideoMode = NO;
    }
    else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
            [self.vLibraryPermissionImageView setHidden:NO];
        }
        [self.switchCameraMode setImage:[UIImage imageNamed:VIDEO_BTN] forState:UIControlStateNormal];
        self.isVideoMode = YES;
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	if (error) {
		NSLog(@"%@", error);
        self.resetSession = YES;
    }
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    if (!self.cancelSave) {
        ALAssetsLibrary *lib = [ViewUtilities defaultAssetsLibrary];
        [lib writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error)
                NSLog(@"%@", error);
            [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                self.camAsset = asset;
                self.assetType = PUZZLE_MEDIA_TYPE_VIDEO_ASSET;
                [self performSegueWithIdentifier:SEGUE_GOTO_STICKERS sender:self];
            } failureBlock:^(NSError *error) {
                NSLog(@"Error");
            }];
            [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
            
            if (backgroundRecordingID != UIBackgroundTaskInvalid)
                [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }];
        [[self stillButton] setEnabled:YES];
    }
    else {
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        self.cancelSave = NO;
        [[self stillButton] setEnabled:YES];
        self.canStartRecording = YES;
    }
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
                [ViewUtilities presentError:@"Puzzlfy doesn't have permission to use Camera, please change privacy settings"];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GOTO_STICKERS]) {
        [((StickersViewController*)segue.destinationViewController) setPuzzleAssetType:self.assetType];
        [((StickersViewController*)segue.destinationViewController) setPuzzleAsset:self.camAsset];
    }
    else{
        [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    }
    [self resetNavBarBackBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self stopVideoRecording];
}

- (void)stopVideoRecording
{
    if (self.stillRecording) {
        self.cancelSave = YES;
    }
    if (self.isVideoMode) {
        [[self movieFileOutput] stopRecording];
        [self.vRecordingIndicatorContainer setHidden:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
}

@end
