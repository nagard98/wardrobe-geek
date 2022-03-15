import 'package:flutter/widgets.dart';

class ProfileModel extends ChangeNotifier{
  String username;
  int? id;
  String? nome;
  String? cognome;
  String? citta;
  String? nazione;
  int? numFollower;
  int? numFollowing;
  int? livello;
  Image? profilePicture;

  ProfileModel(
      {required this.username,
      this.id,
      this.nome,
      this.cognome,
      this.citta,
      this.nazione,
      this.numFollower,
      this.numFollowing,
      this.livello,
      this.profilePicture});
}

ProfileModel profile = ProfileModel(username: "Naagard", id: 1);
