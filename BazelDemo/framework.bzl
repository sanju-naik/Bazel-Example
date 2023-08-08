load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_static_xcframework_import")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_static_framework")

def apple_framework(name, **kwargs):
  # print('scrs - ',kwargs['srcs'])
  if 'vendored_xcframeworks' in kwargs:
    _xcframeworks(name, **kwargs)
  elif 'srcs' in kwargs and '.swift' in str(kwargs['srcs']):
    # print("swift lib", kwargs)    
    _swift_framework(name, **kwargs)
  elif 'srcs' in kwargs and '.m' or '.h' or '.mm' in str(kwargs['srcs']):
    _objc_framework(name, **kwargs) #  _objc_framework(name, kwargs)


def _xcframeworks(name, **kwargs):
    
    xcframework_path = kwargs['vendored_xcframeworks'][0]['slices'][0]['path']
    xcframework_path = xcframework_path.partition('.xcframework')
    xcframework_path = xcframework_path[0] + xcframework_path[1]
    xcframework_path = xcframework_path + "/**"
    # print("xcframework path -",xcframework_path)
    apple_static_xcframework_import(
      name = name,
      xcframework_imports = native.glob([xcframework_path]),
      visibility = kwargs.get('visibility'),
      # data = kwargs.get('data'),
      deps = kwargs.get('deps'),
      sdk_dylibs = kwargs.get('sdk_dylibs'),
      sdk_frameworks = kwargs.get('sdk_frameworks'),
      weak_sdk_frameworks = kwargs.get('weak_sdk_frameworks'),
    )

def _swift_framework(name, **kwargs):
    swift_library(
      name = name,
      srcs = kwargs['srcs'],
      module_name = kwargs.get('module_name', name),
      data = kwargs.get('data'),
      deps = kwargs.get('deps'),
      visibility = kwargs.get('visibility'),
    )

    # ios_static_framework(
    #   name = name,
    #   deps = ["{}Lib".format(name)],
    #   minimum_os_version = "12.0",
    #   visibility = kwargs.get('visibility'),
    # )


def _objc_framework(name, **kwargs):
    # We need to construct list of directories with header files and pass it in copts for bazel to find headers,
    # bazel won't find headers with relative paths by default like Xcode when building ObjC.
    # This comment has more details - https://github.com/bazelbuild/bazel/issues/12131#issuecomment-695094803 
    header_includes = kwargs.get('public_headers')
    include_directories = []

    for hdr_file in header_includes:
      directory = hdr_file.rpartition("/")[0]
      if directory not in include_directories:
        include_directories.append(directory)

    copts_includes = []
    for include_dir in include_directories:
      include_path = "-IPods/{}/{}".format(name,include_dir)
      copts_includes.append(include_path)

    # print("include_directories",copts_includes)
    
    native.objc_library(
      name = name,
      srcs = kwargs['srcs'],
      hdrs = kwargs.get('public_headers'),
      sdk_dylibs = kwargs.get('sdk_dylibs'),
      sdk_frameworks = kwargs.get('sdk_frameworks'),
      defines = kwargs.get('xcconfig'),
      visibility = kwargs.get('visibility'),
      module_name = name,
      enable_modules = True,
      copts = copts_includes,
      data = kwargs.get('data'),
      # includes = ["Pods/SAMKeychain/Sources"],
    )
