// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import <Cordova/CDVCommandDelegate.h>
#import "AppCenterCrashesPlugin.h"

@import AppCenterCrashes;

@class CordovaCrashes;
@class ErrorReport;

@protocol CordovaCrashesDelegate <MSACCrashesDelegate>
// Call to expose a report to JS
- (void)storeReportForJS:(MSACErrorReport *) report;
- (MSACUserConfirmationHandler)shouldAwaitUserConfirmationHandler;


@optional
// Called when the JS code provides a send / don't-send response
- reportUserResponse: (MSACUserConfirmation)confirmation;

@required
// Internal use only, to configure native <-> JS communication
- (NSArray<MSACErrorReport *> *) getAndClearReports;
- (void) provideAttachments: (NSDictionary*) attachments;
- (void) setEventsCallbackChannelForPlugin: (CDVPlugin *) plugin callbackId: (NSString*) id;
@end

@interface CordovaCrashesDelegateBase : NSObject<CordovaCrashesDelegate>
@property NSDictionary* attachments;
@property NSMutableArray* reports;
@property NSString* eventsCallbackId;
@property AppCenterCrashesPlugin* crashesPlugin;
@end

@interface CordovaCrashesDelegateAlwaysSend: CordovaCrashesDelegateBase

@end
