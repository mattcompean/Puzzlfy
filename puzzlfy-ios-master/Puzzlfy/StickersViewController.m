//
//  StickersViewController.m
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickersViewController.h"
#import "SegueNames.h"
#import "PuzzleViewController.h"
#import "UIView+Shadow.h"
#import "StickersManager.h"
#import "StickerCell.h"
#import "StickerUIView.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "PuzzlfyIAPHelper.h"
#import "Notifications.h"
#import "ViewUtilities.h"
#import "DBManager.h"
#import "JigsawPuzzleEngine.h"
#import "SoundUtilities.h"
#import "StickersMainView.h"
#import "EventsManager.h"
#import <CoreMedia/CMTime.h>
#import "PuzzlfyUIApplication.h"
#import "AnimatingPuzzlePiece.h"
#import "AppDelegate.h"

@interface StickersViewController ()

@property (nonatomic, strong) NSMutableArray* pieces;
@property (nonatomic, strong) NSMutableArray* stickersCats;
@property (nonatomic, strong) NSMutableDictionary* unpurchasedProducts;
@property (nonatomic, strong) NSArray* currentStickersArray;
@property (nonatomic) CGRect bottomViewFrame;
@property (nonatomic) CGRect imagePlaceholderEndFrame;
@property (nonatomic) CGRect imagePlaceholderStartFrame;
@property (nonatomic) int stickersCount;
@property (nonatomic, strong) UITapGestureRecognizer* tapBottomBarPanGestureRecognizer;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *videoLayer;
@property (strong, nonatomic) NSArray *products;
@property (nonatomic) BOOL isVideo;
@property (nonatomic) int CategorySelectedIndex;
@property (strong, nonatomic) UIImage *puzzleImage;
@property (strong, nonatomic) IBOutlet UIScrollView *bouncingBottomView;
@property (strong, nonatomic) UIView *blackView;
@property (nonatomic) BOOL touchInProgress;
@property (strong, nonatomic) UIImageView *currentImageView;
@property (strong, nonatomic) UIPanGestureRecognizer *currentPanRecongizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchImageScrollViewRecognizer;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotateImageScrollViewRecognizer;
@property (strong, nonatomic) UIView *current_stickerView;
@property (strong) StickerUIView *panImageView;
@property (nonatomic) NSString* stickersNibName;
@property (strong, nonatomic) UIImageView *vWatermark;

@end

@implementation StickersViewController

#define VIDEO_PLACEHOLDER_END_Y 20
#define IMAGE_PLACEHOLDER_END_Y 78
#define PUZZLE_ANIMATION_DURATION 0.4
#define STICKERS_BOTTOMVIEW_ANIMATION_DURATION 0.2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initStickersViewNibName
{
    self.stickersNibName =  @"PictureStickersView";
    if (self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_ASSET || self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_URL)
    {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setStopIdleSound:YES];
        self.stickersNibName =  @"VideoStickersView";
        self.isVideo = YES;
        [SoundUtilities stopMainSound];
        CALayer *layer = [CALayer layer];
        [layer setBackgroundColor:[UIColor blackColor].CGColor];
        [layer setFrame:self.vBackgroundImageView.bounds];
        [layer setOpacity:0.7f];
        [self.vBackgroundImageView.layer addSublayer:layer];
    }
}

-(void)setCurrentStickerView:(UIView *)view
{

    self.current_stickerView = view;
}

-(void)playLoopSound
{
    if(!self.isVideo)
        [SoundUtilities playMainSoundWithName:@"Another Happy Traveling loop"];
}

-(void)initVideo
{
    AVURLAsset* firstAsset = [[AVURLAsset alloc]initWithURL:(self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_ASSET) ? ((ALAsset *)self.puzzleAsset).defaultRepresentation.url : (NSURL*)self.puzzleAsset options:nil];
    
    // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 2 - Video track
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                        ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    CMTime time = firstAsset.duration;
    for(int i=0; i<self.videoLoopCount; i++)
    {
        AVURLAsset* secondAsset = [[AVURLAsset alloc]initWithURL:(self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_ASSET) ? ((ALAsset *)self.puzzleAsset).defaultRepresentation.url : (NSURL*)self.puzzleAsset options:nil];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                            ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];
        firstAsset = secondAsset;
        time = CMTimeAdd(time, secondAsset.duration);
    }
    
    
    // 3 - Audio track
    if(self.audioTrack)
    {
        AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:self.audioTrack withExtension:@"mp3"] options:nil];
        AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, time)
                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        AVPlayerItem * item = [[AVPlayerItem alloc] initWithAsset:mixComposition];
        self.avPlayer = [AVPlayer playerWithPlayerItem:item];

    }
    else {
        self.avPlayer = [AVPlayer playerWithURL: (self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_ASSET) ? ((ALAsset *)self.puzzleAsset).defaultRepresentation.url : (NSURL*)self.puzzleAsset];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.ImageAreaView = [[[NSBundle mainBundle] loadNibNamed:self.stickersNibName owner:self options:nil] objectAtIndex:0];
    
    if (self.isVideo) {
        self.imagePlaceholder = [[UIView alloc] initWithFrame:CGRectMake(VIDEO_STICKERS_VIEW_X, VIDEO_STICKERS_VIEW_Y, self.ImageAreaView.frame.size.width, self.ImageAreaView.frame.size.height)];
        [self.ImageAreaView.scrollView.layer setCornerRadius:15.0f];
        [self.ImageAreaView.scrollView.layer setMasksToBounds:YES];
        [self.ImageAreaView.scrollView setClipsToBounds:YES];
        [self.ImageAreaView.scrollView setScrollEnabled:NO];
        ((StickersMainView*)self.view).videoStickers = self.ImageAreaView;
        [self initVideo];

    }
    else {
        self.imagePlaceholder = [[UIView alloc] initWithFrame:CGRectMake(PICTURE_STICKERS_VIEW_X, PICTURE_STICKERS_VIEW_Y, self.ImageAreaView.frame.size.width, self.ImageAreaView.frame.size.height)];
    }
    [self.imagePlaceholder addSubview:self.ImageAreaView];
    [self.view addSubview:self.imagePlaceholder];
    
    self.imageScrollView = self.ImageAreaView.scrollView;
    
    [self initializeCollectionViews];
    
    [self.ImageAreaView setCornerRadius:10];
    
    [self adjustContentImage];
    
    self.bottomViewFrame = self.bottomView.frame;
    self.imagePlaceholderEndFrame = CGRectMake(self.imagePlaceholder.frame.origin.x, self.isVideo ? VIDEO_PLACEHOLDER_END_Y : IMAGE_PLACEHOLDER_END_Y, self.imagePlaceholder.frame.size.width, self.imagePlaceholder.frame.size.height);
    self.imagePlaceholderStartFrame = self.imagePlaceholder.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayerNotificationNotification:) name:PLAYER_ACTIONS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterForegroundNotification) name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    [self.view bringSubviewToFront:self.bouncingBottomView];
    self.bouncingBottomView.delegate = self;
    self.pinchImageScrollViewRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchImageScrollViewRecognizer.delegate = self;
    self.rotateImageScrollViewRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    self.rotateImageScrollViewRecognizer.delegate = self;
    
    if (self.bAddWatermark) {
        [self addWatermark];
    }
    else if (self.puzzleAssetType == PUZZLE_MEDIA_TYPE_IMAGE_ASSET || self.puzzleAssetType == PUZZLE_MEDIA_TYPE_VIDEO_ASSET || self.puzzleAssetType == PUZZLE_MEDIA_TYPE_IMAGE_CAMERA) {
        [self addWatermark];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.vWatermark) {
        [self.vWatermark setFrame:CGRectMake(self.imageScrollView.contentOffset.x + 5, ((self.imageScrollView.frame.size.height-self.vWatermark.frame.size.height)-5)+self.imageScrollView.contentOffset.y
                                             , self.vWatermark.frame.size.width, self.vWatermark.frame.size.height)];
    }
}

- (void)addWatermark
{
    self.vWatermark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:WATERMARK_IMG]];
    [self.vWatermark setFrame:CGRectMake(self.imageScrollView.contentOffset.x + 5, ((self.imageScrollView.frame.size.height-self.vWatermark.frame.size.height)-5)+self.imageScrollView.contentOffset.y, self.vWatermark.frame.size.width, self.vWatermark.frame.size.height)];
    [self.imageScrollView addSubview:self.vWatermark];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initStickersViewNibName];
    self.CategorySelectedIndex = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
   
    if(InAppPurchaseEnabled)
        [self initializeProducts];
    
    [self initializeCategoriesImages];
    
    self.tapBottomBarPanGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBottomView)];
    [self.bottomSwipeView addGestureRecognizer:self.tapBottomBarPanGestureRecognizer];
    self.stickersCount = 0;
    
    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] resetPuzzlfyBtnTimer];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLAYER_ACTIONS_NOTIFICATION object:nil];
    [self.avPlayer pause];
    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] stopPuzzlfyBtnTimer];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setStopIdleSound:NO];
}

- (UIImageView *)adjustImageAspectRatio:(UIImage *)image
{
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.imageScrollView.frame.size.width , self.imageScrollView.frame.size.height)];
    
    //check if aspect ratio of image is 4:3
    if(ABS(image.size.width/image.size.height - 4.0/3.0) < 0.1) {
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    //check if not 4:3 but landscape
    else if(image.size.width > image.size.height) {
        CGFloat aspectRatio = image.size.width/image.size.height;
        [newImageView setFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.height*aspectRatio, self.imageScrollView.frame.size.height)];
        [newImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    //check if portrait
    else {
        CGFloat aspectRatio = image.size.width/image.size.height;
        [newImageView setFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.width/aspectRatio)];
        [newImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    
    [newImageView setImage:image];
    return newImageView;
}

- (void)adjustVideoLayerAspectRatio
{
    UIImage *image = [self getImageFromVideo];
    //check if aspect ratio of image is 4:3
    if(ABS(image.size.width/image.size.height - 4.0/3.0) < 0.1)
    {
        [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
    //check if not 4:3 but landscape
    else if(image.size.width > image.size.height)
    {
        CGFloat aspectRatio = image.size.width/image.size.height;
        [self.videoLayer setFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.height*aspectRatio, self.imageScrollView.frame.size.height)];
        [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    //check if portrait
    else
    {
        CGFloat aspectRatio = image.size.width/image.size.height;
        [self.videoLayer setFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.width/aspectRatio)];
        [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }

    
}

- (void)adjustContentImage
{
    [self.imageScrollView setBackgroundColor:[UIColor blackColor]];
    
    if (self.isVideo) {
        
        self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        [self.videoLayer setFrame:self.imageScrollView.bounds];

        [self adjustVideoLayerAspectRatio];
    
        [self.imageScrollView.layer addSublayer:self.videoLayer];
        [self.imageScrollView setContentSize:self.videoLayer.frame.size];
        [self.avPlayer play];
    }
    else {
        if (self.puzzleAssetType == PUZZLE_MEDIA_TYPE_IMAGE_ASSET) {
            ALAssetRepresentation *defaultRep = [(ALAsset *)self.puzzleAsset defaultRepresentation];
            self.imageView = [self adjustImageAspectRatio: [UIImage imageWithCGImage:[defaultRep fullScreenImage]]];
        }
        else if (self.puzzleAssetType == PUZZLE_MEDIA_TYPE_IMAGE || self.puzzleAssetType == PUZZLE_MEDIA_TYPE_IMAGE_CAMERA){
            self.imageView = [self adjustImageAspectRatio: (UIImage*)self.puzzleAsset];
        }
        [self.imageScrollView addSubview:self.imageView];
        [self.imageScrollView setContentSize:self.imageView.frame.size];
    }
    
    self.imageScrollView.delegate = self;
    [self enableScrollViewInteraction];
    
    CGRect bounds = self.imageScrollView.bounds;
    CGSize contentSize = self.imageScrollView.contentSize;
    CGFloat offsetX = MAX(0, (contentSize.width - bounds.size.width) * 0.5f);
    CGFloat offsetY = MAX(0, (contentSize.height - bounds.size.height) * 0.5f);
    CGPoint centerOffset = CGPointMake(offsetX, offsetY);
    
    [self.imageScrollView setContentOffset: centerOffset animated: NO];
    
}

-(void)addStickerToImageScrollView:(UIView*)view
{
    [self.imageScrollView addSubview:view];
    [self.imageScrollView bringSubviewToFront:view];
}

- (void)productPurchased:(NSNotification *)notification {
    [self.stickersCats addObject: [self.unpurchasedProducts objectForKey:notification.object]];
    [self.unpurchasedProducts removeObjectForKey:notification.object];
    [self.categoriesCollectionView reloadData];
}

- (void)receivePlayerNotificationNotification:(NSNotification *)notification
{
    NSDictionary* data= (NSDictionary*)[notification object];
    switch ([[data objectForKey:@"action"] intValue]) {
        case PLAYER_PAUSE:
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setStopIdleSound:NO];
            [self.avPlayer pause];
            break;
        case PLAYER_RESTART:
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setStopIdleSound:YES];
            [self.avPlayer seekToTime:kCMTimeZero];
            [self.avPlayer play];
            break;
        case PLAYER_PLAY:
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setStopIdleSound:YES];
            [self.avPlayer play];
            break;
    }
}

- (void)recieveApplicationWillEnterBackgroundNotification
{
    [self.stickesCollectionView setScrollEnabled:YES];
    if (self.panImageView && self.currentPanRecongizer) {
        [self.panImageView removeFromSuperview];
        self.panImageView = nil;
        self.currentPanRecongizer = nil;
        self.currentImageView = nil;
        self.touchInProgress = NO;
    }
        
    if (self.blackView) {
        [SoundUtilities stopSound];
        [self.view setUserInteractionEnabled:YES];
        for (UIImageView *image in self.pieces) {
            [image.layer removeAllAnimations];
        }
        [self.blackView removeFromSuperview];
        if (self.isVideo) {
            [self.avPlayer pause];
            [self.imageView removeFromSuperview];
            [self.imageScrollView.layer addSublayer:self.videoLayer];
        }
        [SoundUtilities stopSound];
    }
    else if (self.isVideo) {
        [self.avPlayer pause];
    }
}

- (void)recieveApplicationWillEnterForegroundNotification
{
    if (self.stickersCount <=0) {
        [self enableScrollViewInteraction];
    }
    if (self.isVideo && self.avPlayer) {
        [self.avPlayer play];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.ImageAreaView.videoPlayBtn setImage: [UIImage imageNamed: PLAY_IMG] forState:UIControlStateSelected];
    [self.ImageAreaView.videoPlayBtn setSelected:YES];
}

-(void) initializeCategoriesImages
{
    self.stickersCats = [[NSMutableArray alloc] initWithArray:[StickersManager loadStickersFromFile:@"stickers"]];
    if(InAppPurchaseEnabled)
    {
        self.unpurchasedProducts = [[NSMutableDictionary alloc] init];
        for (NSDictionary* dict in self.stickersCats)
        {
            if([dict objectForKey:@"productIdentifier"])
            {
                if(![[PuzzlfyIAPHelper sharedInstance] productPurchased:[dict objectForKey:@"productIdentifier"]])
                {
                    [self.stickersCats removeObject:dict];
                    [self.unpurchasedProducts setObject:dict forKey:[dict objectForKey:@"productIdentifier"]];
                }
            }
        }
    }
}
- (void)initializeCollectionViews
{
    self.categoriesCollectionView.delegate = self;
    self.categoriesCollectionView.dataSource = self;
    self.stickesCollectionView.delegate = self;
    self.stickesCollectionView.dataSource = self;
    [self.categoriesContainerView makeInsetShadowWithRadius:15 Color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] Directions:[NSArray arrayWithObjects:@"top", @"bottom", @"left", @"right", nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (UIImage *)getImageFromVideo
{
    [self.avPlayer pause];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.avPlayer.currentItem.asset];
    [imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
    [imageGenerator setAppliesPreferredTrackTransform:YES];
    [imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:self.avPlayer.currentTime actualTime:NULL error:NULL];
    UIImage *videoImage = [[UIImage alloc]initWithCGImage:thumb];
    CGImageRelease(thumb);
    
    return videoImage;
}

- (UIImage *)getCurrentDisplayedImage
{
    if (self.isVideo) {
        [self.avPlayer pause];
        [self.imageScrollView setClipsToBounds:NO];
        self.imageView = [self adjustImageAspectRatio:[self getImageFromVideo]];
        [self.imageScrollView addSubview:self.imageView];
        [self.imageScrollView sendSubviewToBack:self.imageView];
        [self.videoLayer removeFromSuperlayer];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.imageScrollView.frame.size, NO, 1);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -self.imageScrollView.contentOffset.x, -self.imageScrollView.contentOffset.y);
    [self.imageScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self.imageScrollView setClipsToBounds:YES];
    return viewImage;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self resetNavBarBackBtn];
    [self.avPlayer pause];
    if([segue.identifier isEqualToString: SEGUE_GOTO_PUZZLE_VIEW])
    {
        PuzzleViewController *puzzleViewController = (PuzzleViewController *) segue.destinationViewController;
        puzzleViewController.image = self.puzzleImage;
    }
}

- (void)disableScrollViewInteraction
{
    [self.imageScrollView setScrollEnabled:NO];
    [self.imageScrollView setMaximumZoomScale:1];
    [self.imageScrollView addGestureRecognizer:self.pinchImageScrollViewRecognizer];
    [self.imageScrollView addGestureRecognizer:self.rotateImageScrollViewRecognizer];
}

- (void)enableScrollViewInteraction
{
    if (self.isVideo) {
        return;
    }
    [self.imageScrollView setScrollEnabled:YES];
    [self.imageScrollView setMaximumZoomScale:4.0];
    [self.imageScrollView setMinimumZoomScale:1];
    [self.imageScrollView removeGestureRecognizer:self.pinchImageScrollViewRecognizer];
    [self.imageScrollView removeGestureRecognizer:self.rotateImageScrollViewRecognizer];
}

- (IBAction)PuzzlfyButtonClicked:(UIButton *)sender {
    [self.imageScrollView setContentOffset:[self.imageScrollView contentOffset] animated:NO];
    [self disableScrollViewInteraction];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt: self.stickersCount],PARAM_EVT_KEY_STICKERS_USED, nil];
    [EventsManager reportEventWithType:EVENT_GAME_STARTED withParameters:params];
    
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    self.puzzleImage = [self getCurrentDisplayedImage];
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SAVE_PUZZLE_PICTURES"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        if (self.isVideo)
            [ViewUtilities saveImageToPhotoLibrary:self.puzzleImage];
        else if(self.stickersCount > 0)
            [ViewUtilities saveImageToPhotoLibrary:self.puzzleImage];
    }

    [self initPuzzlePieces:self.puzzleImage];
}

#pragma collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView == self.categoriesCollectionView)
        return self.stickersCats.count;
    return [self.currentStickersArray count];
}

- (StickerCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.categoriesCollectionView)
    {
        StickerCell *cell = (StickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
        NSString *imageName = [((NSDictionary*)[self.stickersCats objectAtIndex:indexPath.row]) objectForKey:@"image"];
        cell.image.image = [UIImage imageNamed:imageName];
        if(self.CategorySelectedIndex == indexPath.row)
        {
            [cell setBorder:YES];
        }
        [cell setExclusiveTouch:YES];
        return cell;
    }
    else
    {
        StickerCell *cell = (StickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"stickerCell" forIndexPath:indexPath];
        cell.image.image = [UIImage imageNamed:[((NSDictionary*)[self.currentStickersArray objectAtIndex:indexPath.row]) objectForKey:@"thumb"]];
        cell.index = indexPath.row;
        if(cell.recognizer)
            [cell removeGestureRecognizer:cell.recognizer];
        cell.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleStickersPan:)];
        cell.recognizer.delegate = self;
        cell.recognizer.delaysTouchesBegan = YES;
        [cell addGestureRecognizer:cell.recognizer];
        [cell setExclusiveTouch:YES];
        return cell;
    }
    
}


- (UIImage*)getImageWithSize:(UIImage*)image withImage:(CGSize)newImageSize {

    UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    [image drawAtPoint:CGPointMake(roundf((newImageSize.width-image.size.width)/2),
                                        roundf((newImageSize.height-image.size.height)/2))];
    [blank drawAtPoint:CGPointMake(roundf((newImageSize.width-blank.size.width)/2),
                                         roundf((newImageSize.height-blank.size.height)/2))];
    UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

- (void) handleStickersPan:(UIPanGestureRecognizer *) recognizer
{
    UIImageView *cellImageView = ((StickerCell*) recognizer.view).image;
    StickerUIView *imageView = [[StickerUIView alloc] initWithImage:cellImageView.image andDelegate:self];
    [imageView setImage:[UIImage imageNamed:[((NSDictionary*)[self.currentStickersArray objectAtIndex:((StickerCell*) recognizer.view).index]) objectForKey:@"image"]]];
    CGPoint translation = [recognizer translationInView:self.view];
    if (self.currentImageView != (UIImageView *)recognizer.view && self.touchInProgress) {
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan && !self.touchInProgress) {
        [self.stickesCollectionView setScrollEnabled:NO];
        if (imageView.superview != self.view) {
            self.currentImageView = (UIImageView *)recognizer.view;
            self.currentPanRecongizer = recognizer;
            
            CGPoint center = [self.view convertPoint:cellImageView.center fromView:cellImageView];
            
            self.panImageView = imageView;
            [self.view addSubview:self.panImageView];
            self.panImageView.center = center;
            
            self.touchInProgress = YES;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.panImageView.center = CGPointMake(self.panImageView.center.x + translation.x, self.panImageView.center.y + translation.y);
        CGPoint newCenter = [self.imageScrollView convertPoint:self.panImageView.center fromView:self.view];
        CGPoint point = CGPointMake(newCenter.x - self.imageScrollView.contentOffset.x, newCenter.y - self.imageScrollView.contentOffset.y);
        CGRect frame = self.imageScrollView.frame;
        if (!CGRectContainsPoint(frame, point) ) {
            [self.panImageView setAlpha:0.5];
        }
        else {
            [self.panImageView setAlpha:1];
        }
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.panImageView.center = CGPointMake(self.panImageView.center.x + translation.x, self.panImageView.center.y + translation.y);
        CGPoint newCenter = [self.imageScrollView convertPoint:self.panImageView.center fromView:self.view];
        CGPoint point = CGPointMake(newCenter.x - self.imageScrollView.contentOffset.x, newCenter.y - self.imageScrollView.contentOffset.y);
        CGRect frame = self.imageScrollView.frame;
        if (!CGRectContainsPoint(frame, point) ) {
            [self.panImageView setAlpha:0.5];
        }

        [self.panImageView removeFromSuperview];

        if(CGRectContainsPoint(frame, point)) {
            if ([self.imageScrollView zoomScale] < [self.imageScrollView minimumZoomScale]) {
                [self.imageScrollView setZoomScale:[self.imageScrollView minimumZoomScale]];
            }
            [self.panImageView setCenter:newCenter];
            [self addStickerToImageScrollView:self.panImageView];
            [self.stickesCollectionView setScrollEnabled:YES];
            [self disableScrollViewInteraction];
            self.stickersCount++;
            if(self.stickersCount % 5 == 0)
                [SoundUtilities playSoundWithName:@"puzzlfy-stickers-encouragement" andFormat:SOUND_TYPE_MP3];
            else
                [SoundUtilities playSoundWithName:@"puzzlfy-stickers-addsticker" andFormat:SOUND_TYPE_MP3];
            
            NSString *stickerID = [((NSDictionary*)[self.currentStickersArray objectAtIndex:((StickerCell *)recognizer.view).index]) objectForKey:@"id"];
            [[DBManager getInstance]updateUsedStickers:stickerID];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:stickerID,PARAM_EVT_KEY_STICKER_ID, nil];
            [EventsManager reportEventWithType:EVENT_STICKERS_USED withParameters:params];
        }

        self.panImageView = nil;
        self.currentPanRecongizer = nil;
    
        self.touchInProgress = NO;
        [self.stickesCollectionView setScrollEnabled:YES];
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.categoriesCollectionView)
    {
        [(StickerCell*)[collectionView cellForItemAtIndexPath:indexPath] setBorder:NO];
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //selecting category
    if(collectionView == self.categoriesCollectionView)
    {
        [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
        if(self.bottomView.hidden)
        {
            [self openBottomView];
        }
        self.currentStickersArray = (NSArray*)[(NSDictionary*)[self.stickersCats objectAtIndex:indexPath.row] objectForKey:@"stickers"];
        self.CategorySelectedIndex = (int)indexPath.row;
        [(StickerCell*)[collectionView cellForItemAtIndexPath:indexPath] setBorder:YES];
        if(self.panImageView)
        {
            [self.panImageView removeFromSuperview];
            self.panImageView = nil;
            self.currentPanRecongizer = nil;
            self.touchInProgress = NO;
            [self.stickesCollectionView setScrollEnabled:YES];
        }
        [self.stickesCollectionView reloadData];
        [self.stickesCollectionView setContentOffset:CGPointZero animated:NO];
    }
    //selecting sticker
    else {
        if ([self.imageScrollView zoomScale] < [self.imageScrollView minimumZoomScale]) {
            [self.imageScrollView setZoomScale:[self.imageScrollView minimumZoomScale]];
        }
        [SoundUtilities playSoundWithName:@"puzzlfy-stickers-addsticker" andFormat:SOUND_TYPE_MP3];
        [self disableScrollViewInteraction];
        
        UIImageView *cellImageView = ((StickerCell*)[collectionView cellForItemAtIndexPath:indexPath]).image;
        StickerUIView *imgView = [[StickerUIView alloc] initWithImage:cellImageView.image andDelegate:self];
        [imgView setImage:[UIImage imageNamed:[((NSDictionary*)[self.currentStickersArray objectAtIndex:indexPath.row]) objectForKey:@"image"]]];
        CGPoint center = CGPointMake(self.imageScrollView.center.x + self.imageScrollView.contentOffset.x, self.imageScrollView.center.y + self.imageScrollView.contentOffset.y);
        [imgView setCenter:center];
        [self addStickerToImageScrollView:imgView];
        self.stickersCount++;
        if(self.stickersCount % 5 == 0)
            [SoundUtilities playSoundWithName:@"puzzlfy-stickers-encouragement" andFormat:SOUND_TYPE_MP3];
        NSString *stickerID = [((NSDictionary*)[self.currentStickersArray objectAtIndex:indexPath.row]) objectForKey:@"id"];
        [[DBManager getInstance]updateUsedStickers:stickerID];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:stickerID,PARAM_EVT_KEY_STICKER_ID, nil];
        [EventsManager reportEventWithType:EVENT_STICKERS_USED withParameters:params];
    }
}

#pragma open close bottom view
- (void)openBottomView
{
    CGRect startingFrame = CGRectMake(self.bottomViewFrame.origin.x, self.bottomViewFrame.origin.y + self.bottomViewFrame.size.height, self.bottomViewFrame.size.width, self.bottomViewFrame.size.height);
    self.bottomView.frame = startingFrame;
    [self.bottomView setHidden:NO];
    //do bottom view animation
    [UIView animateWithDuration:STICKERS_BOTTOMVIEW_ANIMATION_DURATION
                          delay:0.0
                        options:0
                     animations:^{
                         self.bottomView.frame = self.bottomViewFrame;
                         self.imagePlaceholder.frame = self.imagePlaceholderEndFrame;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}

-(void)closeBottomView
{
    CGRect endFrame = CGRectMake(self.bottomViewFrame.origin.x, [UIScreen mainScreen].bounds.size.height, self.bottomViewFrame.size.width, self.bottomViewFrame.size.height);
    [self.bottomView setTranslatesAutoresizingMaskIntoConstraints: YES];
    [UIView animateWithDuration:STICKERS_BOTTOMVIEW_ANIMATION_DURATION
                          delay:0.0
                        options:0
                     animations:^{
                         self.bottomView.frame = endFrame;
                         self.imagePlaceholder.frame = self.imagePlaceholderStartFrame;
                     }
                     completion:^(BOOL finished){
                         [self.bottomView setHidden:YES];
                         [self.bottomView setTranslatesAutoresizingMaskIntoConstraints: NO];
                         StickerCell *cell = (StickerCell*)[self.categoriesCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.CategorySelectedIndex inSection:0]];
                         if(cell)
                         {
                             [cell setBorder:NO];
                             [self.categoriesCollectionView reloadData];
                             self.CategorySelectedIndex = -1;
                         }
                     }];
}



#pragma scroll View
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView != self.imageScrollView || !scrollView.scrollEnabled) //added to disable zooming after stickers added
        return nil;
    return self.imageView;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView == self.bouncingBottomView && velocity.y < -1.25)
    {
        [self closeBottomView];
    }
}

float minScale = 0.3f;
float maxScale = 10.0f;
-(void)handlePinch:(UIPinchGestureRecognizer *) sender
{
    if(!self.current_stickerView)
        return;
    CGFloat factor = [sender scale];
    StickerUIView* stickerView = (StickerUIView*)self.current_stickerView;
    
    if (factor > 1) {
        if(([self xscale:stickerView.transform] < maxScale && [self yscale:stickerView.transform] < maxScale) || factor <= stickerView.lastScale)
        {
            CGAffineTransform t = makeTransform(stickerView.lastScaleFactor + (factor-1), stickerView.lastScaleFactor + (factor-1),
                                                atan2f(stickerView.transform.b, stickerView.transform.a), stickerView.transform.tx, stickerView.transform.ty);
            if([self xscale:t] < maxScale && [self yscale:t] < maxScale)
            {
                stickerView.transform = t;
            }
            stickerView.lastScale = factor;
        }
        else{
            [sender setScale:stickerView.lastScale];
        }
    } else if(([self xscale:stickerView.transform] > minScale && [self yscale:stickerView.transform] > minScale) || factor >= stickerView.lastScale){
        CGAffineTransform t = makeTransform(stickerView.lastScaleFactor * factor, stickerView.lastScaleFactor * factor,
                                            atan2f(stickerView.transform.b,stickerView.transform.a), stickerView.transform.tx, stickerView.transform.ty);
        if([self xscale:t] > minScale && [self yscale:t] > minScale)
        {
            stickerView.transform = t;
        }
        stickerView.lastScale = factor;
    }
    else{
        [sender setScale:stickerView.lastScale];
    }
    
    //Save the new "scale" factor
    if (sender.state == UIGestureRecognizerStateEnded) {
        if((([self xscale:stickerView.transform] < maxScale && [self yscale:stickerView.transform] < maxScale) || factor <= stickerView.lastScale) && factor > 1) {
            stickerView.lastScaleFactor = MIN(stickerView.lastScaleFactor + (factor-1), maxScale);
        } else if(([self xscale:stickerView.transform] > minScale && [self yscale:stickerView.transform] > minScale) || factor >= stickerView.lastScale){
            stickerView.lastScaleFactor = MAX(stickerView.lastScaleFactor*factor, minScale);
        }
        self.current_stickerView = nil;
        // stickerView.lastScale = 1;
    }
}

-(void)handleRotate:(UIRotationGestureRecognizer*)sender
{
    if(!self.current_stickerView)
        return;
    StickerUIView* stickerView = (StickerUIView*)self.current_stickerView;
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
        stickerView.transform = CGAffineTransformRotate([stickerView transform], [sender rotation]);
        [sender setRotation:0];
    }
}

#pragma stickerUIView gesture recognizers
-(void)viewTapped:(UITapGestureRecognizer *) sender
{
    [self.imageScrollView bringSubviewToFront:sender.view];
}

-(void)viewPinched:(UIPinchGestureRecognizer *) sender
{
    [self handlePinch:sender];
}
-(void)viewRotated:(UIRotationGestureRecognizer *) sender
{
    [self handleRotate:sender];
}


-(void)viewPaned:(UIPanGestureRecognizer *) sender
{
    CGPoint translation = [sender translationInView:self.imageScrollView];
    CGRect frame = self.ImageAreaView.frame;
    if(self.isVideo)
    {
        frame = self.imageScrollView.frame;
    }

    if([sender state] == UIGestureRecognizerStateBegan) {
        [self.imageScrollView bringSubviewToFront:((UIPanGestureRecognizer *) sender).view];
    }
    else if([sender state] == UIGestureRecognizerStateChanged)
    {
        sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
        CGPoint point = CGPointMake(sender.view.center.x - self.imageScrollView.contentOffset.x,
                                    sender.view.center.y - self.imageScrollView.contentOffset.y);
        //fade sticker if its center is outside scrollview
        if(!CGRectContainsPoint(frame, point))
        {
            sender.view.alpha = 0.5;
        }
        else
        {
            sender.view.alpha = 1;
        }
    }
    else if([sender state] == UIGestureRecognizerStateEnded)
    {
        sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
        CGPoint point = CGPointMake(sender.view.center.x - self.imageScrollView.contentOffset.x,
                                    sender.view.center.y - self.imageScrollView.contentOffset.y);
        if(!CGRectContainsPoint(frame, point))
        {
            [sender.view removeFromSuperview];
            self.stickersCount--;
            if(self.stickersCount<=0 && !self.isVideo){ //restore scrolling and zooming
                [self enableScrollViewInteraction];
            }
        }
    }
    [sender setTranslation:CGPointMake(0, 0) inView:self.imageScrollView];

}

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;
    
    return transform;
}

- (CGFloat) xscale:(CGAffineTransform)t
{
    return sqrt(t.a * t.a + t.c * t.c);
}

- (CGFloat) yscale:(CGAffineTransform)t
{
    return sqrt(t.b * t.b + t.d * t.d);
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (IBAction)moreStickersButton:(UIButton *)sender
{
    
    [EventsManager reportEventWithType:EVENT_MORE_STICKERS_CLICKED withParameters:nil];
    
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    if(InAppPurchaseEnabled)
    {
        //we have only one product
        SKProduct *product = _products[0];
        //put this line in the proper place (restore button)
        [[PuzzlfyIAPHelper sharedInstance] restoreCompletedTransactions];
        
        [[PuzzlfyIAPHelper sharedInstance]  buyProduct:product];
    }
    else{
        [ViewUtilities presentInformation:@"Coming Soon!"];
    }
}

-(void)initializeProducts
{
    [[PuzzlfyIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
        else{
            //failed to get products
        }
    }];
}

- (void)initPuzzlePieces:(UIImage*)img
{
    [self.view setUserInteractionEnabled:NO];
    self.pieces = [[NSMutableArray alloc] init];
    CGPoint diff = [[DBManager getInstance] getNumberOfPuzzlePieces];
    
    JigsawPuzzleEngine* engine = [[JigsawPuzzleEngine alloc] initWithImage:img.CGImage withDifficultyValue:[[DBManager getInstance] getDifficulty] withX:diff.x andY:diff.y];
   
    self.blackView = [[UIView alloc] initWithFrame:self.imageView.frame];
    [self.blackView setBackgroundColor:[UIColor blackColor]];
    [self.imageScrollView addSubview:self.blackView];
    
    NSMutableArray* randomizedPieces = [[NSMutableArray alloc] init];

    for (int i = 0; i < engine.tilesX * engine.tilesY; i++) {
        [randomizedPieces addObject:[NSNumber numberWithInt:i]];
        float scale = 1.01;
        UIImage* image = [UIImage imageWithCGImage:([engine puzzlePieceAtIndex:[[randomizedPieces objectAtIndex:i] intValue]]).image scale:scale orientation:UIImageOrientationUp];
        AnimatingPuzzlePiece* imageView = [[AnimatingPuzzlePiece alloc] initWithImage:image];
        [self.blackView addSubview:imageView];
        int x = (([engine puzzlePieceAtIndex:[[randomizedPieces objectAtIndex:i] intValue]]).origin.x)*scale + self.imageScrollView.contentOffset.x;
        int y = (([engine puzzlePieceAtIndex:[[randomizedPieces objectAtIndex:i] intValue]]).origin.y)*scale + self.imageScrollView.contentOffset.y;
        [imageView setFrame:CGRectMake(x, y, imageView.frame.size.width, imageView.frame.size.height)];
        [self.pieces addObject:imageView];
    }
    [SoundUtilities playSoundWithName:@"puzzlfy-stickers-puzzleanimation" andFormat:SOUND_TYPE_MP3 isLooping:YES];
    for (int i = 0; i < self.pieces.count; i++)
        [self movePuzzlePiece:[self.pieces objectAtIndex:i] Number:i];
}

-(void) movePuzzlePiece:(AnimatingPuzzlePiece*)puzzlePieceView Number:(int)i
{
    float xDisplacement = 1;
    float yDisplacement = 1;
    
    [UIView animateWithDuration:0.1 delay:0 options: 0 animations:^(void){
        int factor = 0, factor2 = 0;
        //get 1 or -1 values for factors
        while(factor == 0) factor = rand() % (3) -1;
        while(factor2 == 0) factor2 = rand() % (3) -1;
        puzzlePieceView.frame = CGRectMake(puzzlePieceView.frame.origin.x+xDisplacement*factor, puzzlePieceView.frame.origin.y+yDisplacement*factor2, puzzlePieceView.frame.size.width, puzzlePieceView.frame.size.height);
    } completion:^(BOOL finished){
        if(finished)
        {
            if(i == self.pieces.count - 1 && puzzlePieceView.numberOfVibrations == 0){
                [self falloutAnimation];
            }
            else if(puzzlePieceView.numberOfVibrations > 0){
                puzzlePieceView.numberOfVibrations--;
                [self movePuzzlePiece:puzzlePieceView Number:i];
            }
        }
    }];
}

-(void) falloutAnimation
{
    int i=0;
    float duration = PUZZLE_ANIMATION_DURATION;
    CGPoint diff = [[DBManager getInstance] getNumberOfPuzzlePieces];
    
    for (UIImageView *puzzlePieceView in self.pieces) {
        double delay = (PUZZLE_ANIMATION_DURATION + (diff.y * 0.1) - (0.1 * ([self.pieces count]-i) / diff.x));
        
        // Setup the animation
        [UIView animateWithDuration: duration delay:delay options: 0 animations:^(void){
            puzzlePieceView.frame = CGRectMake(puzzlePieceView.frame.origin.x, puzzlePieceView.frame.origin.y+800,puzzlePieceView.frame.size.width, puzzlePieceView.frame.size.height);
        } completion:^(BOOL finished){
            if(finished){
                if(i==self.pieces.count - 1){
                    [SoundUtilities stopSound];
                    [self performSegueWithIdentifier:SEGUE_GOTO_PUZZLE_VIEW sender:self];
                }
            }}];
        
        i++;
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
//{
//    @try {
//        CGPoint velocity = [recognizer velocityInView:self.view];
//        float x = velocity.x;
//        float y = velocity.y;
//        
//        double angle = atan2(y, x) * 180.0f / 3.14159f;
//        NSLog(@"angle: %f",ABS(angle));
//        if ((ABS(angle) > 175 ) || (ABS(angle) >= 0 && ABS(angle) < 20)) {
//            return NO;
//        }
//        else {
//            return YES;
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@", exception.description);
//        return YES;
//    }
//}



- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    if([recognizer.view isKindOfClass:[StickerCell class]])
    {
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        float x = velocity.x;
        float y = velocity.y;
        
        double angle = atan2(y, x) * 180.0f / 3.14159f;
        if(ABS(angle) < 17)
            return NO;
        return ABS(angle) > 190 || ABS(angle) < 170;
    }
    return YES;
}

@end
