//
//  ViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "LogInViewController.h"
#import "ClassTableViewController.h"
#import "Parser.h"

@interface LogInViewController ()
@property(nonatomic)BOOL initialLoad;
@property(nonatomic)int webViewLoads;
@property(nonatomic, weak)NSString* url;
@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSURLRequest* d2lLoginRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:D2LLoginUrl]];
	self.d2lWebView.delegate = self;

	[self.d2lWebView loadRequest:d2lLoginRequest];
	
	/* REMOVE THIS BEFORE SUBMITTING */
	self.userNameTextField.text = @"jjpease";
	self.passwordTextField.text = @"";
    self.initialLoad = YES;
    self.loginButton.enabled = NO;
    self.loginButton.tintColor = [UIColor grayColor];
	self.webViewLoads = 0;
	self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInButtonPressed {
	NSString* login = @"document.forms.item(0).submit();";
	NSString* usernameSet = [NSString stringWithFormat:@"document.getElementById('j_username').value = \"%@\"", self.userNameTextField.text];
	NSString* passwordSet = [NSString stringWithFormat:@"document.getElementById('j_password').value = \"%@\"", self.passwordTextField.text];
	
	if ([self.userNameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"error will robinson" message:@"please enter a username and password before logging in" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	} else {
		[self.activityIndicator startAnimating];
		self.activityIndicator.hidden = NO;
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:usernameSet];
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:passwordSet];
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:login];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.userNameTextField) {
		[textField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	} else if (textField == self.passwordTextField) {
		NSLog(@"done");
		[textField resignFirstResponder];
		[self logInButtonPressed];
	}
	return NO;
}

- (IBAction)screenTapped {
	[self.view endEditing:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	++self.webViewLoads;
	self.url = webView.request.URL.absoluteString;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	--self.webViewLoads;
	
	if (self.webViewLoads == 0) {
		if ([self.url isEqualToString:webView.request.URL.absoluteString]) {
//			UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"you done messed up bro" message:@"please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//			[error show];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" " message:@" " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
			progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
			[alert addSubview:progress];
			[progress startAnimating];
			[alert show];
//			self.activityIndicator.hidden = YES;
//			[self.activityIndicator stopAnimating];
		}
	}
	
	self.url = @"";
	NSString* html = [NSString stringWithContentsOfURL:webView.request.URL encoding:NSASCIIStringEncoding error:nil];
    
    if (self.initialLoad == YES && [webView.request.URL.absoluteString isEqualToString:@"https://idp.uwm.edu/idp/Authn/UserPassword"]) {
        self.loginButton.enabled = YES;
        self.loginButton.tintColor = [UIColor blackColor];
        self.initialLoad = NO;
    }
    
	if ([webView.request.URL.absoluteString isEqualToString:@"https://uwm.courses.wisconsin.edu/d2l/m/home"]) {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];
	} else if ([html rangeOfString:@"Bad username or password"].location != NSNotFound) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"you done messed up" message:@"please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController* dest = segue.destinationViewController;
    ClassTableViewController* destination = [dest.childViewControllers objectAtIndex:0];
	Parser* p = [[Parser alloc] init];
	destination.courses = [p getCoursesFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
	self.activityIndicator.hidden = YES;
	[self.activityIndicator stopAnimating];
	destination.d2lWebView = self.d2lWebView;
}

@end
