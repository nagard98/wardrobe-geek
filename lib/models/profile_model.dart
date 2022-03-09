import 'package:flutter/widgets.dart';

class ProfileModel {
  String username;
  late String? nome;
  late String? cognome;
  late String? citta;
  late String? nazione;
  late int? numFollower;
  late int? numFollowing;
  late int? livello;
  late Image? profilePicture;

  ProfileModel(
      {required this.username,
      this.nome,
      this.cognome,
      this.citta,
      this.nazione,
      this.numFollower,
      this.numFollowing,
      this.livello,
      this.profilePicture});
}

ProfileModel profile = ProfileModel(username: "test");