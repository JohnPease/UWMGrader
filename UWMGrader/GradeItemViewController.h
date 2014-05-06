//
//  GradeItemViewController.h
//  UWMGrader
//
//  Created by John Pease on 4/7/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradeItemViewController : UIViewController

@property(nonatomic, weak)IBOutlet UILabel* gradeValue;
@property(nonatomic, weak)IBOutlet UILabel* weightAchieved;
@property(nonatomic, weak)IBOutlet UITextView* feedbackFromGrader;
@property(nonatomic, weak)IBOutlet UIWebView* gradeStatisticsWebView;

@end
