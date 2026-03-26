enum GameMode { friends, couples }

extension GameModeX on GameMode {
  bool get isFriends => this == GameMode.friends;
  bool get isCouples => this == GameMode.couples;
}
