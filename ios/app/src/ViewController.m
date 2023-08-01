/*
 * Copyright @ 2017-present 8x8, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@import CoreSpotlight;
@import MobileCoreServices;
@import Intents;  // Needed for NSUserActivity suggestedInvocationPhrase

@import JitsiMeetSDK;

#import "Types.h"
#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //            let userInfo = JitsiMeetUserInfo(displayName: "tac20049", andEmail: nil, andAvatar: nil)
  //            builder.userInfo = userInfo
  
  JitsiMeetUserInfo *userInfo = [[JitsiMeetUserInfo alloc] initWithDisplayName:@"SHAHEEN 2" andEmail:nil andAvatar:nil];
  
  JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
    
    //    [builder setServerURL:[NSURL URLWithString:@"https://sanadpoc.qatar.ncc/avserver/"]];
    
    //Custom Feature Flags
    [builder setFeatureFlag:@"welcomepage.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"add-people.enabled" withBoolean:NO];
////    [builder setFeatureFlag:@"call-integration.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"car-mode.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"close-captions.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"chat.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"filmstrip.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"help.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"invite.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"lobby-mode.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"meeting-name.enabled" withBoolean:NO];
    [builder setFeatureFlag:@"prejoinpage.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"raise-hand.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"reactions.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"security-options.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"server-url-change.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"settings.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"speakerstats.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"kick-out.enabled" withBoolean:NO];
    [builder setFeatureFlag:@"tile-view.enabled" withBoolean:YES];
//    [builder setFeatureFlag:@"toolbox.alwaysVisible" withBoolean:YES];
    [builder setFeatureFlag:@"toolbox.enabled" withBoolean:NO];
//    [builder setFeatureFlag:@"video-share.enabled" withBoolean:NO];
    
    //Custom Properties
//    [builder setAudioOnly:YES];
    [builder setRoom:@"USM-M01"];
    [builder setUserInfo:userInfo];
//    [builder setAudioOnly:YES];
    
    //Custom Configurations
    [builder setConfigOverride:@"disableModeratorIndicator" withBoolean: YES];
    [builder setConfigOverride:@"p2p.enabled" withBoolean: NO];
    [builder setConfigOverride:@"disableThirdPartyRequests" withBoolean: YES];
    [builder setConfigOverride:@"analytics.disabled" withBoolean: YES];
    [builder setConfigOverride:@"disableInviteFunctions" withBoolean:YES];
    
  }];
  
  [[JitsiMeet sharedInstance] setDefaultConferenceOptions:options];
  
  JitsiMeetView *view = (JitsiMeetView *) self.view;
  view.delegate = self;
  
  [view join:nil];
}

// JitsiMeetViewDelegate

- (void)_onJitsiMeetViewDelegateEvent:(NSString *)name
                             withData:(NSDictionary *)data {
  NSLog(
        @"[%s:%d] JitsiMeetViewDelegate %@ %@",
        __FILE__, __LINE__, name, data);
  
#if DEBUG
  NSAssert(
           [NSThread isMainThread],
           @"JitsiMeetViewDelegate %@ method invoked on a non-main thread",
           name);
#endif
}

- (void)conferenceJoined:(NSDictionary *)data {
  [self _onJitsiMeetViewDelegateEvent:@"CONFERENCE_JOINED" withData:data];
  
  // Register a NSUserActivity for this conference so it can be invoked as a
  // Siri shortcut.
  NSUserActivity *userActivity
  = [[NSUserActivity alloc] initWithActivityType:JitsiMeetConferenceActivityType];
  
  NSString *urlStr = data[@"url"];
  NSURL *url = [NSURL URLWithString:urlStr];
  NSString *conference = [url.pathComponents lastObject];
  
  userActivity.title = [NSString stringWithFormat:@"Join %@", conference];
  userActivity.suggestedInvocationPhrase = @"Join my Jitsi meeting";
  userActivity.userInfo = @{@"url": urlStr};
  [userActivity setEligibleForSearch:YES];
  [userActivity setEligibleForPrediction:YES];
  [userActivity setPersistentIdentifier:urlStr];
  
  // Subtitle
  CSSearchableItemAttributeSet *attributes
  = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
  attributes.contentDescription = urlStr;
  userActivity.contentAttributeSet = attributes;
  
  self.userActivity = userActivity;
  [userActivity becomeCurrent];
}

- (void)conferenceTerminated:(NSDictionary *)data {
  [self _onJitsiMeetViewDelegateEvent:@"CONFERENCE_TERMINATED" withData:data];
}

- (void)conferenceWillJoin:(NSDictionary *)data {
  [self _onJitsiMeetViewDelegateEvent:@"CONFERENCE_WILL_JOIN" withData:data];
}

#if 0
- (void)enterPictureInPicture:(NSDictionary *)data {
  [self _onJitsiMeetViewDelegateEvent:@"ENTER_PICTURE_IN_PICTURE" withData:data];
}
#endif

- (void)readyToClose:(NSDictionary *)data {
  [self _onJitsiMeetViewDelegateEvent:@"READY_TO_CLOSE" withData:data];
}

- (void)participantJoined:(NSDictionary *)data {
  NSLog(@"%@%@", @"Participant joined: ", data[@"participantId"]);
}

- (void)participantLeft:(NSDictionary *)data {
  NSLog(@"%@%@", @"Participant left: ", data[@"participantId"]);
}

- (void)audioMutedChanged:(NSDictionary *)data {
  NSLog(@"%@%@", @"Audio muted changed: ", data[@"muted"]);
}

- (void)endpointTextMessageReceived:(NSDictionary *)data {
  NSLog(@"%@%@", @"Endpoint text message received: ", data);
}

- (void)screenShareToggled:(NSDictionary *)data {
  NSLog(@"%@%@", @"Screen share toggled: ", data);
}

- (void)chatMessageReceived:(NSDictionary *)data {
  NSLog(@"%@%@", @"Chat message received: ", data);
}

- (void)chatToggled:(NSDictionary *)data {
  NSLog(@"%@%@", @"Chat toggled: ", data);
}

- (void)videoMutedChanged:(NSDictionary *)data {
  NSLog(@"%@%@", @"Video muted changed: ", data[@"muted"]);
}

#pragma mark - Helpers

- (void)terminate {
  JitsiMeetView *view = (JitsiMeetView *) self.view;
  [view leave];
}

@end
