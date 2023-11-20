enum Role {
  MAFIA,
  DON,
  SHERIFF,
  CIVILIAN,
  DOCTOR,
  PUTANA,
  MANIAC,
  NONE,
}

Set<Role> civilianRoles() => {
      Role.SHERIFF,
      Role.CIVILIAN,
      Role.DOCTOR,
      Role.PUTANA,
      Role.MANIAC,
    };

Set<Role> mafiaRoles() => {
      Role.DON,
      Role.MAFIA,
    };

Role roleMapper(String? role) {
  if (role == Role.DON.name) {
    return Role.DON;
  } else if (role == Role.MAFIA.name) {
    return Role.MAFIA;
  } else if (role == Role.SHERIFF.name) {
    return Role.SHERIFF;
  } else if (role == Role.CIVILIAN.name) {
    return Role.CIVILIAN;
  } else if (role == Role.DOCTOR.name) {
    return Role.DOCTOR;
  } else if (role == Role.PUTANA.name) {
    return Role.PUTANA;
  } else if (role == Role.MANIAC.name) {
    return Role.MANIAC;
  } else {
    return Role.NONE;
  }
}
