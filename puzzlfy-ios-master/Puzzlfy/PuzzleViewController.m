//
//  PuzzleViewController.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#import "JigsawPuzzleEngine.h"
#import "PuzzlePieceCell.h"

#import "PuzzleViewController.h"
#import "UIView+Shadow.h"
#import "DBManager.h"
#import "SoundUtilities.h"
#import "Constants.h"
#import "SegueNames.h"
#import "SettingsViewController.h"
#import "StickersViewController.h"
#import "EventsManager.h"
#import "Notifications.h"

@interface PuzzleViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *puzzleCollection;
@property (strong, nonatomic) IBOutlet UIView *winningView;
@property (strong, nonatomic) IBOutlet UIView *wellDoneView;
@property (strong, nonatomic) IBOutlet UIView *winningImageFrameView;
@property (strong, nonatomic) IBOutlet UIImageView *winningImageView;

@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic) CGPoint *difficultyEasy;
@property (nonatomic) CGPoint *difficultyMedium;
@property (nonatomic) CGPoint *difficultyHard;
@property (nonatomic) BOOL returningFromSettings;
@property (nonatomic) BOOL resetGame;
@property (strong) JigsawPuzzleEngine *engine;
@property (strong) UIImageView *panImageView;
@property (strong, nonatomic) NSMutableArray *randomizedPieces;
@property (strong, nonatomic) PuzzlePiece *panPiece;
@property (strong, nonatomic) UIPanGestureRecognizer *currentPanRecongizer;
@property (strong, nonatomic) UIImageView *currentImageView;
@property (strong, nonatomic) UIAlertView *alertView;
@end

@implementation PuzzleViewController {
    double imageScale;
    CGFloat imageShiftX;
    CGFloat imageShiftY;
    CGFloat snapDistance;
    
    BOOL panSolved;
    BOOL touchInProgress;
    
    
//    NSMutableArray *randomizedPieces;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageView.layer setMasksToBounds:YES];
    
    [self addShadowView];
    
    [self initPuzzlePieces];
    
    [self calculateImageShift];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(winningViewTapped:)];
    [self.winningView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self popStickersView];
    
    [EventsManager resetStartDate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];

}

- (void)recieveApplicationWillEnterBackgroundNotification
{
    if(self.alertView && !self.alertView.hidden)
    {
        [self.alertView dismissWithClickedButtonIndex:1 animated:NO];
    }
    if (self.panImageView && self.currentPanRecongizer) {
        [[(UIImageView *)self.currentPanRecongizer.view.subviews.firstObject superview] setHidden:NO];
        [self.panImageView removeGestureRecognizer:self.currentPanRecongizer];
        [self.panImageView removeFromSuperview];
        self.panImageView = nil;
        self.currentPanRecongizer = nil;
        self.currentImageView = nil;
        touchInProgress = NO;
    }
}

- (void)popStickersView
{
    int index = -1;
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray: nav.viewControllers];
    
    for (int i=0; i < allViewControllers.count; i++) {
        if ([[allViewControllers objectAtIndex:i] isKindOfClass:[StickersViewController class]]) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        [allViewControllers removeObjectAtIndex:index];
        nav.viewControllers = allViewControllers;
    }
}

-(void)winningViewTapped:(UITapGestureRecognizer *) sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)playLoopSound
{
    [SoundUtilities playMainSoundWithName:@"Happy Vibes loop"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.returningFromSettings) {
        if (self.resetGame) {
            [self resetPuzzle];
            self.resetGame = NO;
        }
        else {
            [self reloadPuzzleBoardImage];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)resetPuzzle
{
    [EventsManager resetStartDate];
    [self.imageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

    [self initPuzzlePieces];
    
    [self calculateImageShift];
    [self.puzzleCollection reloadData];
}

- (void)reloadPuzzleBoardImage
{
    self.imageView.image = [[UIImage alloc] initWithCGImage:[self.engine getStrokedImage]];
    touchInProgress = NO;
    if (self.panImageView) {
        [self.panImageView removeFromSuperview];
        self.panImageView = nil;
    }
}

- (void)backButtonPressed:(UIButton *)sender {
    [SoundUtilities playSoundWithName:@"puzzlfy-button-back" andFormat:@"mp3"];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Puzzlfy" message:@"This action will reset your current progress. Do it anyway?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [self.alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) //yes selected
    {
        [self resetNavBarBackBtn];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

- (void)initPuzzlePieces
{
    UIImageView *v = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    v.image = self.image;
    UIGraphicsBeginImageContext(v.frame.size);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = viewImage;
    
    CGPoint diff = [[DBManager getInstance] getNumberOfPuzzlePieces];
    int difficulty = [[[[DBManager getInstance] getUser]difficulty] intValue];
    self.imageView.image = self.image;
    
    self.engine = [[JigsawPuzzleEngine alloc] initWithImage:self.image.CGImage withDifficultyValue:difficulty withX:diff.x andY:diff.y];
    
    if(difficulty == DIFFICULTY_SUPER_EASY)
    {
        self.engine.backGroundAlpha = DIFFICULTY_SUPER_EASY_BACKGROUND_ALPHA;
    }
    self.imageView.image = [[UIImage alloc] initWithCGImage:[self.engine getStrokedImage]];
    
    self.randomizedPieces = [[NSMutableArray alloc] init];
    
    switch ((int)diff.x) {
        default:
        case DIFFICULTY_EASY_X:
            if(difficulty == DIFFICULTY_SUPER_EASY)
                snapDistance = self.engine.pieceWidth / DIFFICULTY_SUPER_EASY_SNAPPING;
            else
                snapDistance = self.engine.pieceWidth / DIFFICULTY_EASY_SNAPPING;
            break;
        case DIFFICULTY_MEDIUM_X:
            snapDistance = self.engine.pieceWidth / DIFFICULTY_MEDIUM_SNAPPING;
            break;
        case DIFFICULTY_HARD_X:
            snapDistance = self.engine.pieceWidth / DIFFICULTY_HARD_SNAPPING;
            break;
    }
    
    for (int i = 0; i < self.engine.tilesX * self.engine.tilesY; i++) {
        [self.randomizedPieces addObject:[NSNumber numberWithInt:i]];
    }
    
    // Shuffle
    for (int i =0; i < self.randomizedPieces.count; i++) {
        NSUInteger elements = self.randomizedPieces.count - i;
        NSUInteger n = arc4random_uniform((unsigned int) elements) + i;
        [self.randomizedPieces exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)addShadowView
{
    UIView *shadowView = [[UIView alloc]initWithFrame:self.puzzleCollection.frame];
    [shadowView setUserInteractionEnabled:NO];
    [shadowView makeInsetShadowWithRadius:15 Alpha:0.3];
    [self.view addSubview:shadowView];
}

- (void)calculateImageShift
{
    CGFloat imageWidth = CGImageGetWidth([self.engine getStrokedImage]);
    CGFloat imageHeight = CGImageGetHeight([self.engine getStrokedImage]);
    
    double xScale = 1;
    double yScale = 1;
    
    if (self.imageView.image.size.width > self.imageView.frame.size.width) {
        xScale = self.imageView.frame.size.width / imageWidth;
    }
    
    if (self.imageView.image.size.height > self.imageView.frame.size.height) {
        yScale = self.imageView.frame.size.height / imageHeight;
    }
    
    imageScale = fmin(xScale, yScale);
    
    if (xScale < yScale) {
        imageShiftX = 0;
        imageShiftY = (self.imageView.frame.size.height - self.image.size.height * imageScale) / 2;
    } else {
        imageShiftX = (self.imageView.frame.size.width - self.image.size.width * imageScale) / 2;
        imageShiftY = 0;
    }
}

-(void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePuzzlePiecePan:(UIPanGestureRecognizer *) recognizer {
    
    UIImageView *imageView = (UIImageView *) recognizer.view.subviews.firstObject;
    CGPoint translation = [recognizer translationInView:self.view];
    if (self.currentImageView != imageView && touchInProgress) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan && !touchInProgress) {
        if (imageView.superview != self.view) {
            self.currentImageView = imageView;
            self.currentPanRecongizer = recognizer;
            [SoundUtilities playSoundWithName:@"puzzlfy-puzzlepiece-drag" andFormat:SOUND_TYPE_MP3];
            self.panPiece = ((PuzzlePieceCell *)imageView.superview.superview.superview).puzzlePiece;

            CGPoint center = [self.view convertPoint:imageView.center fromView:imageView];
            
            imageView.superview.hidden = YES;
            
            self.panImageView = [[UIImageView alloc] initWithImage:imageView.image];
            [self.view addSubview:self.panImageView];
            self.panImageView.center = center;
            
            self.panImageView.transform = CGAffineTransformMakeScale(imageScale, imageScale);
            
            panSolved = NO;
            touchInProgress = YES;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.panImageView.center = CGPointMake(self.panImageView.center.x + translation.x, self.panImageView.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint cp = [self.imageView convertPoint:self.imageView.bounds.origin toView:self.view];
        CGFloat distanceX = fabsf(translation.x + self.panImageView.frame.origin.x - self.panPiece.origin.x * imageScale - cp.x);
        CGFloat distanceY = fabsf(translation.y + self.panImageView.frame.origin.y - self.panPiece.origin.y * imageScale - cp.y);
        
        if ((int)distanceX < snapDistance && (int)distanceY <= snapDistance) {
            [imageView.superview removeGestureRecognizer:recognizer];
            imageView.superview.hidden = NO;
            
            CGRect frame = CGRectMake(self.panPiece.origin.x * imageScale + imageShiftX, self.panPiece.origin.y * imageScale + imageShiftY, self.panPiece.fullSize.width, self.panPiece.fullSize.height);
            
            self.panImageView.frame = frame;
            self.panImageView.image = [[UIImage alloc] initWithCGImage:[self.engine aliasedImageForPieceAtX:self.panPiece.locationX andY:self.panPiece.locationY]];
            [self.panImageView removeFromSuperview];
            [self.imageView addSubview:self.panImageView];
            [self.panPiece finalize];
            
            NSInteger cellIndex = ((PuzzlePieceCell *)imageView.superview.superview.superview).cellIndex;
            [self.randomizedPieces removeObjectAtIndex:cellIndex];
            [self.puzzleCollection reloadData];
            
            self.panImageView = nil;
            self.currentPanRecongizer = nil;
            
            panSolved = YES;
            touchInProgress = NO;
            [SoundUtilities playSoundWithName:@"puzzlfy-puzzlepiece-place" andFormat:SOUND_TYPE_MP3];
            if (self.randomizedPieces.count == 0) {
                [self solved];
                return;
            }
            
        }
        else if (!panSolved) {
            [SoundUtilities playSoundWithName:@"puzzlfy-puzzlepiece-letgo" andFormat:SOUND_TYPE_MP3];
            imageView.superview.hidden = NO;
            [self.panImageView removeFromSuperview];
            self.panImageView = nil;
            touchInProgress = NO;
        }
    }
}

- (void) solved
{
    [SoundUtilities playSoundWithName:@"puzzlfy-puzzlecomplete" andFormat:SOUND_TYPE_MP3];
    CGRect welldoneRect = self.wellDoneView.frame;
    //adjust view before starting animation
    self.winningImageFrameView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.winningImageView.image = self.image;
    [self.wellDoneView setFrame:CGRectMake(welldoneRect.origin.x, welldoneRect.origin.y + welldoneRect.size.height, welldoneRect.size.width, welldoneRect.size.height)];
    [self.view bringSubviewToFront:self.winningView];
    [self.winningView setHidden:NO];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
                         self.wellDoneView.frame = welldoneRect;
                         self.winningImageFrameView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [EventsManager reportEventWithType:EVENT_PUZZLE_SOLVED withParameters:nil];

}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    float x = velocity.x;
    float y = velocity.y;
    
    double angle = atan2(y, x) * 180.0f / 3.14159f;
    return ABS(angle) > 100 || ABS(angle) < 80;

}



#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.randomizedPieces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PuzzlePieceCell *cell = (PuzzlePieceCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"PuzzlePieceCell" forIndexPath:indexPath];
    
    NSInteger imageIndex = indexPath.row;
    PuzzlePiece *piece = [self.engine puzzlePieceAtIndex:[[self.randomizedPieces objectAtIndex:imageIndex] intValue]];
    
    UIView *cellView = (UIView *) [cell viewWithTag:101];
    
    // the image we're going to mask and shadow
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithCGImage:piece.image]];
    
    CGRect mainFrame = cellView.frame;
    mainFrame.size.height = mainFrame.size.height - 20;
    mainFrame.size.width = mainFrame.size.width - 20;
    
    imageView.frame = mainFrame;
    imageView.center = cellView.center;
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // make new layer to contain shadow and masked image
    cellView.layer.shadowColor = [UIColor blackColor].CGColor;
    cellView.layer.shadowRadius = 3.f;
    cellView.layer.shadowOffset = CGSizeMake(5.f, 5.f);
    cellView.layer.shadowOpacity = 1.f;
    
    // add masked image layer into container layer so that it's shadowed
    [cellView.subviews.firstObject removeFromSuperview];
    [cellView addSubview:imageView];
    
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePuzzlePiecePan:)];
    recognizer.delegate = self;
    recognizer.delaysTouchesBegan = YES;
    [cellView addGestureRecognizer:recognizer];
    [cellView setExclusiveTouch:YES];
    cell.puzzlePiece = piece;
    cell.cellIndex = imageIndex;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GOTO_PUZZLE_SETTINGS_VIEW]) {
        ((SettingsViewController*)segue.destinationViewController).isGameInPorgress = YES;
        ((SettingsViewController*)segue.destinationViewController).showDifficultyAlert = YES;
        ((SettingsViewController*)segue.destinationViewController).delegate = self;
        self.returningFromSettings = YES;
    }
}

- (void)didDifficultyChange:(BOOL)diffcultyChanged
{
    self.resetGame = diffcultyChanged;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
}
@end
