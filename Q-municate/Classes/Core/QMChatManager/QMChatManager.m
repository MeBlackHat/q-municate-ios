//
//  QMChatManager.m
//  Q-municate
//
//  Created by Injoit on 4/8/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMChatManager.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMMessagesHelper.h"

@interface QMChatManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMChatManager

@dynamic serviceManager;

//MARK: - Chat Connection

- (BFTask *)disconnectFromChat {
    
    return [[self.serviceManager.chatService disconnect] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull  task) {
        
        if (self.serviceManager.currentProfile.userData != nil) {
            
            self.serviceManager.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [self.serviceManager.currentProfile synchronize];
        }
        
        return nil;
    }];
}

- (BFTask *)disconnectFromChatIfNeeded {
    
    BOOL chatNeedDisconnect =  [[QBChat instance] isConnected] || [[QBChat instance] isConnecting];
    if ((UIApplication.sharedApplication.applicationState == UIApplicationStateBackground ||
         UIApplication.sharedApplication.applicationState == UIApplicationStateInactive) &&
        !self.serviceManager.callManager.hasActiveCall && chatNeedDisconnect) {
        
        return [self disconnectFromChat];
    }
    
    return nil;
}

//MARK: - Notifications

- (BFTask *)addUsers:(NSArray *)users toGroupChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    NSArray *userIDs = [self.serviceManager.contactManager idsOfUsers:users];
    
    return [[self.serviceManager.chatService
             joinOccupantsWithIDs:userIDs
             toChatDialog:chatDialog] continueWithSuccessBlock:^id(BFTask<QBChatDialog *> *task)
            {
                QBChatDialog *updatedDialog = task.result;
                [self.serviceManager.chatService
                 sendSystemMessageAboutAddingToDialog:updatedDialog
                 toUsersIDs:userIDs
                 withText:kQMDialogsUpdateNotificationMessage];
                
                [self.serviceManager.chatService
                 sendNotificationMessageAboutAddingOccupants:userIDs
                 toDialog:updatedDialog
                 withNotificationText:kQMDialogsUpdateNotificationMessage];
                
                return nil;
            }];
}

- (BFTask *)changeAvatar:(UIImage *)avatar forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    
    return [[[QMContent uploadPNGImage:avatar progress:nil] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        
        NSString *url = task.result.isPublic ? [task.result publicUrl] : [task.result privateUrl];
        return [self.serviceManager.chatService changeDialogAvatar:url forChatDialog:chatDialog];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogPhoto:task.result withNotificationText:kQMDialogsUpdateNotificationMessage];
        return nil;
    }];
}

- (BFTask *)changeName:(NSString *)name forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    
    return [[self.serviceManager.chatService changeDialogName:name forChatDialog:chatDialog]
            continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
                
                return [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogName:task.result
                                                                                  withNotificationText:kQMDialogsUpdateNotificationMessage];
            }];
}

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    return [[self.serviceManager.chatService
             sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage]
            continueWithBlock:^id(BFTask * task) {
                return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
            }];
}

- (BFTask *)sendBackgroundMessageWithText:(NSString *)text toDialogWithID:(NSString *)chatDialogID {
    
    NSUInteger currentUserID = QMCore.instance.currentProfile.userData.ID;
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:text
                                                          senderID:currentUserID
                                                      chatDialogID:chatDialogID
                                                          dateSent:[NSDate date]];
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest sendMessage:message successBlock:^(QBResponse *  response, QBChatMessage *createdMessage) {
        
        [source setResult:createdMessage];
        
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

@end
