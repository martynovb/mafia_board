enum FinishGameType { ppk, reset, normalFinish, none }

FinishGameType finishGameTypeMapper(String? type) {
  if (type == FinishGameType.ppk.name) {
    return FinishGameType.ppk;
  } else if (type == FinishGameType.reset.name) {
    return FinishGameType.reset;
  } else if (type == FinishGameType.normalFinish.name) {
    return FinishGameType.normalFinish;
  } else {
    return FinishGameType.none;
  }
}
