//
//  CMChatRoomViewController.h
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/9/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "JSMessagesViewController.h"
#import "JSQMessages.h"

@interface CMChatRoomViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property (strong, nonatomic) PFObject *chatRoom;

@end
