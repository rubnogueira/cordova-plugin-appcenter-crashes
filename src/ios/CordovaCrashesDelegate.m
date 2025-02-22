// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "CordovaCrashesDelegate.h"
#import "CrashesUtils.h"

static NSString *ON_BEFORE_SENDING_EVENT = @"willSendCrash";
static NSString *ON_SENDING_FAILED_EVENT = @"failedSendingCrash";
static NSString *ON_SENDING_SUCCEEDED_EVENT = @"didSendCrash";


@implementation CordovaCrashesDelegateBase

- (instancetype) init
{
    self.reports = [[NSMutableArray alloc] init];
    return self;
}

- (BOOL) crashes:(MSACCrashes *)crashes shouldProcessErrorReport:(MSACErrorReport *)errorReport
{
    // By default handle all reports and expose them all to JS.
    [self storeReportForJS: errorReport];
    return YES;
}

- (MSACUserConfirmationHandler)shouldAwaitUserConfirmationHandler
{
    // Do not send anything until instructed to by JS
    return ^(NSArray<MSACErrorReport *> *errorReports){
        return YES;
    };
}

- (void)storeReportForJS:(MSACErrorReport *) report
{
    [self.reports addObject:report];
}

- (CDVPluginResult*) pluginResultForEvent: (NSString*)eventName withReport: (MSACErrorReport* ) errorReport
{
    NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:
                           eventName, @"type",
                           convertReportToJS(errorReport), @"report",
                           nil];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
    [result setKeepCallbackAsBool:YES];

    return result;
}

- (void) crashes:(MSACCrashes *)crashes willSendErrorReport:(MSACErrorReport *)errorReport
{
    CDVPluginResult* result = [self pluginResultForEvent:ON_BEFORE_SENDING_EVENT
                                             withReport:errorReport];

    [self.crashesPlugin.commandDelegate sendPluginResult:result
                                              callbackId:self.eventsCallbackId];
}

- (void) crashes:(MSACCrashes *)crashes didSucceedSendingErrorReport:(MSACErrorReport *)errorReport
{
    CDVPluginResult* result = [self pluginResultForEvent:ON_SENDING_SUCCEEDED_EVENT
                                              withReport:errorReport];

    [self.crashesPlugin.commandDelegate sendPluginResult:result
                                              callbackId:self.eventsCallbackId];}

- (void) crashes:(MSACCrashes *)crashes didFailSendingErrorReport:(MSACErrorReport *)errorReport withError:(NSError *)sendError
{
    CDVPluginResult* result = [self pluginResultForEvent:ON_SENDING_FAILED_EVENT
                                              withReport:errorReport];

    [self.crashesPlugin.commandDelegate sendPluginResult:result
                                              callbackId:self.eventsCallbackId];}

- (void) provideAttachments: (NSDictionary*) attachments
{
    self.attachments = attachments;
}

- (void) setEventsCallbackChannelForPlugin: (AppCenterCrashesPlugin*) plugin callbackId: (NSString*) id;
{
    self.crashesPlugin = plugin;
    self.eventsCallbackId = id;
}

- (NSArray<MSACErrorAttachmentLog *> *)attachmentsWithCrashes:(MSACCrashes *)crashes
                                             forErrorReport:(MSACErrorReport *)errorReport
{
    id attachmentLogs = [[NSMutableArray alloc] init];
    id attachmentsForErrorReport = [self.attachments objectForKey:[errorReport incidentIdentifier]];
    if (attachmentsForErrorReport && [attachmentsForErrorReport isKindOfClass:[NSArray class]]) {
        for (id attachment in (NSArray *) attachmentsForErrorReport) {
            if (attachment && [attachment isKindOfClass:[NSDictionary class]]) {
                NSDictionary *attachmentDict = (NSDictionary *) attachment;
                id fileName = [attachmentDict objectForKey:@"fileName"];
                NSString *fileNameString = nil;
                if (fileName && [fileName isKindOfClass:[NSString class]]) {
                    fileNameString = (NSString *) fileName;
                }

                // Check for text versus binary attachment.
                id text = [attachmentDict objectForKey:@"text"];
                if (text && [text isKindOfClass:[NSString class]]) {
                    id attachmentLog = [MSACErrorAttachmentLog attachmentWithText:text filename:fileNameString];
                    [attachmentLogs addObject:attachmentLog];
                }
                else {
                    id data = [attachmentDict objectForKey:@"data"];
                    if (data && [data isKindOfClass:[NSString class]]) {

                        // Binary data is passed as a base64 string from Javascript, decode it.
                        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        id contentType = [attachmentDict objectForKey:@"contentType"];
                        NSString *contentTypeString = nil;
                        if (contentType && [contentType isKindOfClass:[NSString class]]) {
                            contentTypeString = (NSString *) contentType;
                        }
                        id attachmentLog = [MSACErrorAttachmentLog attachmentWithBinary:decodedData filename:fileNameString contentType:contentTypeString];
                        [attachmentLogs addObject:attachmentLog];
                    }
                }
            }
        }
    }
    return attachmentLogs;
}

- (NSArray<MSACErrorReport *>*) getAndClearReports
{
    NSArray<MSACErrorReport *>* result = self.reports;
    self.reports = [[NSMutableArray alloc] init];
    return result;
}

@end

@implementation CordovaCrashesDelegateAlwaysSend
- (BOOL) crashes:(MSACCrashes *)crashes shouldProcessErrorReport:(MSACErrorReport *)errorReport
{
    // Do not pass the report to JS, but do process them
    return YES;
}

- (MSACUserConfirmationHandler)shouldAwaitUserConfirmationHandler
{
    // Do not wait for user confirmation, always send.
    return ^(NSArray<MSACErrorReport *> *errorReports){
        return NO;
    };
}

@end
