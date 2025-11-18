class UserSession {
  UserSession._();

  static final UserSession instance = UserSession._();

  String? nombreCompleto;
  String? dni;
  int? clubId;

  void update({
    String? nombre,
    String? nuevoDni,
    int? nuevoClubId,
  }) {
    if (nombre != null) {
      nombreCompleto = nombre;
    }
    if (nuevoDni != null) {
      dni = nuevoDni;
    }
    if (nuevoClubId != null) {
      clubId = nuevoClubId;
    }
  }

  void clear() {
    nombreCompleto = null;
    dni = null;
    clubId = null;
  }
}
