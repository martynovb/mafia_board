enum FinishGameType {
  ppkCiv,
  ppkMaf,
  reset,
  normalFinish,
  none
}

FinishGameType finishGameTypeMapper(String? type) {
  if (type == FinishGameType.ppkCiv.name) {
    return FinishGameType.ppkCiv;
  } else if (type == FinishGameType.ppkMaf.name) {
    return FinishGameType.ppkMaf;
  } else if (type == FinishGameType.reset.name) {
    return FinishGameType.reset;
  } else if (type == FinishGameType.normalFinish.name) {
    return FinishGameType.normalFinish;
  } else {
    return FinishGameType.none;
  }
}