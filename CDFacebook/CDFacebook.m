//
//  CDFacebook.m
//  CDFacebook
//
//  Created by David Tseng on 10/21/13.
//  Copyright (c) 2013 David Tseng. All rights reserved.
//

#import "CDFacebook.h"

@implementation CDFacebook

+(BOOL)isCDFacebookLogin{
    if ([UserManager sharedManager].currentSession.isOpen) {
        NSLog(@"Login Status:YES.");
        return YES;
    } else {
        NSLog(@"Login Status:NO.");
        return NO;
    }
}

+(void)openSessionWithSuccess:(SuccessSessionBlock)success failure:(FailureErrorBlock)failure{

    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if (session.isOpen) {
                                          [[UserManager sharedManager] setCurrentSession:session];
                                          NSLog(@"Login Success.");
                                          success(session);
                                      } else {
                                          NSLog(@"Login Failed.\n%@",error.description);
                                          failure(error);
                                      }
                                  }];
}

+(void)closeSession{

    [[UserManager sharedManager] switchToNoActiveUser:^{
        NSLog(@"Clear.");
    }];
}


+(void)requestMyInfoWithSuccess:(SuccessFBGrapgUserBlock)success withFaulure:(FailureErrorBlock)failure{
    
    FBRequest *me = [[FBRequest alloc] initWithSession:[UserManager sharedManager].currentSession
                                             graphPath:@"me"];
    [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                     // we expect a user as a result, and so are using FBGraphUser protocol
                                     // as our result type; in order to allow us to access first_name and
                                     // birthday with property syntax
                                     NSDictionary<FBGraphUser> *user,
                                     NSError *error) {
        if (me!=[UserManager sharedManager].pendingRequest) {
            return;
        }
        [[UserManager sharedManager] setPendingRequest:nil];
        if (error) {
            failure(error);
            NSLog(@"Couldn't get info : %@", error.localizedDescription);
            return;
        }else{
            NSLog(@"Got %@",user.first_name);
            success(user);
        }
    }];
    [UserManager sharedManager].pendingRequest = me;
     
}


@end




@implementation UserManager

@synthesize currentSession = _currentSession;
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;

+ (instancetype)sharedManager	{
	DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
		return [[self alloc] init];
	});
}

- (id)init	{
    self = [super init];
    if (self) {

    }
    return self;
}

- (FBSessionTokenCachingStrategy*)createCachingStrategy{
    // FBSample logic
    // Token caching strategies are an advanced feature of the SDK; by creating one and passing it to
    // FBSession at instantiation time, the SUUserManager class takes control of the token caching
    // behavior of session instances; this is useful to do in this application, because there may be up
    // to four users whose tokens are remembered by the application at one time; and so the names in
    // NSUserDefaults used to store these values need to reflect the user whose data is being cached
    // Note: an application with more advanced token caching needs (beyond NSUserDefaults) can derive
    // from FBSessionTokenCachingStrategy, and implement any store for the token cache that it needs,
    // including storing and retrieving tokens on an application-specific server, filesystem, etc.
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc]
                                                           initWithUserDefaultTokenInformationKeyName:[NSString stringWithFormat:@"SUUserTokenInfo"]];
    return tokenCachingStrategy;
}

- (FBSession*)createSession{
    // FBSample logic
    // Getting the right strategy instance for the right slot matters for this application
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [self createCachingStrategy];
    
    // create a session object, with defaults accross the board, except that we provide a custom
    // instance of FBSessionTokenCachingStrategy
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:@[@"basic_info",@"user_birthday"]
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:tokenCachingStrategy];
    return session;
}

- (FBSession *)switchToUserWithNotify:(SuccessBlock)success{

    NSLog(@"UserManager switching.");

    FBSession *session = [self createSession];
    _currentSession = session;
    success();
    
    return session;
}

- (void)switchToNoActiveUser:(SuccessBlock)success{

    NSLog(@"UserManager switching to no active");
    _currentSession = nil;
    success();
}


static NSString *const SUUserIDKeyFormat = @"SUUserID";
static NSString *const SUUserNameKeyFormat = @"SUUserName";

- (void)updateUser:(NSDictionary<FBGraphUser> *)user{

    NSString *idKey = [NSString stringWithFormat:SUUserIDKeyFormat];
    NSString *nameKey = [NSString stringWithFormat:SUUserNameKeyFormat];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (user != nil ) {
        NSLog(@"SUUserManager updating: fbid = %@, name = %@", user.id, user.name);
        [defaults setObject:user.id forKey:idKey];
        [defaults setObject:user.name forKey:nameKey];
        
    } else {
        NSLog(@"SUUserManager clearing");
        
        self.currentSession = nil;
        // Can't be current user anymore
        // FBSample logic
        // Also need to tell the token cache to forget the tokens for this user
        FBSessionTokenCachingStrategy *tokenCachingStrategy = [self createCachingStrategy];
        [tokenCachingStrategy clearToken];
        [defaults removeObjectForKey:idKey];
        [defaults removeObjectForKey:nameKey];
    }
    [defaults synchronize];
}


- (NSString*)getUserID{

    NSString *key = [NSString stringWithFormat:SUUserIDKeyFormat];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Don't assume we have a full FBGraphObject -- builds compiled with earlier versions of SDK
    // may have saved only a plain NSDictionary.
    return [defaults objectForKey:key];
}
- (NSString*)getUserName{
    
    NSString *key = [NSString stringWithFormat:SUUserNameKeyFormat];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Don't assume we have a full FBGraphObject -- builds compiled with earlier versions of SDK
    // may have saved only a plain NSDictionary.
    return [defaults objectForKey:key];
    
}


@end
