//
//  UDMenuLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "RRMenuMultiplayerLayer.h"


#if __IPHONE_OS_VERSION_MAX_ALLOWED
    #define RRMenuLayerGKDelegates GKMatchmakerViewControllerDelegate, GKPeerPickerControllerDelegate
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    #define RRMenuLayerGKDelegates GKMatchmakerViewControllerDelegate
#endif


@interface RRMenuLayer : CCLayer <RRMenuMultiplayerLayerDelegate, RRMenuLayerGKDelegates> {
    GKMatchmakerViewController  *_matchmakerViewController;
#ifdef __CC_PLATFORM_IOS
    GKPeerPickerController      *_peerPickerController;
#elif defined(__CC_PLATFORM_MAC)
    GKDialogController          *_dialogController;
#endif
}

@end
