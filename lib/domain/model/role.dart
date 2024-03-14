enum Role {
  mafia,
  don,
  sheriff,
  civilian,
  doctor,
  putana,
  maniac,
  none,
}

Set<Role> civilianRoles() => {
      Role.sheriff,
      Role.civilian,
      Role.doctor,
      Role.putana,
      Role.maniac,
    };

Set<Role> mafiaRoles() => {
      Role.don,
      Role.mafia,
    };

Role roleMapper(String? role) {
  if (role == Role.don.name) {
    return Role.don;
  } else if (role == Role.mafia.name) {
    return Role.mafia;
  } else if (role == Role.sheriff.name) {
    return Role.sheriff;
  } else if (role == Role.civilian.name) {
    return Role.civilian;
  } else if (role == Role.doctor.name) {
    return Role.doctor;
  } else if (role == Role.putana.name) {
    return Role.putana;
  } else if (role == Role.maniac.name) {
    return Role.maniac;
  } else {
    return Role.none;
  }
}

String roleEmojiMapper(Role role) {
  switch (role) {
    case Role.mafia:
      return '👎🏻';
    case Role.don:
      return '🎩';
    case Role.sheriff:
      return '🚨';
    case Role.civilian:
      return '👍🏻';
    case Role.doctor:
      return '🏥';
    case Role.putana:
      return '👠';
    case Role.maniac:
      return '🔪';
    case Role.none:
      return '❓';
  }
}
