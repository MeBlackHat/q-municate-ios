//
//  QMConstants.h
//  Q-municate
//
//  Created by Injoit on 3/19/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#ifndef QMConstants_h
#define QMConstants_h

#import <CoreLocation/CLLocation.h>

#define qm_keypath(__CLASS__, __KEY__)                      \
({                                                          \
    while (1) {                                             \
        break;                                              \
        [__CLASS__ class];                                  \
        __CLASS__ * instance = nil;                         \
        [instance __KEY__];                                 \
    }                                                       \
    NSStringFromSelector(@selector(__KEY__));               \
})

// storyboards
static NSString *const kQMMainStoryboard = @"Main";
static NSString *const kQMChatStoryboard = @"Chat";
static NSString *const kQMSettingsStoryboard = @"Settings";
static NSString *const kQMShareStoryboard = @"ShareInterface";

static NSString *const kQMPushNotificationDialogIDKey = @"dialog_id";
static NSString *const kQMPushNotificationUserIDKey = @"user_id";

static NSString *const kQMDialogsUpdateNotificationMessage = @"Notification message";
static NSString *const kQMContactRequestNotificationMessage = @"Contact request";
static NSString *const kQMLocationNotificationMessage = @"Location";
static NSString *const kQMCallNotificationMessage = @"Call notification";

static const CGFloat kQMBaseAnimationDuration = 0.2f;
static const CGFloat kQMSlashAnimationDuration = 0.1f;
static const CGFloat kQMDefaultNotificationDismissTime = 2.0f;
static const CGFloat kQMShadowViewHeight = 0.5f;

static const CLLocationDegrees MKCoordinateSpanDefaultValue = 250;

//Notifications

//DarwinNotificationCenter

//Extension notifications
//Posted immediately after dialogs' updates in the Share Extension
static NSNotificationName const kQMDidUpdateDialogsNotification = @"com.quickblox.shareextension.didUpdateDialogs.notification";
//Posted immediately after dialog's updates in the Share Extension.
//Full name of the notification should be 'kQMDidUpdateDialogNotificationPrefix:dialogID'
static NSNotificationName const kQMDidUpdateDialogNotificationPrefix = @"com.quickblox.shareextension.didUpdateDialog.notification";

#endif /* QMConstants_h */
