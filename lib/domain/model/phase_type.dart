enum PhaseType { speak, vote, night, info, none }

PhaseType phaseTypeMapper(String? role) {
  if (role == PhaseType.speak.name) {
    return PhaseType.speak;
  } else if (role == PhaseType.vote.name) {
    return PhaseType.vote;
  } else if (role == PhaseType.night.name) {
    return PhaseType.night;
  } else if (role == PhaseType.info.name) {
    return PhaseType.info;
  } else {
    return PhaseType.none;
  }
}
