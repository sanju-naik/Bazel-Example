load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_extension")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

load("//:custom_schemes.bzl","custom_schemes_for_targets","custom_top_level_targets")

load("@build_bazel_rules_apple//apple/testing/default_runner:ios_test_runner.bzl","ios_test_runner")

load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
    "xcode_schemes"
)

xcodeproj(
    name = "BazelDemo_gen",
    project_name = "BazelDemo",
    tags = ["manual"],
    pre_build = "echo 'Hello world'",
    top_level_targets = [
        top_level_target(":BazelDemo", target_environments = ["simulator"]),
        # top_level_target(":BazelDemoTests", target_environments = ["simulator"]),
    ],
    schemes = custom_schemes_for_targets(["BazelDemo"],[]),
    scheme_autogeneration_mode = "none",
    xcode_configurations = {
        "Debug": {"//command_line_option:compilation_mode": "dbg",
                  "//command_line_option:apple_generate_dsym": False,
                  "//:variant": "debug",
                  "//command_line_option:features": [],
                  },
        "Alpha": {"//command_line_option:compilation_mode": "opt",
                    "//:variant": "alpha",
                    "//command_line_option:apple_generate_dsym": True,
                    "//command_line_option:features": [
                        "swift.debug_prefix_map",
                        "swift.debug_prefix_map_pwd_is_dot",
                        "swift.file_prefix_map",
                        "swift.full_debug_info",
                    ],
                },
        "Release": {"//command_line_option:compilation_mode": "opt",
                    "//:variant": "release",
                    "//command_line_option:apple_generate_dsym": True,
                    "//command_line_option:features": [
                        "swift.debug_prefix_map",
                        "swift.debug_prefix_map_pwd_is_dot",
                        "swift.file_prefix_map",
                        "swift.full_debug_info",
                    ],
                }
    }
)
#                         "swift.opt_uses_osize",

# "swift.full_debug_info",


swift_library(
    name = "BazelDemoSources",
    module_name = "BazelDemo",
    srcs = glob(["BazelDemo/**/*.swift"]),
    data = [
        "BazelDemo/Base.lproj/Main.storyboard",
        "BazelDemo/Base.lproj/LaunchScreen.storyboard",
        "BazelDemo/Assets.xcassets",
    ],
    # deps = ["//Pods/AppsFlyerFramework"],
    # deps = ["//Pods/Firebase","//Pods/FirebaseCrashlytics","//Pods/FirebaseSessions",]
    # select({
    #     ":Debug": ,
    #     ":Release": ["//Pods/Firebase"],
    # })
)

ios_application(
    name = "BazelDemo",
    bundle_id = select({
        "//:Debug": "com.go-jek.ent.staging.develop", # com.bazeldemo.debug.app
        "//:Alpha": "com.bazeldemo.alpha.app",
        "//:Release": "com.bazeldemo.release.app",
    }), 
    families = ["iphone"],
    infoplists = [":BazelDemo/Info.plist"],
    minimum_os_version = "12.0",
    deps = [":BazelDemoSources"],
    visibility = ["//visibility:public"],
    resources = select({
        ":Release": ["Resources/GoogleService-Info.plist"],
        ":Debug": ["Resources/Debug/GoogleService-Info.plist"],
        "//conditions:default": None, 
    }),
    entitlements = select({
            ":Debug": "Entitlements/Debug.entitlements",
            ":Alpha": "Entitlements/Alpha.entitlements",
            ":Release": "Entitlements/Release.entitlements",
     }),
    # launch_storyboard = "BazelDemo/Base.lproj/LaunchScreen.storyboard",
  )

string_flag(
        name = "variant",
        build_setting_default = "debug",
        visibility = ["//visibility:public"],
    )
    
config_setting(
        name = "Release",
        flag_values = {
            "//:variant": "release",
        },
        visibility = ["//visibility:public"],
    )
    
config_setting(
        name = "Debug",
        flag_values = {
            "//:variant": "debug",
        },
        visibility = ["//visibility:public"],
    )

config_setting(
        name = "Alpha",
        flag_values = {
            "//:variant": "alpha",
        },
        visibility = ["//visibility:public"],
    )

# swift_library(
#     name = "BazelDemoTestsSources",
#     srcs = glob(["BazelDemoTests/**/*.swift"]),
#     testonly = True,
#     deps = [":BazelDemoSources"],
# )

# ios_unit_test(
#    name = "BazelDemoTests",
#    deps = [":BazelDemoTestsSources"],
#    minimum_os_version = "14.5",
#    runner = ":IPhone_12",
#    visibility = ["//visibility:public"],
# )

# ios_test_runner(
#     name = "IPhone_12",
#     device_type = "iPhone 12",
#     test_environment = {"LCOV_MERGER": "/usr/bin/true"},
# )
