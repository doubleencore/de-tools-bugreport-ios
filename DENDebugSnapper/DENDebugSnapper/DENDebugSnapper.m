//
//  DENDebugSnapper.m
//  DENDebugSnapper
//
//  Created by Brad Dillon on 4/8/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "DENDebugSnapper.h"


@interface DENDebugSnapper () <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailComposer;

@end


@implementation DENDebugSnapper

- (void)dealloc
{
    BOOL canScreenshot = &UIApplicationUserDidTakeScreenshotNotification != NULL;
    if (canScreenshot) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    }
}


- (void)setShouldSnapOnUserScreenshot:(BOOL)shouldSnapOnUserScreenshot
{
    BOOL canScreenshot = &UIApplicationUserDidTakeScreenshotNotification != NULL;
    if (!canScreenshot) return;
    
    if (_shouldSnapOnUserScreenshot != shouldSnapOnUserScreenshot) {
        _shouldSnapOnUserScreenshot = shouldSnapOnUserScreenshot;

        if (_shouldSnapOnUserScreenshot) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
        }
    }
}


- (void)snap
{
    if (![MFMailComposeViewController canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:@"Mail Failed" message:@"Mail not configured. Could not create snapshot." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    NSDate *date = [NSDate date];
    
    NSData *snapData = nil;
    if (self.captureBlock) {
        snapData = self.captureBlock();
    }
    
    UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.window drawViewHierarchyInRect:self.window.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    UIGraphicsEndImageContext();
    
    MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
    mailComposer.mailComposeDelegate = self;
    
    [mailComposer setTitle:[NSString stringWithFormat:@"Snapshot %@", date]];
    [mailComposer addAttachmentData:imageData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"Screenshot-%@.png", date]];
    
    if (snapData) {
        [mailComposer addAttachmentData:snapData mimeType:@"application/zip" fileName:[NSString stringWithFormat:@"Snapshot-%@.zip", date]];
    }
    
    [self.window addSubview:mailComposer.view];
    self.mailComposer = mailComposer;
}


- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (_gestureRecognizer != gestureRecognizer) {
        _gestureRecognizer = gestureRecognizer;
        
        [_gestureRecognizer addTarget:self action:@selector(gestureRecognized:)];
    }
}


#pragma mark -


- (void)userDidTakeScreenshot
{
    [[[UIAlertView alloc] initWithTitle:@"Screenshot Taken" message:@"Would you like to attach this screenshot and snapshot data to an email?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self snap];
    }
}


#pragma mark -


- (void)gestureRecognized:(UIGestureRecognizer *)recognizer
{
    [self snap];
}


#pragma mark -


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.mailComposer.view removeFromSuperview];
    self.mailComposer = nil;
}

@end
