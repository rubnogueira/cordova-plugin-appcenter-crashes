// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@import AppCenterCrashes.MSErrorReport;

NSDictionary* convertReportToJS(ErrorReport* report);
NSArray* convertReportsToJS(NSArray* reports);
