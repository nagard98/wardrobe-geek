import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:esempio/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:esempio/screens/login.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      body: ProfileFrontLayer(controller: controller),
    );
  }
}

class ProfileBackLayer extends StatelessWidget {
  const ProfileBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ProfileFrontLayer extends StatefulWidget {
  const ProfileFrontLayer({Key? key, required this.controller})
      : super(key: key);

  final AnimationController controller;

  @override
  State<StatefulWidget> createState() {
    return ProfileFrontLayerState();
  }
}

class ProfileFrontLayerState extends State<ProfileFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalAccount>(builder: (context, profile, child) {
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: const Color(0xFFFDCDA2),
            title: const Text("Profilo"),
            actions: [
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
                if(profile.isLoggedIn){
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        curve: Curves.easeInOutCubic, parent: _animationOpacity),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                          curve: Curves.easeInOutCubic, parent: _animationScale),
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
                                    profile.logout();
                                  },
                                  child: Text("Logout"),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    "${profile.myProfile.name} ${profile.myProfile.surname}"),
                                Text(
                                    "${profile.myProfile.city}, ${profile.myProfile.city}"),
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
                                          Text("${profile.myProfile.numFollower}")
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
                                              "${profile.myProfile.numFollowing}")
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
/*                        HorizontalMoreList(
                            itemHeight: 200,
                          ),*/
                                const SizedBox(
                                  height: 30,
                                ),
                                /*                   HorizontalMoreList(
                            itemHeight: 150,
                            cardShape: CircleBorder(),
                          ),*/
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
                }else{
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 128, 16, 0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text("Fai il login per accedere a tutte le funzionalità",softWrap: true,),
                        const SizedBox(height: 10,),
                        ElevatedButton(
                          onPressed: () {
                            pushNewScreen(context,
                                screen: Login(), withNavBar: true, pageTransitionAnimation: PageTransitionAnimation.slideUp);
                          },
                          child: const Text("Login"),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Non hai un account? "),
                            TextButton(onPressed: (){
                              pushNewScreen(
                                  context,
                                  screen: Register(),
                                  withNavBar: true,
                                  pageTransitionAnimation: PageTransitionAnimation.slideUp
                              );
                            }, child: const Text("Registrati"))
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
  const ProfilePicture({Key? key, this.topMargin = 5}) : super(key: key);

  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: InkWell(
          //TODO: implementa immagine full screen profilo
/*          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const FullScreenImage(
                  imageUrl: "https://picsum.photos/500?image=42",
                  tag: "avatar");
            }));
          },*/
          child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: "avatar",
            child: CircleAvatar(
              radius: 80,
              backgroundImage: Image.network(
                'https://picsum.photos/500?image=42',
                fit: BoxFit.fitHeight,
              ).image,
            ),
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
