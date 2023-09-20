import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/screens/more_screen/help_screen.dart';
import 'package:much_todo/src/screens/more_screen/uploaded_photos_screen.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_tasks.dart';
import 'package:much_todo/src/services/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/sign_in_screen.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/screens/more_screen/user_contacts.dart';
import 'package:much_todo/src/screens/more_screen/user_tags.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/skeletons/more_screen_skeleton.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key, required this.controller});

  final SettingsProvider controller;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

enum AccountOptions { logout, delete }

class _MoreScreenState extends State<MoreScreen> {
  final _scrollController = ScrollController();
  String? _version;

  @override
  void initState() {
    super.initState();
    setPackageInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserProvider>().user;
    if (user == null || context.watch<UserProvider>().isLoading) {
      return const MoreScreenSkeleton();
    }
    return Scrollbar(
      controller: _scrollController,
      child: ListView(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Much To Do', style: Theme.of(context).textTheme.displayMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                    child: Text(
                      _version ?? '',
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
              ListTile(
                title: Text(user.email),
                subtitle: const Text(
                  'ACCOUNT',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: accountDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Card(
            child: ListTile(
              title: Text(user.tags.isNotEmpty ? '${user.tags.length} Tags' : 'No tags'),
              onTap: launchTags,
              leading: const Icon(Icons.tag),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(user.contacts.isNotEmpty ? '${user.contacts.length} Contacts' : 'No contacts'),
              onTap: launchContacts,
              leading: const Icon(Icons.person),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Completed Tasks'),
              onTap: launchCompletedTasks,
              leading: const Icon(Icons.check),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Uploaded Photos'),
              onTap: launchUploadedPhotos,
              leading: const Icon(Icons.camera_alt),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.brush),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: widget.controller.themeMode,
                  dropdownColor: getDropdownColor(context),
                  onChanged: widget.controller.updateThemeMode, // rebuilds MaterialApp
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Card(
            child: ListTile(
              title: const Text('Help'),
              onTap: launchHelp,
              leading: const Icon(Icons.help),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Privacy Policy'),
              onTap: launchPrivacyPolicy,
              leading: const Icon(Icons.policy_outlined),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Terms and Conditions'),
              onTap: launchTermsAndConditions,
              leading: const Icon(Icons.article),
            ),
          ),
        ],
      ),
    );
  }

  Widget accountDropdown() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Account Options',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) {
        return <PopupMenuEntry<AccountOptions>>[
          const PopupMenuItem<AccountOptions>(
            value: AccountOptions.logout,
            child: Text('Sign-out'),
          ),
          PopupMenuItem<AccountOptions>(
            value: AccountOptions.delete,
            child: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ];
      },
      onSelected: (AccountOptions result) => onAccountOptionSelected(result),
    );
  }

  void onAccountOptionSelected(AccountOptions result) {
    switch (result) {
      case AccountOptions.logout:
        signOut();
        break;
      case AccountOptions.delete:
        final user = FirebaseAuth.instance.currentUser;
        bool hasPassword = user!.providerData.any((element) => element.providerId == 'password');
        if (hasPassword) {
          promptDeleteAccountPasswordConfirm();
        } else {
          promptDeleteAccountGoogle();
        }
        break;
    }
    setState(() {});
  }

  Future<void> setPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void launchTags() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserTags(),
      ),
    );
  }

  void launchContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserContacts(),
      ),
    );
  }

  void launchCompletedTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompletedTasks(),
      ),
    );
  }

  void launchUploadedPhotos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadedPhotosScreen(
          userId: context.read<UserProvider>().user!.id,
        ),
      ),
    );
  }

  void launchHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  Future<void> launchPrivacyPolicy() async {
    var uri = Uri.parse('https://storage.googleapis.com/much-to-do-sites/privacy_policy.html');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch privacy policy.', context);
      }
    }
  }

  Future<void> launchTermsAndConditions() async {
    var uri = Uri.parse('https://storage.googleapis.com/much-to-do-sites/terms_and_conditions.html');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch terms & conditions.', context);
      }
    }
  }

  Future<void> signOut() async {
    var result = await UserService.signOut(context);
    if (context.mounted && result.success) {
      Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (route) => false);
    } else if (context.mounted && result.failure) {
      showSnackbar(result.errorMessage!, context);
    }
  }

  Future<void> deleteAccount() async {
    var result = await UserService.deleteUser(context);
    if (context.mounted && result.success) {
      Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (route) => false);
    } else if (context.mounted && result.failure) {
      showSnackbar(result.errorMessage!, context);
    }
  }

  Future<void> promptDeleteAccountGoogle() async {
    final confirmController = TextEditingController();
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog.adaptive(
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      hideKeyboard();
                      var user = FirebaseAuth.instance.currentUser!;
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        var googleSignInResult = await AuthService.getGoogleCredential();
                        if (googleSignInResult.failure) {
                          setState(() {
                            isLoading = false;
                            errorText = 'Incorrect Google account';
                          });
                          return;
                        }
                        await user.reauthenticateWithCredential(googleSignInResult.data!);

                        if (context.mounted) {
                          Navigator.pop(context);
                          deleteAccount();
                        }
                      } catch (e) {
                        setState(() {
                          errorText = 'Error';
                        });
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator() : const Text('DELETE'),
                )
              ],
              title: const Text('Delete Account'),
              insetPadding: const EdgeInsets.all(8.0),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Are you sure you wish to delete your account? This action is permanent and all of your data will be gone!'
                          '\n\nType "Delete" to confirm.'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Confirmation',
                            errorText: errorText,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: confirmController,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Required';
                            } else if (val.toLowerCase() != 'delete') {
                              return 'Invalid';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (errorText != null) {
                              setState(() {
                                errorText = null;
                              });
                            }
                          },
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> promptDeleteAccountPasswordConfirm() async {
    final passwordController = TextEditingController();
    bool hidePassword = true;
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog.adaptive(
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      hideKeyboard();
                      var user = FirebaseAuth.instance.currentUser!;
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        await user.reauthenticateWithCredential(EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text,
                        ));
                        if (context.mounted) {
                          Navigator.pop(context);
                          deleteAccount();
                        }
                      } catch (e) {
                        setState(() {
                          errorText = 'Invalid credentials';
                        });
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator() : const Text('DELETE'),
                )
              ],
              title: const Text('Delete Account'),
              insetPadding: const EdgeInsets.all(8.0),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Are you sure you wish to delete your account? This action is permanent and all of your data will be gone!'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            labelText: 'Password *',
                            errorText: errorText,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                                child: Icon(
                                  hidePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: passwordController,
                          obscureText: hidePassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (errorText != null) {
                              setState(() {
                                errorText = null;
                              });
                            }
                          },
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
