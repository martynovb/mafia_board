enum WinnerType {
  mafia,
  civilian,
  none

}
WinnerType mapWinnerType(String? type) {
  if(type == WinnerType.mafia.name) {
    return WinnerType.mafia;
  } else if(type == WinnerType.civilian.name) {
    return WinnerType.civilian;
  } else {
    return WinnerType.none;
  }
}

