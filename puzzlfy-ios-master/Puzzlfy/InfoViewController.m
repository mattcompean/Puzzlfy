//
//  InfoViewController.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/27/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "InfoViewController.h"
#import "NavigationBarView.h"
#import "Constants.h"
#import "ViewUtilities.h"
#import "SoundUtilities.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) adjustNavigationBarButtonsVisibility:(NavigationBarView*) bar
{
    [bar.menuButton setHidden:YES];
}

- (IBAction)openWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:R60_URL]];
}

- (IBAction)sendFeedback:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    [self sendFeedbackEmail];
}

- (IBAction)caminandesClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CAMINANDES_URL]];
}

- (IBAction)kidssafeClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:KIDSSAFE_URL]];
}

- (void)sendFeedbackEmail
{
    if(![MFMailComposeViewController canSendMail])
    {
        [ViewUtilities presentError:@"Device is not configured to send mail."];
        return;
    }
    MFMailComposeViewController *mc = [MFMailComposeViewController new];
    [mc setSubject:EMAIL_SUBJECT];
    [mc setToRecipients:[NSArray arrayWithObjects:FEEDBACK_EMAIL, nil]];
    mc.mailComposeDelegate = self;
    [self presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
