//
//  ViewController.m
//  CDFacebook
//
//  Created by David Tseng on 10/21/13.
//  Copyright (c) 2013 David Tseng. All rights reserved.
//

#import "ViewController.h"
#import "CDFacebook.h"
#import <FacebookSDK/FacebookSDK.h>
@interface ViewController () <FBFriendPickerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet FBProfilePictureView *vwProfile;
@property (readwrite, nonatomic, copy) NSString *fbidSelection;
@property (readwrite, nonatomic, retain) FBFrictionlessRecipientCache *friendCache;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    if (isFacebookLogin) {
        //[self refreshView];
    } else {
        [self doSomethingNotLogin];
//        self.inviteButton.enabled = NO;
//        self.friendCache = nil;
        
        // display the message that we have
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In with Facebook"
                                                        message:@"When you Log In with Facebook, you can view "
                              @"friends' activity within Rock Paper Scissors, and "
                              @"invite friends to play.\n\n"
                              @"What would you like to do?"
                                                       delegate:self
                                              cancelButtonTitle:@"Do Nothing"
                                              otherButtonTitles:@"Log In", nil];
        [alert show];
    }
}

- (IBAction)btnLoginClicked:(id)sender {
    
    isFacebookLogin;
    
}


- (IBAction)btnFBLoginClicked:(id)sender {
    
    [CDFacebook openSessionWithSuccess:^(FBSession *session) {
    

    } failure:^(NSError *err) {
       
    }];
}

- (IBAction)btnLogout:(id)sender {
    
    [CDFacebook closeSession];
}


- (IBAction)btnRequestInfoClicked:(id)sender {
    
    self.vwProfile.hidden = YES;
    __weak id weakSelf =  self;
    [CDFacebook requestMyInfoWithSuccess:^(NSDictionary<FBGraphUser> *user) {
    
        NSLog(@"User %@",user.first_name);
        [[weakSelf vwProfile] setPictureCropping:FBProfilePictureCroppingSquare];
        [[weakSelf vwProfile] setProfileID:user.id];
        [weakSelf vwProfile].hidden = NO;
        [weakSelf setVwProfile:[[FBProfilePictureView alloc]initWithProfileID:user.id pictureCropping:FBProfilePictureCroppingSquare]];
        
    } withFaulure:^(NSError *err) {
        
    }];
}


- (void)refreshView {
    
    //[self loadData];
    
    // we use frictionless requests, so let's get a cache and request the
    // current list of frictionless friends before enabling the invite button
    if (!self.friendCache) {
        self.friendCache = [[FBFrictionlessRecipientCache alloc] init];
        [self.friendCache prefetchAndCacheForSession:nil
                                   completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                       
                                       //self.inviteButton.enabled = YES;
                                   }];
    } else  {
        // if we already have a primed cache, let's just run with it
        //self.inviteButton.enabled = YES;
    }
}

-(void)doSomethingNotLogin{

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // do nothing
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 1: { // log in
            // we will update the view *once* upon successful login
            __block ViewController *me = self;
            [FBSession openActiveSessionWithReadPermissions:nil
                                               allowLoginUI:YES
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                              if (me) {
                                                  if (session.isOpen) {
                                                      //[me refreshView];
                                                  } else {
                                                      [me.navigationController popToRootViewControllerAnimated:YES];
                                                  }
                                                  me = nil;
                                              }
                                          }];
            
            break;
        }
    }
}

- (IBAction)clickInviteFriends:(id)sender {
    // if there is a selected user, seed the dialog with that user
    NSDictionary *parameters = self.fbidSelection ? @{@"to":self.fbidSelection} : nil;
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Please come play RPS with me!"
                                                    title:@"Invite a Friend"
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (result == FBWebDialogResultDialogCompleted) {
                                                          NSLog(@"Web dialog complete: %@", resultURL);
                                                      } else {
                                                          NSLog(@"Web dialog not complete, error: %@", error.description);
                                                      }
                                                  }
                                              friendCache:self.friendCache];
}

- (IBAction)clickSendRequest:(id)sender {
    // if there is a selected user, seed the dialog with that user
    NSDictionary *parameters = self.fbidSelection ? @{@"to":self.fbidSelection} : nil;
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Please come play RPS with me!"
                                                    title:@"Invite a Friend"
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (result == FBWebDialogResultDialogCompleted) {
                                                          NSLog(@"Web dialog complete: %@", resultURL);
                                                      } else {
                                                          NSLog(@"Web dialog not complete, error: %@", error.description);
                                                      }
                                                  }
                                              friendCache:self.friendCache];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
