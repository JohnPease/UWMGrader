//
//  GradeTableViewController.h
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Course;

@interface GradeTableViewController : UITableViewController

@property(nonatomic,strong)Course* course;
@property(nonatomic,strong)UIWebView* d2lWebView;
@property(nonatomic,strong)NSArray* gradeSections;

@end
