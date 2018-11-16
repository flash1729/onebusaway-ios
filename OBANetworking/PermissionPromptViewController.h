//
//  PermissionPromptViewController.h
//  OBANetworking
//
//  Created by Aaron Brethorst on 11/15/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

@import UIKit;
@import OBALocationKit;

NS_ASSUME_NONNULL_BEGIN

@interface PermissionPromptViewController : UIViewController
- (instancetype)initWithLocationService:(OBALocationService*)locationService;
@end

NS_ASSUME_NONNULL_END
