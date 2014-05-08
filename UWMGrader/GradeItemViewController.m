//
//  GradeItemViewController.m
//  UWMGrader
//
//  Created by John Pease on 4/7/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "GradeItemViewController.h"
#import "Grade.h"

@interface GradeItemViewController ()

@end

@implementation GradeItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.gradeValue.text = [NSString stringWithFormat:@"score: %@", self.grade.score];
	self.weightAchieved.text = [NSString stringWithFormat:@"weight achieved: %@", self.grade.weightAchieved];
	self.feedbackFromGrader.text = self.grade.feedback;
	
}

- (void)viewWillAppear:(BOOL)animated {
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
