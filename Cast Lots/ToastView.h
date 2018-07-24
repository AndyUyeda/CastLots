//
//  ToastView.h
//  A2:42
//
//  Created by Andy Uyeda on 5/3/16.
//  Copyright © 2016 Andy Uyeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end