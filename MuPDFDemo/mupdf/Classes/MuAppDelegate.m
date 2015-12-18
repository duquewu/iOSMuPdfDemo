//#include "common.h"
//#include "mupdf/fitz.h"
//
//#import "MuAppDelegate.h"
//
//#ifdef CRASHLYTICS_ENABLE
//#import <Crashlytics/Crashlytics.h>
//#endif
//
//@interface MuAppDelegate () <UINavigationControllerDelegate>
//@end
//
//@implementation MuAppDelegate
//{
//	UIWindow *window;
//	UINavigationController *navigator;
//	MuLibraryController *library;
//	BOOL _isInBackground;
//}
//
//- (BOOL) application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
//{
//	NSString *filename;
//
//	queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
//
//	ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
//	fz_register_document_handlers(ctx);
//
//#ifdef CRASHLYTICS_ENABLE
//	NSLog(@"Starting Crashlytics");
//	[Crashlytics startWithAPIKey:CRASHLYTICS_API_KEY];
//#endif
//
//	screenScale = [[UIScreen mainScreen] scale];
//
//	library = [[MuLibraryController alloc] initWithStyle: UITableViewStylePlain];
//
//	navigator = [[UINavigationController alloc] initWithRootViewController: library];
//	[[navigator navigationBar] setTranslucent: YES];
//	[[navigator toolbar] setTranslucent: YES];
//	[navigator setDelegate: self];
//
//	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
//	[window setBackgroundColor: [UIColor grayColor]];
//	[window setRootViewController: navigator];
//	[window makeKeyAndVisible];
//
//	filename = [[NSUserDefaults standardUserDefaults] objectForKey: @"OpenDocumentKey"];
//	if (filename)
//		[library openDocument: filename];
//
//	filename = [launchOptions objectForKey: UIApplicationLaunchOptionsURLKey];
//	NSLog(@"urlkey = %@\n", filename);
//
//	return YES;
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//	NSLog(@"openURL: %@\n", url);
//	if ([url isFileURL]) {
//		NSString *path = [url path];
//		NSString *dir = [NSString stringWithFormat: @"%@/Documents/", NSHomeDirectory()];
//		path = [path stringByReplacingOccurrencesOfString:@"/private" withString:@""];
//		path = [path stringByReplacingOccurrencesOfString:dir withString:@""];
//		NSLog(@"file relative path: %@\n", path);
//		[library openDocument:path];
//		return YES;
//	}
//	return NO;
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//	printf("applicationDidEnterBackground!\n");
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	_isInBackground = YES;
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//	printf("applicationWillEnterForeground!\n");
//	_isInBackground = NO;
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//	printf("applicationDidBecomeActive!\n");
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//	printf("applicationWillTerminate!\n");
//	[[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//	NSLog(@"applicationDidReceiveMemoryWarning");
//	int success = fz_shrink_store(ctx, _isInBackground ? 0 : 50);
//	NSLog(@"fz_shrink_store: success = %d", success);
//}
//
//- (void) dealloc
//{
//	dispatch_release(queue);
//	[library release];
//	[navigator release];
//	[window release];
//	[super dealloc];
//}
//
//@end

#include "common.h"
#include "mupdf/fitz.h"

#import "MuAppDelegate.h"

#import "MuDocumentController.h"
@interface MuAppDelegate () <UINavigationControllerDelegate>
@end

@implementation MuAppDelegate
{
	UIWindow *window;
	UINavigationController *navigator;
}

- (BOOL) application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
	
	screenScale = [[UIScreen mainScreen] scale];
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	navigator = [[UINavigationController alloc]initWithRootViewController:[UIViewController new]];
	[window setRootViewController:navigator];
	[window makeKeyAndVisible];
	
	
	NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://j.xtrich.com/userfiles/1/contract/1449796377721.pdf"]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
		
		NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
		NSString* filePath =[NSString stringWithFormat:@"%@/1.pdf",documentPath];
		[data writeToFile:filePath atomically:YES];
		[self readPDFWithFilePath:filePath];
		
	}];
	return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"applicationDidReceiveMemoryWarning");
	int success = fz_shrink_store(ctx, /* DISABLES CODE */ (YES) ? 0 : 50);
	NSLog(@"fz_shrink_store: success = %d", success);
}

- (void) dealloc
{
	//关闭PDF界面时需要释放 queue队列
	dispatch_release(queue);
	[window release];
	[super dealloc];
}

//读取PDF
-(void)readPDFWithFilePath:(NSString*)filePath {
	//开启pdf队列
	queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
	//初始化pdf context
	ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
	//为pdf context注册处理事件
	fz_register_document_handlers(ctx);
	
	MuDocRef * doc = [[MuDocRef alloc]initWithFilename:filePath.cString];
	MuDocumentController *document = [[MuDocumentController alloc] initWithFilename: @"1.pdf" path:filePath.cString document: doc];
	[navigator pushViewController:document animated:YES];
}

@end

