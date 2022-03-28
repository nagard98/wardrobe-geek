import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:esempio/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:esempio/screens/login.dart';
import 'dart:io';
import 'package:esempio/common/utils.dart';
import 'dart:developer';
import 'package:esempio/screens/outfit.dart';
import 'package:esempio/models/explore_model.dart';

class Profile extends StatelessWidget {
  Profile({Key? key, this.controller, this.profile}) : super(key: key);

  PersonalAccount? profile;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      body: ProfileFrontLayer(
        controller: controller,
        profile: profile,
      ),
    );
  }
}

class ProfileFrontLayer extends StatefulWidget {
  ProfileFrontLayer({Key? key, required this.controller, this.profile})
      : super(key: key);

  PersonalAccount? profile;
  final AnimationController? controller;

  @override
  State<StatefulWidget> createState() {
    return ProfileFrontLayerState();
  }
}

class ProfileFrontLayerState extends State<ProfileFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;
  late bool isEditable;

  @override
  void initState() {
    super.initState();
    isEditable = widget.profile == null;
    if (widget.controller != null) {
      _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller!);
    }
    if (widget.controller != null) {
      _animationOpacity =
          Tween(begin: 0.3, end: 1.0).animate(widget.controller!);
    }
    //Carica outfit e followed se profilo non è il proprio
    if (widget.profile != null) widget.profile!.loadData();
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalAccount>(builder: (context, profile, child) {
      widget.profile ??= profile;
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: const Color(0xFFFDCDA2),
            title: const Text("Profilo"),
            actions: [
              if (isEditable)
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Settings()));
                    },
                    icon: const Icon(Icons.settings))
            ],
            expandedHeight: 130,
            pinned: true,
            snap: false,
            floating: false,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (widget.profile!.isLoggedIn) {
                  if (widget.controller != null) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                          curve: Curves.easeInOutCubic,
                          parent: _animationOpacity),
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                            curve: Curves.easeInOutCubic,
                            parent: _animationScale),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 185,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF425C5A),
                                      border: Border.all(
                                          color: const Color(0xFF425C5A),
                                          width: 2)),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16))),
                                  height: 60,
                                  margin: const EdgeInsets.only(top: 130),
                                ),
                                ProfilePicture(
                                    imgPath: widget.profile?.myProfile
                                        .pathPicture as String),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      style: BorderStyle.none, width: 0)),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.profile!.logout();
                                    },
                                    child: Text("Logout"),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      "${widget.profile!.myProfile.name} ${widget.profile!.myProfile.surname}"),
                                  Text(
                                      "${widget.profile!.myProfile.city}, ${widget.profile!.myProfile.city}"),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFDCDA2),
                                            border: Border.all(
                                                color: const Color(0xFFFDCDA2),
                                                width: 0),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10))),
                                        child: Column(
                                          children: [
                                            const Text("Followers"),
                                            Text(
                                                "${widget.profile!.myProfile.numFollower}")
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFDCDA2),
                                            border: Border.all(
                                                color: const Color(0xFFFDCDA2),
                                                width: 0),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10))),
                                        child: Column(
                                          children: [
                                            const Text("Following"),
                                            Text(
                                                "${widget.profile!.myProfile.numFollowing}")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  const Divider(
                                    height: 300,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 185,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF425C5A),
                                  border: Border.all(
                                      color: const Color(0xFF425C5A),
                                      width: 2)),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16))),
                              height: 60,
                              margin: const EdgeInsets.only(top: 130),
                            ),
                            const ProfilePicture(),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  style: BorderStyle.none, width: 0)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  widget.profile!.logout();
                                },
                                child: Text("Logout"),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                  "${widget.profile!.myProfile.name} ${widget.profile!.myProfile.surname}"),
                              Text(
                                  "${widget.profile!.myProfile.city}, ${widget.profile!.myProfile.city}"),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFDCDA2),
                                        border: Border.all(
                                            color: const Color(0xFFFDCDA2),
                                            width: 0),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10))),
                                    child: Column(
                                      children: [
                                        const Text("Followers"),
                                        Text(
                                            "${widget.profile!.myProfile.numFollower ?? 0}")
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFDCDA2),
                                        border: Border.all(
                                            color: const Color(0xFFFDCDA2),
                                            width: 0),
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Column(
                                      children: [
                                        const Text("Following"),
                                        Text(
                                            "${widget.profile!.myProfile.numFollowing ?? 0}")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Outfit Popolari"),
                                          TextButton(
                                            style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        const Color(
                                                            0xFFFDCDA2)),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        const Color(
                                                            0xFFA4626D))),
                                            onPressed: () {
                                              log("asd");
                                              //explore2?.showScreen(1, section);
                                            },
                                            child: Row(
                                              children: const [
                                                Text("Vedi Tutti"),
                                                Icon(Icons.arrow_forward_ios)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      ChangeNotifierProvider.value(
                                        value: widget.profile,
                                        child: SizedBox(
                                          height: 250,
                                          child: Consumer<PersonalAccount>(
                                            builder: (context, userProfile, child) {
                                              return GridView.builder(
                                                scrollDirection: Axis.horizontal,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                      childAspectRatio: 1.6,
                                                        crossAxisCount: 1),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    child: Hero(
                                                      tag: "profileOutfit$index",
                                                      child: Card(
                                                        child: Image.file(
                                                          //TODO: implement dynamic loading
                                                          File(userProfile.outfits[index].imgPath!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => Outfit(
                                                            outfit: userProfile.outfits[index],
                                                            heroTag: "profileOutfit$index", section: Section.popOutf,

                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                itemCount:
                                                    userProfile.outfits.length,
                                              );
                                            }
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Utenti Seguiti"),
                                          TextButton(
                                            style: ButtonStyle(
                                                overlayColor:
                                                MaterialStateProperty.all(
                                                    const Color(
                                                        0xFFFDCDA2)),
                                                foregroundColor:
                                                MaterialStateProperty.all(
                                                    const Color(
                                                        0xFFA4626D))),
                                            onPressed: () {
                                              log("asd");
                                              //explore2?.showScreen(1, section);
                                            },
                                            child: Row(
                                              children: const [
                                                Text("Vedi Tutti"),
                                                Icon(Icons.arrow_forward_ios)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      ChangeNotifierProvider.value(
                                        value: widget.profile,
                                        child: SizedBox(
                                          height: 250,
                                          child: Consumer<PersonalAccount>(
                                              builder: (context, userProfile, child) {
                                                return GridView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                      childAspectRatio: 1.6,
                                                      crossAxisCount: 1),
                                                  itemBuilder: (context, index) {
                                                    return InkWell(
                                                      child: Hero(
                                                        tag: "profileFollowd$index",
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 48,
                                                              backgroundColor: const Color(0xFF425C5A),
                                                              backgroundImage: userProfile.followed[index].pathPicture!.isEmpty ? Image.file(
                                                                //TODO: implement dynamic loading
                                                                File(userProfile.followed[index].pathPicture!),
                                                                fit: BoxFit.cover,
                                                              ).image : Image.asset('assets/profile_placeholder.png',fit: BoxFit.fitWidth,).image,
                                                            ),
                                                            Text(userProfile.followed[index].name)
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                                          PersonalAccount temp = PersonalAccount();
                                                          temp.myProfile = userProfile.followed[index];
                                                          return Profile(profile: temp,);
                                                        }));
                                                      },
                                                    );
                                                  },
                                                  itemCount:
                                                  userProfile.followed.length,
                                                );
                                              }
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 300,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 128, 16, 0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          "Fai il login per accedere a tutte le funzionalità",
                          softWrap: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFA4626D))),
                          onPressed: () {
                            pushNewScreen(context,
                                screen: Login(),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.slideUp);
                          },
                          child: const Text("Login"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Non hai un account? "),
                            TextButton(
                                style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        const Color(0xFFA4626D))),
                                onPressed: () {
                                  pushNewScreen(context,
                                      screen: Register(),
                                      withNavBar: true,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.slideUp);
                                },
                                child: const Text("Registrati"))
                          ],
                        )
                      ],
                    ),
                  );
                }
              },
              childCount: 1,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                width: 0,
                                color: Colors.white,
                                style: BorderStyle.none))))
              ],
            ),
          ),
        ],
      );
    });
  }
}

class ProfilePicture extends StatelessWidget {
  const ProfilePicture(
      {Key? key, this.topMargin = 5, this.imgPath, this.heroTag})
      : super(key: key);

  final double topMargin;
  final String? imgPath;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Image image = imgPath == null
        ? Image.asset(
            'assets/profile_placeholder.png',
            fit: BoxFit.fitWidth,
          )
        : Image.file(
            File(imgPath!),
            fit: BoxFit.fitHeight,
          );
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: InkWell(
          //TODO: implementa immagine full screen profilo
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return FullScreenImage(image: image, tag: heroTag ?? uuid.v1());
            }));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: heroTag ?? uuid.v1(),
                child: CircleAvatar(radius: 80, backgroundImage: image.image),
              ),
              SleekCircularSlider(
                initialValue: 80,
                innerWidget: (value) {
                  return Container();
                },
                appearance: CircularSliderAppearance(
                  customColors: CustomSliderColors(
                      progressBarColor: const Color(0xFFF39053),
                      trackColor: const Color(0xFFA4626D)),
                  customWidths: CustomSliderWidths(progressBarWidth: 10),
                  size: 170,
                ),
              )
            ],
          )),
    );
  }
}
