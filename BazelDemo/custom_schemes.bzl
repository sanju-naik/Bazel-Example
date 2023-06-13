
load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "xcode_schemes",
    "top_level_target"
)

def custom_schemes_for_targets(targets, test_targets):
    schemes = []
    BazelDemo_schemes = ['BazelDemo-Debug', 'BazelDemo-Release']
    for target in targets:
        # For Xcode scheme, just use the plain string scheme name, rather than fully qualified bazel build target
        # Ex: If build target is "//Home:AccountKit", then just use AccountKit for Xcode Scheme name.
        target_name = target.removeprefix('//')
        if target.find(':') != -1:
            target_name = target_name.partition(':')[2]
        if target == 'BazelDemo':
            for scheme_name in BazelDemo_schemes:
                   scheme = create_scheme(target, scheme_name, test_targets)
                   schemes.append(scheme)
        else:
            scheme = create_scheme(target, target_name, test_targets)
            schemes.append(scheme) 
        

    return schemes


def create_scheme(target, scheme_name, test_targets):
     scheme = xcode_schemes.scheme(
        name = scheme_name, 
        build_action = build_action_for(target),
        launch_action = launch_action_for(target,scheme_name),
        profile_action = profile_action_for(target, scheme_name),
        test_action = test_action_for(target,test_targets),
    )
     return scheme       

def build_configuration_for(target):
    if target == 'BazelDemo-Debug':
        return 'Debug'
    elif target == 'BazelDemo-Release':
        return 'Release'
    else:
        return 'Debug'

def build_action_for(target):
    return xcode_schemes.build_action(
                targets = [target], 
                # pre_actions = [xcode_schemes.pre_post_action(
                #     name = "Pre Build Script",
                #     script = "sh \"$SRCROOT/../scripts/pre_actions.sh\"",
                #     expand_variables_based_on = target,
                # )], 
                # post_actions = [xcode_schemes.pre_post_action(
                #     name = "Post Build Script",
                #     script = "sh \"$SRCROOT/../scripts/post_actions.sh\" > /dev/null 2>&1 &",
                #     expand_variables_based_on = target,
                # )],
            )


def launch_action_for(target, scheme_name):
    if target.find('Host') != -1 or target == "BazelDemo":
       return xcode_schemes.launch_action(
                target = target, 
                args = None, 
                diagnostics = None, 
                env = None,
                build_configuration = build_configuration_for(scheme_name),
                working_directory = None,
            )
    else:
        return None



def test_action_for(target,test_targets):
    if target.find('Host') != -1 or target == "BazelDemo":
        return None
    elif "{}Tests".format(target) in test_targets:
        return xcode_schemes.test_action(
                targets = ["{}Tests".format(target)], 
                args = None, 
                diagnostics = None,  
                env = None,
                expand_variables_based_on = None, 
                pre_actions = [], 
                post_actions = []
            )
    else:
        return None 

def profile_action_for(target, scheme_name):
    if target.find('Host') != -1 or target == "BazelDemo":
        return xcode_schemes.profile_action(
                target = target, 
                args = None, 
                build_configuration = build_configuration_for(scheme_name), 
                env = None, 
                working_directory = None,
            )
    else:
        return None


def custom_top_level_targets(targets):
    custom_targets = []
    for target in targets:
        if target.find('Host') != -1 or target == "BazelDemo":
            custom_targets.append(top_level_target(target, target_environments = ["device", "simulator"]))
        else:
            custom_targets.append(target)
    
    return custom_targets