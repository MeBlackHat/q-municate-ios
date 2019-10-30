//
//  QMContactsSearchDataProvider.m
//  Q-municate
//
//  Created by Injoit on 3/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMContactsSearchDataProvider.h"
#import "QMSearchProtocols.h"
#import "QMCore.h"

@interface QMContactsSearchDataProvider ()

<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (copy, nonatomic) NSString *cachedSearchText;

@end

@implementation QMContactsSearchDataProvider

//MARK: - Construction

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [QMCore.instance.contactListService addDelegate:self];
        [QMCore.instance.usersService addDelegate:self];
        _friends = [QMCore.instance.contactManager friends];
    }
    
    return self;
}

//MARK: - Methods

- (void)performSearch:(NSString *)searchText {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        self.cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [self.dataSource replaceItems:self.friends];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
        NSArray *friendsSearchResult = [self.friends filteredArrayUsingPredicate:usersSearchPredicate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.dataSource replaceItems:friendsSearchResult];
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
}

//MARK: - Helpers

- (void)updateData {
    
    self.friends = [QMCore.instance.contactManager friends];
    [self performSearch:self.cachedSearchText];
    
    [self.delegate searchDataProvider:self didUpdateData:self.friends];
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    [self updateData];
}

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    [self updateData];
}

//MARK: - QMContactListDelegate

- (void)contactListServiceDidLoadCache {
    
    [self updateData];
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [self updateData];
}

@end
