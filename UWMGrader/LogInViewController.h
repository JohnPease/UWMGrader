//
//  ViewController.h
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define D2LLoginUrl @"https://uwm.courses.wisconsin.edu/Shibboleth.sso/Login?target=https://uwm.courses.wisconsin.edu/d2l/shibbolethSSO/deepLinkLogin.d2l"

@interface LogInViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>

@property(nonatomic, weak)IBOutlet UITextField* userNameTextField;
@property(nonatomic, weak)IBOutlet UITextField* passwordTextField;
@property(nonatomic, weak)IBOutlet UIImageView* d2lImageView;
@property(nonatomic, weak)IBOutlet UIWebView* d2lWebView;
@property(nonatomic, weak)IBOutlet UIButton* loginButton;
@property(nonatomic)MBProgressHUD* activityHud;

- (IBAction)logInButtonPressed;
- (IBAction)screenTapped;

@end
