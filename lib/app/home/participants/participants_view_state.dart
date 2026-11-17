/// Estado de la vista del listado de participantes que se conserva durante
/// la sesión: al entrar en la ficha de un participante, moverse por sus
/// menús o cambiar de sección y volver, el listado aparece tal y como se dejó.
class ParticipantsViewState {
  ParticipantsViewState._();

  /// false = tarjetas ("Vista general"), true = tabla ("Vista detalle").
  static bool detailView = false;

  /// 0 = Mis participantes, 1 = participantes de la entidad.
  static int selectedTab = 0;

  /// Muestra los participantes inactivos en lugar de los activos.
  static bool showInactive = false;

  // Vista detalle (tabla)
  static int sortColumn = 0;
  static bool sortAscending = true;
  static int page = 0;
  static int pageSize = 10;
}
