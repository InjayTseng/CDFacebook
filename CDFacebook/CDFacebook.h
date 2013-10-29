//
//  CDFacebook.h
//  CDFacebook
//
//  Created by David Tseng on 10/21/13.
//  Copyright (c) 2013 David Tseng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#define isFacebookLogin ([CDFacebook isCDFacebookLogin])
typedef void(^SuccessBlock)(void);
typedef void(^SuccessSessionBlock)(FBSession* session);
typedef void(^SuccessFBGrapgUserBlock)(NSDictionary<FBGraphUser> *user);
typedef void(^FailureErrorBlock)(NSError* err);


@interface CDFacebook : NSObject

+(BOOL)isCDFacebookLogin;
+(void)openSessionWithSuccess:(SuccessSessionBlock)success failure:(FailureErrorBlock)failure;
+(void)closeSession;
+(void)requestMyInfoWithSuccess:(SuccessFBGrapgUserBlock)success withFaulure:(FailureErrorBlock)failure;

@end

@interface UserManager : NSObject

@property (strong, nonatomic) FBSession *currentSession;
@property (strong, nonatomic) FBRequest *pendingRequest;


+ (instancetype)sharedManager;
- (void)updateUser:(NSDictionary<FBGraphUser> *)user;
- (void)switchToNoActiveUser:(SuccessBlock)success;
@end