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
@property(nonatomic, strong)NSString* url;
@property(nonatomic)MBProgressHUD* activityHud;
@property(nonatomic)Parser* parser;
@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSURLRequest* d2lLoginRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:D2LLoginUrl]];
	self.d2lWebView.delegate = self;
	self.parser = [[Parser alloc] init];

	[self.d2lWebView loadRequest:d2lLoginRequest];
    self.initialLoad			= YES;
    self.loginButton.enabled	= NO;
	[self.loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	self.webViewLoads			= 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logInButtonPressed {
	if (![self networkConnection]) return;
	NSString* login = @"document.forms.item(0).submit();";
	NSString* usernameSet = [NSString stringWithFormat:@"document.getElementById('j_username').value = \"%@\"", self.userNameTextField.text];
	NSString* passwordSet = [NSString stringWithFormat:@"document.getElementById('j_password').value = \"%@\"", self.passwordTextField.text];
	
	if ([self.userNameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"danger, will robinson" message:@"please enter a username and password before logging in" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	} else {
		[self startActivityHud];
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
	self.url = [NSString stringWithString:webView.request.URL.absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	--self.webViewLoads;
	
	if (self.webViewLoads == 0) {
		if ([self.url isEqualToString:webView.request.URL.absoluteString]) {
			UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"danger, will robinson" message:@"please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
			[error show];
		}
	}
	
	self.url = @"";
    
    if (self.initialLoad == YES && [webView.request.URL.absoluteString isEqualToString:@"https://idp.uwm.edu/idp/Authn/UserPassword"]) {
        self.loginButton.enabled = YES;
		[self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.initialLoad = NO;
    }
	
	if ([webView.request.URL.absoluteString isEqualToString:@"https://uwm.courses.wisconsin.edu/d2l/m/home"]) {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];
	}
	[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController* dest = segue.destinationViewController;
    ClassTableViewController* destination = [dest.childViewControllers objectAtIndex:0];
	
	destination.courses = [self.parser getCoursesFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
	[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
	destination.d2lWebView = self.d2lWebView;
}

- (void)startActivityHud {
	self.activityHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.activityHud = MBProgressHUDModeIndeterminate;
	self.activityHud.labelText = @"loading";
}

- (BOOL)networkConnection {
	Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"danger, will robinson" message:@"You need an active internet connection to use this app" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
		return false;
	} else {
		return true;
	}
}

@end
