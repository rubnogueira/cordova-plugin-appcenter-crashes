// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "CrashesUtils.h"

@import AppCenterCrashes.ErrorReport;
@import AppCenter.MSDevice;

NSArray* convertReportsToJS(NSArray* reports) {
    NSMutableArray* jsReadyReports = [[NSMutableArray alloc] init];
    [reports enumerateObjectsUsingBlock:^(MSACErrorReport* report, NSUInteger idx, BOOL * stop) {
        [jsReadyReports addObject:convertReportToJS(report)];
    }];
    return jsReadyReports;
}


static NSString *const kMSACSdkName = @"sdk_name";
static NSString *const kMSACSdkVersion = @"sdk_version";
static NSString *const kMSACModel = @"model";
static NSString *const kMSACOemName = @"oem_name";
static NSString *const kMSACOsName = @"os_name";
static NSString *const kMSACOsVersion = @"os_version";
static NSString *const kMSACOsBuild = @"os_build";
static NSString *const kMSACOsApiLevel = @"os_api_level";
static NSString *const kMSACLocale = @"locale";
static NSString *const kMSACTimeZoneOffset = @"time_zone_offset";
static NSString *const kMSACScreenSize = @"screen_size";
static NSString *const kMSACAppVersion = @"app_version";
static NSString *const kMSACCarrierName = @"carrier_name";
static NSString *const kMSACCarrierCountry = @"carrier_country";
static NSString *const kMSACAppBuild = @"app_build";
static NSString *const kMSACAppNamespace = @"app_namespace";

static NSDictionary *serializeDeviceToDictionary(MSDevice* device) {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if (device.sdkName) {
        dict[kMSACSdkName] = device.sdkName;
    }
    if (device.sdkVersion) {
        dict[kMSACSdkVersion] = device.sdkVersion;
    }
    if (device.model) {
        dict[kMSACModel] = device.model;
    }
    if (device.oemName) {
        dict[kMSACOemName] = device.oemName;
    }
    if (device.osName) {
        dict[kMSACOsName] = device.osName;
    }
    if (device.osVersion) {
        dict[kMSACOsVersion] = device.osVersion;
    }
    if (device.osBuild) {
        dict[kMSACOsBuild] = device.osBuild;
    }
    if (device.osApiLevel) {
        dict[kMSACOsApiLevel] = device.osApiLevel;
    }
    if (device.locale) {
        dict[kMSACLocale] = device.locale;
    }
    if (device.timeZoneOffset) {
        dict[kMSACTimeZoneOffset] = device.timeZoneOffset;
    }
    if (device.screenSize) {
        dict[kMSACScreenSize] = device.screenSize;
    }
    if (device.appVersion) {
        dict[kMSACAppVersion] = device.appVersion;
    }
    if (device.carrierName) {
        dict[kMSACCarrierName] = device.carrierName;
    }
    if (device.carrierCountry) {
        dict[kMSACCarrierCountry] = device.carrierCountry;
    }
    if (device.appBuild) {
        dict[kMSACAppBuild] = device.appBuild;
    }
    if (device.appNamespace) {
        dict[kMSACAppNamespace] = device.appNamespace;
    }
    return dict;
}

NSDictionary* convertReportToJS(MSACErrorReport* report) {
    if (report == nil) {
        return nil;
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSString * identifier = [report incidentIdentifier];
    if (identifier) {
        dict[@"id"] = identifier;
    }

    NSUInteger processIdentifier = [report appProcessIdentifier];
    dict[@"appProcessIdentifier"] = @(processIdentifier);

    NSTimeInterval startTime = [[report appStartTime] timeIntervalSince1970];
    if (startTime) {
      dict[@"appStartTime"] = @(startTime);
    }
    NSTimeInterval errTime = [[report appErrorTime] timeIntervalSince1970];
    if (errTime) {
      dict[@"appErrorTime"] = @(errTime);
    }

    NSString * exceptionName = [report exceptionName];
    if (exceptionName) {
      dict[@"exceptionName"] = exceptionName;
    }
    NSString * exceptionReason = [report exceptionReason];
    if (exceptionReason) {
      dict[@"exceptionReason"] = exceptionReason;
    }

    NSString * signal = [report signal];
    if (signal) {
      dict[@"signal"] = signal;
    }

    dict[@"device"] = serializeDeviceToDictionary([report device]);

    return dict;
}
