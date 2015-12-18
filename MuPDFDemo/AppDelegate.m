//
//  AppDelegate.m
//  MuPDFDemo
//
//  Created by WuNan on 15/12/18.
//  Copyright © 2015年 信通惠德. All rights reserved.
//

enum
{
    ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
};
#include "common.h"
#include "mupdf/fitz.h"

#import "AppDelegate.h"

#import "MuDocumentController.h"
@interface AppDelegate () <UINavigationControllerDelegate>
@end

@implementation AppDelegate
{
    UINavigationController *_navigator;
}

- (BOOL) application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
    

    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    _navigator = [[UINavigationController alloc]initWithRootViewController:[UIViewController new]];
    [self.window setRootViewController:_navigator];
    [self.window setBackgroundColor:[UIColor redColor]];
    [self.window makeKeyAndVisible];

    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://j.xtrich.com/userfiles/1/contract/1449796377721.pdf"]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {

        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
        NSString* filePath =[NSString stringWithFormat:@"%@/1.pdf",documentPath];
        NSLog(@"%@",filePath);
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


//读取PDF
-(void)readPDFWithFilePath:(NSString*)filePath {
    //开启pdf队列
    queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
    //初始化pdf context
    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
    //为pdf context注册处理事件
    fz_register_document_handlers(ctx);
    screenScale = [[UIScreen mainScreen] scale];
    
    MuDocRef * doc = [[MuDocRef alloc]initWithFilename:filePath.cString];
    MuDocumentController *document = [[MuDocumentController alloc] initWithFilename: @"1.pdf" path:filePath.cString document: doc];
    [_navigator pushViewController:document animated:YES];
}

@end

