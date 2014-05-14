//
//  ClassTableViewController.h
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHud/MBProgressHUD.h>

@class User;
@class Course;

@interface ClassTableViewController : UITableViewController <UIWebViewDelegate>

@property(nonatomic,strong)User* user;
@property(nonatomic,strong)NSArray* courses;
@property(nonatomic,strong)UIWebView* d2lWebView;

- (IBAction)logoutButtonPressed;

@end
