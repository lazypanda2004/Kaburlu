import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/pages/profile/edit_profile.dart';
import 'package:kaburlu/pages/profile/passwordchange.dart';
import 'package:kaburlu/pages/profile/privacy.dart';
import 'package:kaburlu/pages/Auth/welcome.dart';
import 'package:kaburlu/widgets/dataWidgets/email_prov.dart';
import 'package:kaburlu/widgets/dataWidgets/image_prov.dart';
import 'package:kaburlu/widgets/dataWidgets/username_prov.dart';
import 'package:lottie/lottie.dart';

class Profile_Screen extends StatefulWidget {
  const Profile_Screen({super.key});

  @override
  State<Profile_Screen> createState() => _Profile_ScreenState();
}

class _Profile_ScreenState extends State<Profile_Screen> {
  User user = FirebaseAuth.instance.currentUser!;
  String id = FirebaseAuth.instance.currentUser!.uid;
  String userimageurl = '';
  String username = '';
  String _email = '';

  void getdata() async {
    final DocumentSnapshot userdoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    Map<String, dynamic> userDataMap = userdoc.data() as Map<String, dynamic>;
    setState(() {
      username = userDataMap['username'];
      _email = userDataMap['email'];
      userimageurl = userDataMap['image_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 210,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                          offset: const Offset(0, 6),
                          blurRadius: 12,
                          spreadRadius: 6,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.black87,
                          Colors.black54,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ProfileImage(
                                  id: id,
                                  radius: 35,
                                ),
                                const Spacer(),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.black,
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                      color: Colors.black,
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        if (mounted) {
                                          Navigator.pushNamed(
                                              context, WelcomeScreen.id);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.exit_to_app,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            UsernameProv(
                              documentid: id,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            EmailProv(documentid: id, color: Colors.white)
                          ],
                        )),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Center(
                    child: Text(
                      'My Account',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return EditProfile(id: id);
                        }),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Edit Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return Passwordchange(
                            id: id,
                          );
                        }),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Change Password',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const Privacy();
                        }),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Privacy Policy',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.11,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Lottie.asset('lib/assets/cat.json'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
