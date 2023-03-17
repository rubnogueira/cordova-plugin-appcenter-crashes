// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@import AppCenterCrashes.MSACErrorReport;

NSDictionary* convertReportToJS(MSACErrorReport* report);
NSArray* convertReportsToJS(NSArray* reports);
