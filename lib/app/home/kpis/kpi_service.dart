import '../../models/userEnreda.dart';
import '../../models/initialReport.dart';
import '../../models/closureReport.dart';
import '../../models/followReport.dart';
import '../../models/derivationReport.dart';
import '../../models/education.dart';
import '../../models/ipilEntry.dart';
import '../../services/database.dart';
import '../../services/api_path.dart';
import '../../values/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Color, IconData, Icons;
import 'kpi_colors.dart';
import 'kpi_models.dart';

class ParticipantesKpiData {
  final int total;
  final List<StackedBarRow> porEstado;
  final List<StackedBarRow> porGenero;
  final List<StackedBarRow> porNacionalidad;
  final List<UserEnreda> users;
  final List<SituacionEmpleoRow> situacionEmpleoInicial;
  final List<SituacionEmpleoRow> situacionEmpleoActual;
  final int totalConInformeInicialCompleto;
  final List<FormatLevelItem> nivelesCine;
  final List<FormatLevelItem> nivelesEstudios;
  final int nivelesSinEspecificar;
  final List<DonutSegment> discapacidad;
  final List<RankedBarItem> condicionesSobrevenidas;
  final List<DonutSegment> situacionAdministrativa;
  final List<RankedBarItem> competenciasReconocidas;
  final List<CompetenciaArea> competenciasPorArea;
  final List<DonutSegment> competenciasPorCategoria;
  final List<NacionalidadItem> nacionalidades;
  final int nacionalidadSinEspecificar;
  final List<KeyIndicatorMetric> indicadoresClave;
  final List<FunnelStep> recorridoResultados;
  final List<RankedBarItem> resultadosPorSector;

  // Categoría de cada participante (por userId), para poder desagregar las
  // tarjetas por cualquier agrupación (género, nacionalidad…).
  /// Índice de [KpiService.situacionEmpleoCategories] en el informe inicial.
  final Map<String, int> situacionInicialPorUsuario;

  /// Índice de [KpiService.situacionEmpleoCategories] en el último informe.
  final Map<String, int> situacionActualPorUsuario;

  /// Índice del grupo CINE (posición en [nivelesCine]).
  final Map<String, int> nivelCinePorUsuario;

  /// Índice de la opción de nivel de estudios (posición en [nivelesEstudios]).
  final Map<String, int> nivelEstudiosPorUsuario;

  /// Índice del segmento de [discapacidad] (solo informe inicial completo).
  final Map<String, int> discapacidadPorUsuario;

  const ParticipantesKpiData({
    required this.total,
    required this.porEstado,
    required this.porGenero,
    required this.porNacionalidad,
    this.users = const [],
    this.situacionEmpleoInicial = const [],
    this.situacionEmpleoActual = const [],
    this.totalConInformeInicialCompleto = 0,
    this.nivelesCine = const [],
    this.nivelesEstudios = const [],
    this.nivelesSinEspecificar = 0,
    this.discapacidad = const [],
    this.condicionesSobrevenidas = const [],
    this.situacionAdministrativa = const [],
    this.competenciasReconocidas = const [],
    this.competenciasPorArea = const [],
    this.competenciasPorCategoria = const [],
    this.nacionalidades = const [],
    this.nacionalidadSinEspecificar = 0,
    this.indicadoresClave = const [],
    this.recorridoResultados = const [],
    this.resultadosPorSector = const [],
    this.situacionInicialPorUsuario = const {},
    this.situacionActualPorUsuario = const {},
    this.nivelCinePorUsuario = const {},
    this.nivelEstudiosPorUsuario = const {},
    this.discapacidadPorUsuario = const {},
  });

  static ParticipantesKpiData empty() {
    return const ParticipantesKpiData(
      total: 0,
      porEstado: [
        StackedBarRow(
            label: 'Activos',
            count: 0,
            percentage: 0,
            color: KpiColors.turquoise),
        StackedBarRow(
            label: 'En espera',
            count: 0,
            percentage: 0,
            color: KpiColors.lightTurquoise),
        StackedBarRow(
            label: 'Inactivos',
            count: 0,
            percentage: 0,
            color: KpiColors.borderLight),
      ],
      porGenero: [
        StackedBarRow(
            label: 'Mujeres', count: 0, percentage: 0, color: KpiColors.yellow),
        StackedBarRow(
            label: 'Hombres',
            count: 0,
            percentage: 0,
            color: KpiColors.primaryDark),
        StackedBarRow(
            label: 'No binario',
            count: 0,
            percentage: 0,
            color: KpiColors.slate),
      ],
      porNacionalidad: [
        StackedBarRow(
            label: 'Nacional',
            count: 0,
            percentage: 0,
            color: KpiColors.primaryDark),
        StackedBarRow(
            label: 'Extranjera',
            count: 0,
            percentage: 0,
            color: KpiColors.turquoise),
      ],
      situacionEmpleoInicial: [],
      situacionEmpleoActual: [],
      totalConInformeInicialCompleto: 0,
    );
  }
}

class RecursosKpiData {
  final int total;
  final int esteMes;
  final List<DonutSegment> porCategoria;
  final List<DateTime> fechas;

  /// Recursos por ámbito de actuación (`interests`). Un recurso puede tener
  /// varios, así que los porcentajes (sobre [conInteres]) no suman 100.
  final List<RankedBarItem> porInteres;

  /// Recursos con al menos un `interest` informado.
  final int conInteres;

  const RecursosKpiData({
    required this.total,
    required this.esteMes,
    required this.porCategoria,
    required this.fechas,
    this.porInteres = const [],
    this.conInteres = 0,
  });
}

class KpiService {
  final Database database;

  KpiService(this.database);

  /// Lee los documentos de una consulta. Si falla (p. ej. permisos), lo
  /// registra y devuelve una lista vacía para que el resto de KPIs se carguen.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getDocs(
    Query<Map<String, dynamic>> query,
    String label,
  ) async {
    try {
      return (await query.get()).docs;
    } catch (e) {
      print('KPIs: error leyendo "$label": $e');
      return [];
    }
  }

  /// Ejecuta un cálculo de KPIs; si falla, lo registra y devuelve [fallback]
  /// para no dejar vacía toda la página por un solo bloque.
  T _guard<T>(String label, T Function() compute, T fallback) {
    try {
      return compute();
    } catch (e, stack) {
      print('KPIs: error calculando "$label": $e\n$stack');
      return fallback;
    }
  }

  /// Obtiene todos los usuarios candidatos (Desempleados / participantes)
  Future<List<UserEnreda>> _fetchCandidateUsers({
    required String filterId,
    required String currentSocialEntityId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // Si el filtro es por entidad específica (id igual a la entidad actual)
    if (filterId == currentSocialEntityId || filterId == 'entity') {
      final snap = await firestore
          .collection(APIPath.users())
          .where('assignedEntityId', isEqualTo: currentSocialEntityId)
          .get();

      final List<UserEnreda> users = [];
      for (final doc in snap.docs) {
        try {
          final u = UserEnreda.fromMap(doc.data(), doc.id);
          if (u.role == 'Desempleado' ||
              (u.role == null && u.assignedEntityId != null)) {
            users.add(u);
          }
        } catch (_) {}
      }
      return users;
    }

    // Para Global o subsidios, cargamos participantes de la colección de usuarios
    // Filtramos los que tengan rol 'Desempleado' o sean participantes asignados
    final snap = await firestore.collection(APIPath.users()).get();

    final List<UserEnreda> users = [];
    for (final doc in snap.docs) {
      try {
        final u = UserEnreda.fromMap(doc.data(), doc.id);
        if (u.role == 'Desempleado' ||
            (u.role == null &&
                (u.assignedEntityId != null || u.socialEntityId != null))) {
          users.add(u);
        }
      } catch (_) {}
    }
    return users;
  }

  /// Carga los datos de participantes y calcula los KPIs según el filtro seleccionado
  Future<ParticipantesKpiData> loadParticipantesKpi({
    required String filterId,
    required String currentSocialEntityId,
  }) async {
    final users = await _fetchCandidateUsers(
      filterId: filterId,
      currentSocialEntityId: currentSocialEntityId,
    );

    if (users.isEmpty) {
      return ParticipantesKpiData.empty();
    }

    final firestore = FirebaseFirestore.instance;

    // 1. Cargar todos los informes iniciales, de cierre y de derivación directamente
    // en paralelo (son colecciones pequeñas y evita problemas con chunks de documentId o campos faltantes)
    final results = await Future.wait([
      _getDocs(
          firestore.collection(APIPath.initialReports()), 'initialReports'),
      _getDocs(
          firestore.collection(APIPath.closureReports()), 'closureReports'),
      _getDocs(firestore.collection(APIPath.derivationReports()),
          'derivationReports'),
      _getDocs(firestore.collection(APIPath.followReports()), 'followReports'),
      _getDocs(firestore.collection(APIPath.education()), 'education'),
      _getDocs(firestore.collection(APIPath.competencies()), 'competencies'),
      _getDocs(firestore.collection(APIPath.competenciesCategories()),
          'competenciesCategories'),
      _getDocs(firestore.collection(APIPath.competenciesSubCategories()),
          'competenciesSubCategories'),
    ]);

    final Map<String, InitialReport> initialReportsByUser = {};
    for (final doc in results[0]) {
      try {
        final report = InitialReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          final existing = initialReportsByUser[report.userId!];
          if (existing == null ||
              ((existing.subsidy == null || existing.subsidy!.isEmpty) &&
                  (report.subsidy != null && report.subsidy!.isNotEmpty))) {
            initialReportsByUser[report.userId!] = report;
          }
        }
        initialReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    final Map<String, ClosureReport> closureReportsByUser = {};
    for (final doc in results[1]) {
      try {
        final report = ClosureReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          closureReportsByUser[report.userId!] = report;
        }
        closureReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    final Map<String, DerivationReport> derivationReportsByUser = {};
    for (final doc in results[2]) {
      try {
        final report = DerivationReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          derivationReportsByUser[report.userId!] = report;
        }
        derivationReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    final Map<String, FollowReport> followReportsByUser = {};
    for (final doc in results[3]) {
      try {
        final report = FollowReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          followReportsByUser[report.userId!] = report;
        }
        followReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    final List<Education> educations = [];
    for (final doc in results[4]) {
      try {
        if (doc.data()['label'] == null) continue;
        educations.add(Education.fromMap(doc.data(), doc.id));
      } catch (_) {}
    }
    educations.sort((a, b) => a.order.compareTo(b.order));

    // 2. Filtrar lista de usuarios según el filterId seleccionado
    final List<UserEnreda> filteredUsers = users.where((u) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null &&
              initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      final sub = (initReport?.subsidy ?? '').trim();

      // Si el filtro es por subsidio
      if (filterId == '529760' || filterId.contains('529760')) {
        return sub.contains('529760') ||
            sub.toUpperCase().contains('MEDICOS DEL MUNDO');
      } else if (filterId == '529775' || filterId.contains('529775')) {
        return sub.contains('529775') || sub.toUpperCase().contains('SICFCH');
      } else if (filterId == 'seimlab' || filterId.contains('0080')) {
        return sub.toUpperCase().contains('SEIMLAB') || sub.contains('0080');
      } else if (filterId == 'global') {
        return true;
      } else {
        // Por entidad (currentSocialEntityId)
        return (u.assignedEntityId == currentSocialEntityId ||
            u.socialEntityId == currentSocialEntityId);
      }
    }).toList();

    final int total = filteredUsers.length;
    if (total == 0) {
      return ParticipantesKpiData.empty();
    }

    // 3. Contadores
    int countActivos = 0;
    int countEnEspera = 0;
    int countInactivos = 0;

    int countMujeres = 0;
    int countHombres = 0;
    int countNoBinario = 0;

    int countNacional = 0;
    int countExtranjera = 0;

    for (final u in filteredUsers) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null &&
              initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      final closureReport = (u.closureReportId != null &&
              closureReportsByUser.containsKey(u.closureReportId))
          ? closureReportsByUser[u.closureReportId]
          : (closureReportsByUser[uId] ?? closureReportsByUser[u.email]);
      final derivationReport = (u.derivationReportId != null &&
              derivationReportsByUser.containsKey(u.derivationReportId))
          ? derivationReportsByUser[u.derivationReportId]
          : (derivationReportsByUser[uId] ?? derivationReportsByUser[u.email]);

      final bool isInitFinished = initReport != null &&
          (initReport.finished == true || initReport.completedDate != null);
      final bool isClosureFinished = closureReport != null &&
          (closureReport.finished == true ||
              closureReport.completedDate != null);
      final bool isDerivationFinished = derivationReport != null &&
          (derivationReport.finished == true ||
              derivationReport.completedDate != null);

      // Estado:
      // "Inactivos": informe de cierre completado y sin informe de reapertura
      // (si tiene socialItineraryHistory, comprobamos si tiene un nuevo ciclo activo reabierto)
      final bool hasReopening =
          u.initialReportId != null && u.socialItineraryHistory.isNotEmpty;

      if (isClosureFinished && !hasReopening) {
        countInactivos++;
      } else if (isInitFinished &&
          !isClosureFinished &&
          !isDerivationFinished) {
        // "Activos": informe inicial completo pero sin informe de cierre o derivación
        countActivos++;
      } else {
        // "En espera": sin informe de cierre completado (y sin cumplir condición de activo o inactivo)
        countEnEspera++;
      }

      // Género:
      final genderStr = (u.gender ?? '').trim().toLowerCase();
      if (genderStr == 'mujer' || genderStr == 'femenino' || genderStr == 'f') {
        countMujeres++;
      } else if (genderStr == 'hombre' ||
          genderStr == 'masculino' ||
          genderStr == 'm') {
        countHombres++;
      } else {
        countNoBinario++;
      }

      // Nacionalidad:
      // "Nacional" si es España, "Extranjera" en caso contrario
      final natStr = (u.nationality ?? '').trim().toLowerCase();
      if (natStr == 'españa' ||
          natStr == 'espana' ||
          natStr == 'española' ||
          natStr == 'espanola') {
        countNacional++;
      } else {
        countExtranjera++;
      }
    }

    double pct(int count) => total > 0 ? ((count / total) * 100) : 0.0;

    // Situación inicial: participantes con informe inicial completado
    String? inicialOf(UserEnreda u) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null &&
              initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      final bool isInitFinished = initReport != null &&
          _isFilled(initReport.finished, initReport.completedDate);
      if (!isInitFinished) return null;
      return (initReport.laborSituation ?? '').trim();
    }

    // Situación actual: participantes con informe de seguimiento o de cierre;
    // se toma la situación laboral del último informe rellenado (cierre > seguimiento,
    // y en caso de reapertura, el último informe del ciclo más reciente)
    String? actualOf(UserEnreda u) => _resolveCurrentLaborSituation(
          user: u,
          initialReports: initialReportsByUser,
          followReports: followReportsByUser,
          closureReports: closureReportsByUser,
        );

    final situacionInicial = _calculateSituacionEmpleo(
        users: filteredUsers, laborSituationOf: inicialOf);
    final situacionActual = _calculateSituacionEmpleo(
        users: filteredUsers, laborSituationOf: actualOf);

    final Map<String, int> situacionInicialPorUsuario = {};
    final Map<String, int> situacionActualPorUsuario = {};
    for (final u in filteredUsers) {
      final uId = u.userId;
      if (uId == null) continue;
      final inicial = inicialOf(u);
      if (inicial != null)
        situacionInicialPorUsuario[uId] = situacionEmpleoCategory(inicial);
      final actual = actualOf(u);
      if (actual != null)
        situacionActualPorUsuario[uId] = situacionEmpleoCategory(actual);
    }

    int totalConInformeInicialCompleto = 0;
    final List<(UserEnreda, InitialReport)> conInformeInicialCompleto = [];
    for (final u in filteredUsers) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null &&
              initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      if (initReport != null &&
          (initReport.finished == true || initReport.completedDate != null)) {
        totalConInformeInicialCompleto++;
        conInformeInicialCompleto.add((u, initReport));
      }
    }

    final categorias = _guard(
      'categorías especiales',
      () => _calculateCategoriasEspeciales(conInformeInicialCompleto),
      (
        discapacidad: <DonutSegment>[],
        condiciones: <RankedBarItem>[],
        situacionAdministrativa: <DonutSegment>[],
        discapacidadPorUsuario: <String, int>{},
      ),
    );

    final nacionalidades = _guard(
      'nacionalidades',
      () => _calculateNacionalidades(filteredUsers),
      (items: <NacionalidadItem>[], sinEspecificar: 0),
    );

    ({
      List<KeyIndicatorMetric> indicadores,
      List<FunnelStep> recorrido,
      List<RankedBarItem> porSector
    }) resultados;
    try {
      resultados = await _loadIndicadoresClave(
        users: filteredUsers,
        closureReportDocs: results[1],
      );
    } catch (e, stack) {
      print('KPIs: error calculando "indicadores de resultados": $e\n$stack');
      resultados = (
        indicadores: <KeyIndicatorMetric>[],
        recorrido: <FunnelStep>[],
        porSector: <RankedBarItem>[]
      );
    }

    final competencias = _guard(
      'competencias',
      () => _calculateCompetencias(
        users: filteredUsers,
        competencyDocs: results[5],
        categoryDocs: results[6],
        subCategoryDocs: results[7],
      ),
      (
        reconocidas: <RankedBarItem>[],
        porArea: <CompetenciaArea>[],
        porCategoria: <DonutSegment>[]
      ),
    );

    final niveles = _guard(
      'niveles formativos',
      () => _calculateNivelesFormativos(
        users: filteredUsers,
        educations: educations,
      ),
      (
        cine: <FormatLevelItem>[],
        estudios: <FormatLevelItem>[],
        sinEspecificar: 0,
        cinePorUsuario: <String, int>{},
        estudiosPorUsuario: <String, int>{},
      ),
    );

    return ParticipantesKpiData(
      total: total,
      porEstado: [
        StackedBarRow(
          label: 'Activos',
          count: countActivos,
          percentage: pct(countActivos),
          color: KpiColors.turquoise,
        ),
        StackedBarRow(
          label: 'En espera',
          count: countEnEspera,
          percentage: pct(countEnEspera),
          color: KpiColors.lightTurquoise,
        ),
        StackedBarRow(
          label: 'Inactivos',
          count: countInactivos,
          percentage: pct(countInactivos),
          color: KpiColors.borderLight,
        ),
      ],
      porGenero: [
        StackedBarRow(
          label: 'Mujeres',
          count: countMujeres,
          percentage: pct(countMujeres),
          color: KpiColors.yellow,
        ),
        StackedBarRow(
          label: 'Hombres',
          count: countHombres,
          percentage: pct(countHombres),
          color: KpiColors.primaryDark,
        ),
        StackedBarRow(
          label: 'No binario',
          count: countNoBinario,
          percentage: pct(countNoBinario),
          color: KpiColors.slate,
        ),
      ],
      porNacionalidad: [
        StackedBarRow(
          label: 'Nacional',
          count: countNacional,
          percentage: pct(countNacional),
          color: KpiColors.primaryDark,
        ),
        StackedBarRow(
          label: 'Extranjera',
          count: countExtranjera,
          percentage: pct(countExtranjera),
          color: KpiColors.turquoise,
        ),
      ],
      users: filteredUsers,
      situacionEmpleoInicial: situacionInicial,
      situacionEmpleoActual: situacionActual,
      totalConInformeInicialCompleto: totalConInformeInicialCompleto,
      nivelesCine: niveles.cine,
      nivelesEstudios: niveles.estudios,
      nivelesSinEspecificar: niveles.sinEspecificar,
      discapacidad: categorias.discapacidad,
      condicionesSobrevenidas: categorias.condiciones,
      situacionAdministrativa: categorias.situacionAdministrativa,
      competenciasReconocidas: competencias.reconocidas,
      competenciasPorArea: competencias.porArea,
      competenciasPorCategoria: competencias.porCategoria,
      nacionalidades: nacionalidades.items,
      nacionalidadSinEspecificar: nacionalidades.sinEspecificar,
      indicadoresClave: resultados.indicadores,
      recorridoResultados: resultados.recorrido,
      resultadosPorSector: resultados.porSector,
      situacionInicialPorUsuario: situacionInicialPorUsuario,
      situacionActualPorUsuario: situacionActualPorUsuario,
      nivelCinePorUsuario: niveles.cinePorUsuario,
      nivelEstudiosPorUsuario: niveles.estudiosPorUsuario,
      discapacidadPorUsuario: categorias.discapacidadPorUsuario,
    );
  }

  bool _isFilled(bool? finished, DateTime? completedDate) =>
      finished == true || completedDate != null;

  /// Devuelve la situación laboral "actual" del participante, o `null` si no
  /// tiene ningún informe de seguimiento ni de cierre rellenado (no computa).
  ///
  /// Se recorren los ciclos del itinerario en orden cronológico
  /// (ciclos archivados en `socialItineraryHistory` + ciclo vigente) y, dentro
  /// de cada ciclo, los informes en orden: reapertura → seguimiento → cierre.
  /// Se queda con la situación laboral del último informe rellenado, de forma
  /// que si hay seguimiento y cierre prevalece el cierre, y si hubo reapertura
  /// prevalecen los informes del nuevo ciclo.
  String? _resolveCurrentLaborSituation({
    required UserEnreda user,
    required Map<String, InitialReport> initialReports,
    required Map<String, FollowReport> followReports,
    required Map<String, ClosureReport> closureReports,
  }) {
    bool hasFollowOrClosure = false;
    String? latest;

    void consider(String? laborSituation) {
      final ls = (laborSituation ?? '').trim();
      if (ls.isNotEmpty) latest = ls;
    }

    void processCycle({
      required String? reopeningReportId,
      required FollowReport? follow,
      required ClosureReport? closure,
    }) {
      // Informe de reapertura (solo existe en ciclos posteriores al primero)
      if (reopeningReportId != null) {
        final reopening = initialReports[reopeningReportId];
        if (reopening != null &&
            _isFilled(reopening.finished, reopening.completedDate)) {
          consider(reopening.laborSituation);
        }
      }
      if (follow != null && _isFilled(follow.finished, follow.completedDate)) {
        hasFollowOrClosure = true;
        consider(follow.laborSituation);
      }
      if (closure != null &&
          _isFilled(closure.finished, closure.completedDate)) {
        hasFollowOrClosure = true;
        consider(closure.laborSituation);
      }
    }

    // 1. Ciclos archivados (se añaden en orden cronológico con arrayUnion)
    final history = user.socialItineraryHistory;
    for (int i = 0; i < history.length; i++) {
      final cycle = history[i];
      processCycle(
        reopeningReportId: i > 0 ? cycle.initialReportId : null,
        follow: cycle.followReportId != null
            ? followReports[cycle.followReportId]
            : null,
        closure: cycle.closureReportId != null
            ? closureReports[cycle.closureReportId]
            : null,
      );
    }

    // 2. Ciclo vigente. Si no hay histórico (sin reaperturas) se permite el
    // fallback por userId/email para usuarios antiguos sin punteros.
    final uId = user.userId ?? '';
    final bool allowLegacyLookup = history.isEmpty;
    final FollowReport? currentFollow = user.followReportId != null
        ? followReports[user.followReportId]
        : (allowLegacyLookup
            ? (followReports[uId] ?? followReports[user.email])
            : null);
    final ClosureReport? currentClosure = user.closureReportId != null
        ? closureReports[user.closureReportId]
        : (allowLegacyLookup
            ? (closureReports[uId] ?? closureReports[user.email])
            : null);

    processCycle(
      reopeningReportId: history.isNotEmpty ? user.initialReportId : null,
      follow: currentFollow,
      closure: currentClosure,
    );

    if (!hasFollowOrClosure) return null;
    return latest ?? '';
  }

  /// Categorías de situación de empleo, en el orden en que se indexan en
  /// [ParticipantesKpiData.situacionInicialPorUsuario] / `situacionActualPorUsuario`.
  static const List<String> situacionEmpleoCategories = [
    'corta',
    'larga',
    'otroDesempleo',
    'inactiva',
    'empleada',
    'sinEspecificar',
  ];

  /// Índice en [situacionEmpleoCategories] de una situación laboral, con el
  /// mismo criterio que [_calculateSituacionEmpleo].
  static int situacionEmpleoCategory(String laborSituation) {
    final ls = laborSituation.toLowerCase();
    if (ls.contains('corta')) return 0;
    if (ls.contains('larga')) return 1;
    if (ls.contains('desemplead')) return 2;
    if (ls.contains('inactiv')) return 3;
    if (ls.contains('ocupada') || ls.contains('emplead')) return 4;
    return 5;
  }

  /// Calcula el desglose de situación de empleo por género.
  /// [laborSituationOf] devuelve la situación laboral a computar para cada
  /// participante, o `null` si el participante no debe computarse.
  List<SituacionEmpleoRow> _calculateSituacionEmpleo({
    required List<UserEnreda> users,
    required String? Function(UserEnreda u) laborSituationOf,
  }) {
    int cortaM = 0, cortaH = 0, cortaNB = 0;
    int largaM = 0, largaH = 0, largaNB = 0;
    int otherDesempM = 0, otherDesempH = 0, otherDesempNB = 0;
    int inactM = 0, inactH = 0, inactNB = 0;
    int empM = 0, empH = 0, empNB = 0;
    int unspecM = 0, unspecH = 0, unspecNB = 0;

    for (final u in users) {
      final String? laborSituation = laborSituationOf(u);
      if (laborSituation == null) continue;

      final gStr = (u.gender ?? '').trim().toLowerCase();
      final bool isMujer =
          (gStr == 'mujer' || gStr == 'femenino' || gStr == 'f');
      final bool isHombre =
          (gStr == 'hombre' || gStr == 'masculino' || gStr == 'm');

      final ls = laborSituation.toLowerCase();

      if (ls.contains('corta')) {
        if (isMujer)
          cortaM++;
        else if (isHombre)
          cortaH++;
        else
          cortaNB++;
      } else if (ls.contains('larga')) {
        if (isMujer)
          largaM++;
        else if (isHombre)
          largaH++;
        else
          largaNB++;
      } else if (ls.contains('desemplead')) {
        if (isMujer)
          otherDesempM++;
        else if (isHombre)
          otherDesempH++;
        else
          otherDesempNB++;
      } else if (ls.contains('inactiv')) {
        if (isMujer)
          inactM++;
        else if (isHombre)
          inactH++;
        else
          inactNB++;
      } else if (ls.contains('ocupada') || ls.contains('emplead')) {
        if (isMujer)
          empM++;
        else if (isHombre)
          empH++;
        else
          empNB++;
      } else {
        if (isMujer)
          unspecM++;
        else if (isHombre)
          unspecH++;
        else
          unspecNB++;
      }
    }

    final desempM = cortaM + largaM + otherDesempM;
    final desempH = cortaH + largaH + otherDesempH;
    final desempNB = cortaNB + largaNB + otherDesempNB;
    final desempTotal = desempM + desempH + desempNB;

    final cortaTotal = cortaM + cortaH + cortaNB;
    final largaTotal = largaM + largaH + largaNB;
    final inactTotal = inactM + inactH + inactNB;
    final empTotal = empM + empH + empNB;
    final unspecTotal = unspecM + unspecH + unspecNB;

    final totalM = desempM + inactM + empM + unspecM;
    final totalH = desempH + inactH + empH + unspecH;
    final totalNB = desempNB + inactNB + empNB + unspecNB;
    final grandTotal = totalM + totalH + totalNB;

    final rows = <SituacionEmpleoRow>[
      SituacionEmpleoRow(
        label: 'Desempleadas/os',
        mujeres: desempM,
        hombres: desempH,
        noBinario: desempNB,
        total: desempTotal,
      ),
      SituacionEmpleoRow(
        label: 'Corta duración',
        mujeres: cortaM,
        hombres: cortaH,
        noBinario: cortaNB,
        total: cortaTotal,
        isIndented: true,
      ),
      SituacionEmpleoRow(
        label: 'Larga duración',
        mujeres: largaM,
        hombres: largaH,
        noBinario: largaNB,
        total: largaTotal,
        isIndented: true,
      ),
      SituacionEmpleoRow(
        label: 'Inactivas/os',
        mujeres: inactM,
        hombres: inactH,
        noBinario: inactNB,
        total: inactTotal,
      ),
      SituacionEmpleoRow(
        label: 'Empleadas/os',
        mujeres: empM,
        hombres: empH,
        noBinario: empNB,
        total: empTotal,
      ),
    ];

    if (unspecTotal > 0) {
      rows.add(
        SituacionEmpleoRow(
          label: 'Sin especificar',
          mujeres: unspecM,
          hombres: unspecH,
          noBinario: unspecNB,
          total: unspecTotal,
        ),
      );
    }

    rows.add(
      SituacionEmpleoRow(
        label: 'Total',
        mujeres: totalM,
        hombres: totalH,
        noBinario: totalNB,
        total: grandTotal,
        isTotal: true,
      ),
    );

    return rows;
  }

  static const List<String> _cineLabels = [
    'CINE 0 – 2',
    'CINE 3 – 4',
    'CINE 5 – 8'
  ];
  static const List<String> _cineTitles = [
    'Educación básica o sin estudios',
    'Educación secundaria postobligatoria',
    'Educación superior',
  ];
  static const List<String> _cineDescriptions = [
    'Sin formación, Educación Primaria, ESO, Competencias clave y Certificados profesionales (niveles 1 – 3)',
    'FP básica, FP de grado medio y Bachillerato',
    'FP de grado superior, formación universitaria y postgrado',
  ];

  String _normalizeText(String raw) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    final buffer = StringBuffer();
    for (final ch in raw.trim().toLowerCase().split('')) {
      final idx = from.indexOf(ch);
      buffer.write(idx >= 0 ? to[idx] : ch);
    }
    return buffer.toString();
  }

  /// Devuelve el grupo CINE (0: CINE 0–2, 1: CINE 3–4, 2: CINE 5–8) de una
  /// opción de nivel educativo, o `null` si no se reconoce.
  int? _cineGroupOf(String label) {
    final l = _normalizeText(label);
    if (l.contains('no tengo formaci') ||
        l.contains('sin formaci') ||
        l.contains('sin estudios') ||
        l.contains('primari') ||
        RegExp(r'\beso\b').hasMatch(l) ||
        l.contains('secundaria obligatoria') ||
        l.contains('competencias clave') ||
        l.contains('certificado')) {
      return 0;
    }
    if (l.contains('fp basica') ||
        l.contains('profesional basica') ||
        l.contains('grado medio') ||
        l.contains('bachiller')) {
      return 1;
    }
    if (l.contains('postgrado') ||
        l.contains('posgrado') ||
        l.contains('master') ||
        l.contains('doctor') ||
        l.contains('universit') ||
        l.contains('grado superior') ||
        l.contains('licenciatura') ||
        l.contains('diplomatura') ||
        l.contains('grado')) {
      return 2;
    }
    return null;
  }

  /// Calcula los niveles formativos (agrupados por CINE y por opción del
  /// desplegable de nivel educativo del alta) desagregados por género.
  ({
    List<FormatLevelItem> cine,
    List<FormatLevelItem> estudios,
    int sinEspecificar,
    Map<String, int> cinePorUsuario,
    Map<String, int> estudiosPorUsuario,
  }) _calculateNivelesFormativos({
    required List<UserEnreda> users,
    required List<Education> educations,
  }) {
    // Opciones del alta: las de order 1 – 10 ("No tengo formación" … "Postgrado")
    final List<Education> options =
        educations.where((e) => e.order >= 1 && e.order <= 10).toList();

    final Map<String, Education> byId = {
      for (final e in options)
        if (e.educationId != null) e.educationId!: e,
    };
    final Map<String, Education> byLabel = {
      for (final e in options) _normalizeText(e.label): e,
    };

    final optM = List<int>.filled(options.length, 0);
    final optH = List<int>.filled(options.length, 0);
    final optNB = List<int>.filled(options.length, 0);
    final cineM = List<int>.filled(3, 0);
    final cineH = List<int>.filled(3, 0);
    final cineNB = List<int>.filled(3, 0);
    int sinEspecificar = 0;
    final Map<String, int> cinePorUsuario = {};
    final Map<String, int> estudiosPorUsuario = {};

    for (final u in users) {
      Education? edu = (u.educationId != null && u.educationId!.isNotEmpty)
          ? byId[u.educationId]
          : null;
      edu ??= byLabel[_normalizeText(u.educationName ?? '')];
      if (edu == null) {
        sinEspecificar++;
        continue;
      }

      final gStr = (u.gender ?? '').trim().toLowerCase();
      final bool isMujer =
          (gStr == 'mujer' || gStr == 'femenino' || gStr == 'f');
      final bool isHombre =
          (gStr == 'hombre' || gStr == 'masculino' || gStr == 'm');

      final optIdx = options.indexOf(edu);
      if (isMujer)
        optM[optIdx]++;
      else if (isHombre)
        optH[optIdx]++;
      else
        optNB[optIdx]++;
      if (u.userId != null) estudiosPorUsuario[u.userId!] = optIdx;

      final cineIdx = _cineGroupOf(edu.label);
      if (cineIdx == null) continue;
      if (u.userId != null) cinePorUsuario[u.userId!] = cineIdx;
      if (isMujer)
        cineM[cineIdx]++;
      else if (isHombre)
        cineH[cineIdx]++;
      else
        cineNB[cineIdx]++;
    }

    final int totalCine = [
      for (int i = 0; i < 3; i++) cineM[i] + cineH[i] + cineNB[i]
    ].fold(0, (a, b) => a + b);
    final int totalEstudios = [
      for (int i = 0; i < options.length; i++) optM[i] + optH[i] + optNB[i]
    ].fold(0, (a, b) => a + b);

    String genderDetail(int m, int h, int nb) =>
        '$m ${m == 1 ? 'mujer' : 'mujeres'} · $h ${h == 1 ? 'hombre' : 'hombres'} · $nb no binario';

    final cine = <FormatLevelItem>[
      for (int i = 0; i < 3; i++)
        FormatLevelItem(
          cineLabel: _cineLabels[i],
          title: _cineTitles[i],
          total: cineM[i] + cineH[i] + cineNB[i],
          percentage: totalCine > 0
              ? (cineM[i] + cineH[i] + cineNB[i]) / totalCine * 100
              : 0.0,
          mujeres: cineM[i],
          hombres: cineH[i],
          noBinario: cineNB[i],
          description:
              '${_cineDescriptions[i]}. ${genderDetail(cineM[i], cineH[i], cineNB[i])}',
        ),
    ];

    final estudios = <FormatLevelItem>[
      for (int i = 0; i < options.length; i++)
        FormatLevelItem(
          cineLabel: _cineGroupOf(options[i].label) != null
              ? _cineLabels[_cineGroupOf(options[i].label)!]
              : '',
          title: options[i].label,
          total: optM[i] + optH[i] + optNB[i],
          percentage: totalEstudios > 0
              ? (optM[i] + optH[i] + optNB[i]) / totalEstudios * 100
              : 0.0,
          mujeres: optM[i],
          hombres: optH[i],
          noBinario: optNB[i],
          description: genderDetail(optM[i], optH[i], optNB[i]),
        ),
    ];

    return (
      cine: cine,
      estudios: estudios,
      sinEspecificar: sinEspecificar,
      cinePorUsuario: cinePorUsuario,
      estudiosPorUsuario: estudiosPorUsuario,
    );
  }

  /// Calcula discapacidad, condiciones sobrevenidas y situación administrativa
  /// a partir del informe inicial. Solo computan participantes con el informe
  /// inicial completo.
  ({
    List<DonutSegment> discapacidad,
    List<RankedBarItem> condiciones,
    List<DonutSegment> situacionAdministrativa,
    Map<String, int> discapacidadPorUsuario,
  }) _calculateCategoriasEspeciales(List<(UserEnreda, InitialReport)> entries) {
    final int total = entries.length;
    double pct(int count) => total > 0 ? ((count / total) * 100) : 0.0;

    // Discapacidad (estado del certificado: En trámite / Concedida / No aplica)
    int reconocida = 0, enTramiteDisc = 0, sinDiscapacidad = 0;
    final Map<String, int> discapacidadPorUsuario = {};

    // Condiciones sobrevenidas (sección 8 del informe inicial, multiselección)
    final Map<String, int> condicionesCount = {
      for (final option in StringConst.OPTIONS_SECTION_12) option: 0,
    };

    // Situación administrativa (Nacional + estado del informe inicial)
    int nacional = 0,
        concedida = 0,
        enTramiteAdmin = 0,
        sinTramitar = 0,
        sinEspecificar = 0;

    for (final (u, report) in entries) {
      final disability = _normalizeText(report.disabilityState ?? '');
      final int disabilityIdx;
      if (disability == 'concedida') {
        reconocida++;
        disabilityIdx = 0;
      } else if (disability == 'en tramite') {
        enTramiteDisc++;
        disabilityIdx = 1;
      } else {
        sinDiscapacidad++;
        disabilityIdx = 2;
      }
      if (u.userId != null) discapacidadPorUsuario[u.userId!] = disabilityIdx;

      for (final option
          in (report.vulnerabilityOptions ?? const <String>[]).toSet()) {
        if (condicionesCount.containsKey(option)) {
          condicionesCount[option] = condicionesCount[option]! + 1;
        }
      }

      final natStr = (u.nationality ?? '').trim().toLowerCase();
      final adminState = _normalizeText(report.adminState ?? '');
      if (natStr == 'españa' ||
          natStr == 'espana' ||
          natStr == 'española' ||
          natStr == 'espanola') {
        nacional++;
      } else if (adminState == 'concedida') {
        concedida++;
      } else if (adminState == 'en tramite') {
        enTramiteAdmin++;
      } else if (adminState == 'sin tramitar') {
        sinTramitar++;
      } else {
        sinEspecificar++;
      }
    }

    final discapacidad = <DonutSegment>[
      DonutSegment(
          label: 'Reconocida',
          count: reconocida,
          percentage: pct(reconocida),
          color: KpiColors.turquoise),
      DonutSegment(
          label: 'En trámite',
          count: enTramiteDisc,
          percentage: pct(enTramiteDisc),
          color: KpiColors.lightTurquoise),
      DonutSegment(
          label: 'Sin discapacidad declarada',
          count: sinDiscapacidad,
          percentage: pct(sinDiscapacidad),
          color: KpiColors.borderLight),
    ];

    final condiciones = condicionesCount.entries
        .map((e) => RankedBarItem(
            label: e.key, count: e.value, percentage: pct(e.value)))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final situacionAdministrativa = <DonutSegment>[
      DonutSegment(
          label: 'Nacional',
          count: nacional,
          percentage: pct(nacional),
          color: KpiColors.primaryDark),
      DonutSegment(
          label: 'Concedida',
          count: concedida,
          percentage: pct(concedida),
          color: KpiColors.turquoise),
      DonutSegment(
          label: 'En trámite',
          count: enTramiteAdmin,
          percentage: pct(enTramiteAdmin),
          color: KpiColors.lightTurquoise),
      DonutSegment(
          label: 'Sin tramitar',
          count: sinTramitar,
          percentage: pct(sinTramitar),
          color: KpiColors.yellow),
      DonutSegment(
          label: 'Sin especificar',
          count: sinEspecificar,
          percentage: pct(sinEspecificar),
          color: KpiColors.borderLight),
    ];

    return (
      discapacidad: discapacidad,
      condiciones: condiciones,
      situacionAdministrativa: situacionAdministrativa,
      discapacidadPorUsuario: discapacidadPorUsuario,
    );
  }

  static const List<Color> _competencyCategoryColors = [
    KpiColors.primaryDark,
    KpiColors.turquoise,
    KpiColors.yellow,
  ];

  /// Calcula las competencias reconocidas por los participantes. Una competencia
  /// cuenta como reconocida si su id aparece en el map `competencies` del
  /// usuario, sea cual sea el valor asociado.
  ({
    List<RankedBarItem> reconocidas,
    List<CompetenciaArea> porArea,
    List<DonutSegment> porCategoria
  }) _calculateCompetencias({
    required List<UserEnreda> users,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> competencyDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> subCategoryDocs,
  }) {
    // Categorías (las 3 grandes), ordenadas por `order`
    final categories = <({String id, String name, int order})>[];
    for (final doc in categoryDocs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      categories.add((
        id: (data['competencyCategoryId'] ?? doc.id).toString(),
        name: name,
        order: data['order'] is int ? data['order'] as int : 0,
      ));
    }
    categories.sort((a, b) => a.order.compareTo(b.order));
    final Map<String, int> categoryIndexById = {
      for (int i = 0; i < categories.length; i++) categories[i].id: i,
    };
    Color colorOf(int? categoryIdx) => categoryIdx != null
        ? _competencyCategoryColors[
            categoryIdx % _competencyCategoryColors.length]
        : KpiColors.slate;

    // Subcategorías (áreas de competencia), ordenadas por categoría y `order`
    final subCategories =
        <({String id, String name, int order, int? categoryIdx})>[];
    for (final doc in subCategoryDocs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      subCategories.add((
        id: (data['competencySubCategoryId'] ?? doc.id).toString(),
        name: name,
        order: data['order'] is int ? data['order'] as int : 0,
        categoryIdx:
            categoryIndexById[(data['competencyCategoryId'] ?? '').toString()],
      ));
    }
    subCategories.sort((a, b) {
      final ca = a.categoryIdx ?? categories.length;
      final cb = b.categoryIdx ?? categories.length;
      return ca != cb ? ca.compareTo(cb) : a.order.compareTo(b.order);
    });
    final Map<String, int> subCategoryIndexById = {
      for (int i = 0; i < subCategories.length; i++) subCategories[i].id: i,
    };

    // Competencias: se indexan por el campo `id` y por el id del documento
    final competencies =
        <({String name, int? categoryIdx, int? subCategoryIdx})>[];
    final Map<String, int> competencyIndexByKey = {};
    for (final doc in competencyDocs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final idx = competencies.length;
      competencies.add((
        name: name,
        categoryIdx:
            categoryIndexById[(data['competencyCategoryId'] ?? '').toString()],
        subCategoryIdx: subCategoryIndexById[
            (data['competencySubCategoryId'] ?? '').toString()],
      ));
      competencyIndexByKey[doc.id] = idx;
      if (data['id'] != null) competencyIndexByKey[data['id'].toString()] = idx;
    }

    final counts = List<int>.filled(competencies.length, 0);
    for (final u in users) {
      final recognized = <int>{};
      for (final key in u.competencies.keys) {
        final idx = competencyIndexByKey[key];
        if (idx != null) recognized.add(idx);
      }
      for (final idx in recognized) {
        counts[idx]++;
      }
    }

    final int totalUsers = users.length;

    // Top 10 competencias por número de participantes que la tienen reconocida
    final ranked = [for (int i = 0; i < competencies.length; i++) i]
        .where((i) => counts[i] > 0)
        .toList()
      ..sort((a, b) => counts[b].compareTo(counts[a]));
    final reconocidas = ranked.take(10).map((i) {
      final c = competencies[i];
      return RankedBarItem(
        label: c.name,
        category:
            c.categoryIdx != null ? categories[c.categoryIdx!].name : null,
        count: counts[i],
        percentage: totalUsers > 0 ? counts[i] / totalUsers * 100 : 0.0,
        color: colorOf(c.categoryIdx),
      );
    }).toList();

    // Reparto de reconocimientos por área (subcategoría). Se muestran todas
    // las áreas, aunque no tengan reconocimientos.
    final subCounts = List<int>.filled(subCategories.length, 0);
    for (int i = 0; i < competencies.length; i++) {
      final si = competencies[i].subCategoryIdx;
      if (si != null) subCounts[si] += counts[i];
    }
    final int totalAreaRecognitions = subCounts.fold(0, (a, b) => a + b);
    double areaPct(int count) =>
        totalAreaRecognitions > 0 ? count / totalAreaRecognitions * 100 : 0.0;

    final porArea = [
      for (int si = 0; si < subCategories.length; si++)
        CompetenciaArea(
          name: subCategories[si].name,
          percentage: areaPct(subCounts[si]),
          color: colorOf(subCategories[si].categoryIdx),
          group: subCategories[si].categoryIdx != null
              ? categories[subCategories[si].categoryIdx!].name
              : 'Sin categoría',
        ),
    ];

    final porCategoria = [
      for (int ci = 0; ci < categories.length; ci++)
        () {
          int count = 0;
          for (int si = 0; si < subCategories.length; si++) {
            if (subCategories[si].categoryIdx == ci) count += subCounts[si];
          }
          return DonutSegment(
            label: categories[ci].name,
            count: count,
            percentage: areaPct(count),
            color: colorOf(ci),
          );
        }(),
    ];

    return (
      reconocidas: reconocidas,
      porArea: porArea,
      porCategoria: porCategoria
    );
  }

  /// Agrupa a los participantes por nacionalidad (sin distinguir mayúsculas ni
  /// tildes), desagregados por género y ordenados de más a menos participantes.
  ({List<NacionalidadItem> items, int sinEspecificar}) _calculateNacionalidades(
      List<UserEnreda> users) {
    final Map<String, String> labels = {};
    final Map<String, List<int>> counts = {};
    int sinEspecificar = 0;

    for (final u in users) {
      final raw = (u.nationality ?? '').trim();
      if (raw.isEmpty) {
        sinEspecificar++;
        continue;
      }
      final key = _normalizeText(raw);
      labels.putIfAbsent(key, () => raw);
      final c = counts.putIfAbsent(key, () => [0, 0, 0]);

      final gStr = (u.gender ?? '').trim().toLowerCase();
      if (gStr == 'mujer' || gStr == 'femenino' || gStr == 'f') {
        c[0]++;
      } else if (gStr == 'hombre' || gStr == 'masculino' || gStr == 'm') {
        c[1]++;
      } else {
        c[2]++;
      }
    }

    final items = counts.entries
        .map((e) => NacionalidadItem(
              label: labels[e.key]!,
              mujeres: e.value[0],
              hombres: e.value[1],
              noBinario: e.value[2],
            ))
        .toList()
      ..sort((a, b) => b.total != a.total
          ? b.total.compareTo(a.total)
          : a.label.compareTo(b.label));

    return (items: items, sinEspecificar: sinEspecificar);
  }

  /// Calcula los indicadores clave de resultados y el recorrido de resultados.
  /// Cada indicador cuenta participantes distintos. En los indicadores clave
  /// el valor principal es el del año en curso y se compara con el año
  /// anterior (salvo el CV, que no tiene fecha); el recorrido es acumulado.
  Future<
      ({
        List<KeyIndicatorMetric> indicadores,
        List<FunnelStep> recorrido,
        List<RankedBarItem> porSector
      })> _loadIndicadoresClave({
    required List<UserEnreda> users,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
        closureReportDocs,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final userIds = {
      for (final u in users)
        if (u.userId != null && u.userId!.isNotEmpty) u.userId!,
    };

    // Opciones de los checklists del IPIL: se buscan las de
    // "Inscripción formación" y "Certificación formación" por su label.
    final optionCollections = [
      APIPath.ipilReinforcement(),
      APIPath.ipilContextualization(),
      APIPath.ipilConnectionTerritory(),
      APIPath.ipilInterviews(),
      APIPath.ipilIntermediations(),
      APIPath.ipilObtainingEmployment(),
      APIPath.ipilImprovingEmployment(),
      APIPath.ipilPostWorkSupport(),
      APIPath.ipilCoordination(),
      APIPath.ipilLegal(),
      APIPath.ipilEconomicBag(),
      APIPath.ipilSpecificSkills(),
      APIPath.ipilSoftSkills(),
      APIPath.ipilDigitalSkills(),
      APIPath.ipilLaborSkills(),
      APIPath.ipilResults(),
    ];
    final interestsFuture =
        _getDocs(firestore.collection(APIPath.interests()), 'interests');
    final snapshots = await Future.wait([
      _getDocs(firestore.collection(APIPath.ipilEntry()), 'ipilEntry'),
      ...optionCollections.map((c) => _getDocs(firestore.collection(c), c)),
    ]);

    final Set<String> inscripcionKeys = {};
    final Set<String> certificacionKeys = {};
    for (final snap in snapshots.skip(1)) {
      for (final doc in snap) {
        final data = doc.data();
        final label = _normalizeText((data['label'] ?? '').toString());
        if (!label.contains('formaci')) continue;
        final Set<String>? target = label.contains('inscripci')
            ? inscripcionKeys
            : (label.contains('certificaci') ? certificacionKeys : null);
        if (target == null) continue;
        target.add(doc.id);
        target.add((data['label'] ?? '').toString());
        data.forEach((key, value) {
          if (key.endsWith('Id') && value != null) target.add(value.toString());
        });
      }
    }

    final int currentYear = DateTime.now().year;
    final int previousYear = currentYear - 1;

    // Participantes distintos por año para cada indicador; la clave
    // [acumulado] guarda todos, independientemente de la fecha.
    const int acumulado = 0;
    Map<int, Set<String>> newCounter() =>
        {currentYear: {}, previousYear: {}, acumulado: {}};
    final inscripcion = newCounter();
    final certificacion = newCounter();
    final empleo = newCounter();
    final mantiene4Semanas = newCounter();
    final mantiene6Meses = newCounter();

    // Resultados por sector: "Tipo de empleo" (interest) elegido en el
    // seguimiento IPIL al marcar "Obtienen empleo" → participantes distintos
    final Map<String, Set<String>> empleoUsersByType = {};
    void addEmploymentType(String? typeId, String userId) {
      if (typeId == null || typeId.isEmpty) return;
      empleoUsersByType.putIfAbsent(typeId, () => {}).add(userId);
    }

    void add(Map<int, Set<String>> target, DateTime? date, String userId) {
      target[acumulado]!.add(userId);
      if (date == null) return;
      target[date.year]?.add(userId);
    }

    for (final doc in snapshots[0]) {
      final IpilEntry ipil;
      try {
        ipil = IpilEntry.fromMap(doc.data(), doc.id);
      } catch (_) {
        continue;
      }
      if (!userIds.contains(ipil.userId)) continue;

      final checked = <String>{
        ...?ipil.reinforcement,
        ...?ipil.contextualization,
        ...?ipil.connectionTerritory,
        ...?ipil.interviews,
        ...?ipil.intermediations,
        ...?ipil.obtainingEmployment,
        ...?ipil.improvingEmployment,
        ...?ipil.coordination,
        ...?ipil.postWorkSupport,
        ...?ipil.legal,
        ...?ipil.economicBag,
        ...?ipil.specificSkills,
        ...?ipil.softSkills,
        ...?ipil.digitalSkills,
        ...?ipil.laborSkills,
        ...?ipil.results,
      };
      if (checked.any(inscripcionKeys.contains))
        add(inscripcion, ipil.date, ipil.userId);
      if (checked.any(certificacionKeys.contains))
        add(certificacion, ipil.date, ipil.userId);

      if (ipil.fourWeeksCheck == true) {
        if (ipil.fourWeeksSituation == StringConst.IPIL_SITUATION_EMPLOYMENT) {
          add(empleo, ipil.date, ipil.userId);
          addEmploymentType(ipil.fourWeeksEmploymentTypeId, ipil.userId);
        } else if (ipil.fourWeeksSituation ==
            StringConst.IPIL_SITUATION_KEEPS_EMPLOYMENT) {
          add(mantiene4Semanas, ipil.date, ipil.userId);
        }
      }
      if (ipil.sixMonthsCheck == true) {
        if (ipil.sixMonthsSituation == StringConst.IPIL_SITUATION_EMPLOYMENT) {
          add(empleo, ipil.date, ipil.userId);
          addEmploymentType(ipil.sixMonthsEmploymentTypeId, ipil.userId);
        } else if (ipil.sixMonthsSituation ==
            StringConst.IPIL_SITUATION_KEEPS_EMPLOYMENT) {
          add(mantiene6Meses, ipil.date, ipil.userId);
        }
      }
    }

    // Empleos conseguidos en el informe de cierre ("Consecución de empleo: Si")
    for (final doc in closureReportDocs) {
      try {
        final report = ClosureReport.fromMap(doc.data(), doc.id);
        final uId = report.userId ?? '';
        if (!userIds.contains(uId)) continue;
        if (_normalizeText(report.jobObtaining ?? '') != 'si') continue;
        add(
            empleo,
            report.jobObtainDate ?? report.completedDate ?? report.closeDate,
            uId);
      } catch (_) {}
    }

    // CV realizado en Enreda: participantes con alguna experiencia o formación
    final idList = userIds.toList();
    final Set<String> conCv = {};
    final cvSnapshots = await Future.wait([
      for (int i = 0; i < idList.length; i += 30)
        _getDocs(
          firestore.collection(APIPath.experiences()).where('userId',
              whereIn: idList.sublist(
                  i, i + 30 > idList.length ? idList.length : i + 30)),
          'experiences',
        ),
    ]);
    for (final snap in cvSnapshots) {
      for (final doc in snap) {
        final uId = doc.data()['userId']?.toString();
        if (uId != null) conCv.add(uId);
      }
    }

    String variation(int current, int previous) {
      if (previous == 0) return current > 0 ? '▲ nuevo' : '= 0%';
      final pct = ((current - previous) / previous * 100).round();
      if (pct > 0) return '▲ $pct%';
      if (pct < 0) return '▼ ${pct.abs()}%';
      return '= 0%';
    }

    String personas(int n) => n == 1 ? 'persona' : 'personas';

    KeyIndicatorMetric yearly({
      required String title,
      required Map<int, Set<String>> data,
      required String source,
      required IconData icon,
    }) {
      final current = data[currentYear]!.length;
      final previous = data[previousYear]!.length;
      return KeyIndicatorMetric(
        title: title,
        mainValue: '$current',
        unit: personas(current),
        variation: variation(current, previous),
        isPositive: current >= previous,
        previousYearText: 'En $previousYear: $previous ${personas(previous)}',
        source: source,
        icon: icon,
      );
    }

    final m4Current = mantiene4Semanas[currentYear]!.length;
    final m6Current = mantiene6Meses[currentYear]!.length;
    final m6Previous = mantiene6Meses[previousYear]!.length;

    final int totalInscritos = users.length;
    FunnelStep step(String label, int count, Color ringColor) => FunnelStep(
          percentage:
              totalInscritos > 0 ? (count / totalInscritos * 100).round() : 0,
          count: count,
          label: label,
          ringColor: ringColor,
        );
    final recorrido = [
      step('Participantes inscritos', totalInscritos, KpiColors.primaryDark),
      step('Ingreso a formación', inscripcion[acumulado]!.length,
          KpiColors.turquoise),
      step('Cualificaciones obtenidas', certificacion[acumulado]!.length,
          KpiColors.turquoise),
      step('Empleos conseguidos', empleo[acumulado]!.length,
          KpiColors.turquoise),
      step('Empleo mantenido a 6 meses', mantiene6Meses[acumulado]!.length,
          KpiColors.turquoise),
    ];

    final indicadores = [
      yearly(
        title: 'Ingreso a formación',
        data: inscripcion,
        source: 'Fuente: IPIL › Inscripción formación',
        icon: Icons.school_outlined,
      ),
      yearly(
        title: 'Cualificaciones obtenidas',
        data: certificacion,
        source: 'Fuente: IPIL › Certificación formación',
        icon: Icons.star_outline_rounded,
      ),
      yearly(
        title: 'Empleos conseguidos',
        data: empleo,
        source: 'Fuente: Informe de cierre e IPIL › Seguimiento',
        icon: Icons.work_outline,
      ),
      KeyIndicatorMetric(
        title: 'Mantenimiento del empleo',
        mainValue: '$m4Current',
        unit: '${personas(m4Current)} a las 4 semanas',
        secondValue: '$m6Current',
        secondUnit: '${personas(m6Current)} a los 6 meses',
        variation: variation(m6Current, m6Previous),
        isPositive: m6Current >= m6Previous,
        previousYearText:
            'A los 6 meses en $previousYear: $m6Previous ${personas(m6Previous)}',
        source: 'Fuente: IPIL › Seguimiento',
        icon: Icons.shield_outlined,
      ),
      KeyIndicatorMetric(
        title: 'CV realizado en Enreda',
        mainValue: '${conCv.length}',
        unit: personas(conCv.length),
        variation: '',
        isPositive: true,
        previousYearText: 'Total acumulado (sin fecha de realización)',
        source: 'Fuente: Enreda › Currículum',
        icon: Icons.description_outlined,
      ),
    ];

    // El tipo de empleo se guarda como `interestId` (o el nombre si no lo hay)
    final Map<String, String> interestNameByKey = {};
    for (final doc in await interestsFuture) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      interestNameByKey[doc.id] = name;
      if (data['interestId'] != null)
        interestNameByKey[data['interestId'].toString()] = name;
      interestNameByKey[name] = name;
    }
    final Map<String, Set<String>> empleoUsersBySector = {};
    for (final entry in empleoUsersByType.entries) {
      final sector = interestNameByKey[entry.key] ?? 'Otros sectores';
      empleoUsersBySector.putIfAbsent(sector, () => {}).addAll(entry.value);
    }
    final int totalConSector =
        empleoUsersByType.values.expand((u) => u).toSet().length;
    final porSector = empleoUsersBySector.entries
        .map((e) => RankedBarItem(
              label: e.key,
              count: e.value.length,
              percentage: totalConSector > 0
                  ? e.value.length / totalConSector * 100
                  : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return (
      indicadores: indicadores,
      recorrido: recorrido,
      porSector: porSector
    );
  }

  static const List<Color> _resourceCategoryColors = [
    KpiColors.primaryDark,
    KpiColors.turquoise,
    KpiColors.lightTurquoise,
    KpiColors.yellow,
    KpiColors.slate,
    KpiColors.borderLight,
  ];

  /// Carga los KPIs de recursos. Se cuentan todos los recursos de la
  /// colección, independientemente del filtro seleccionado.
  Future<RecursosKpiData> loadRecursosKpi() async {
    final firestore = FirebaseFirestore.instance;
    final results = await Future.wait([
      _getDocs(firestore.collection(APIPath.resources()), 'resources'),
      _getDocs(firestore.collection(APIPath.resourcesCategories()),
          'resourcesCategories'),
      _getDocs(firestore.collection(APIPath.interests()), 'interests'),
    ]);

    // Ámbitos de actuación: se indexan por `interestId` y por el id del documento
    final interestNames = <String>[];
    final Map<String, int> interestIndexByKey = {};
    for (final doc in results[2]) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final idx = interestNames.length;
      interestNames.add(name);
      interestIndexByKey[doc.id] = idx;
      if (data['interestId'] != null)
        interestIndexByKey[data['interestId'].toString()] = idx;
    }
    final interestCounts = List<int>.filled(interestNames.length, 0);
    int conInteres = 0;

    final categories = <({String id, String name, int order})>[];
    for (final doc in results[1]) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      categories.add((
        id: doc.id,
        name: name,
        order: data['order'] is int ? data['order'] as int : 0,
      ));
    }
    categories.sort((a, b) => a.order.compareTo(b.order));
    final Map<String, int> categoryIndexById = {
      for (int i = 0; i < categories.length; i++) categories[i].id: i,
    };
    final Map<String, int> categoryIndexByName = {
      for (int i = 0; i < categories.length; i++)
        _normalizeText(categories[i].name): i,
    };

    final counts = List<int>.filled(categories.length, 0);
    int otros = 0;
    final List<DateTime> fechas = [];
    final now = DateTime.now();
    int esteMes = 0;

    for (final doc in results[0]) {
      final data = doc.data();

      final rawDate = data['createdate'];
      final DateTime? created = rawDate is Timestamp
          ? rawDate.toDate()
          : (rawDate is DateTime ? rawDate : null);
      if (created != null) {
        fechas.add(created);
        if (created.year == now.year && created.month == now.month) esteMes++;
      }

      final idx =
          categoryIndexById[(data['resourceCategory'] ?? '').toString()] ??
              categoryIndexByName[_normalizeText(
                  (data['resourceCategoryName'] ?? '').toString())];
      if (idx != null) {
        counts[idx]++;
      } else {
        otros++;
      }

      final rawInterests = data['interests'];
      if (rawInterests is List && rawInterests.isNotEmpty) {
        conInteres++;
        final matched = <int>{};
        for (final key in rawInterests) {
          final i = interestIndexByKey[key?.toString()];
          if (i != null) matched.add(i);
        }
        for (final i in matched) {
          interestCounts[i]++;
        }
      }
    }

    final int total = results[0].length;
    double pct(int count) => total > 0 ? count / total * 100 : 0.0;

    final porCategoria = <DonutSegment>[
      for (int i = 0; i < categories.length; i++)
        if (counts[i] > 0)
          DonutSegment(
            label: categories[i].name,
            count: counts[i],
            percentage: pct(counts[i]),
            color: _resourceCategoryColors[i % _resourceCategoryColors.length],
          ),
      if (otros > 0)
        DonutSegment(
            label: 'Otros',
            count: otros,
            percentage: pct(otros),
            color: KpiColors.divider),
    ];

    final porInteres = [
      for (int i = 0; i < interestNames.length; i++)
        if (interestCounts[i] > 0)
          RankedBarItem(
            label: interestNames[i],
            count: interestCounts[i],
            percentage:
                conInteres > 0 ? interestCounts[i] / conInteres * 100 : 0.0,
          ),
    ]..sort((a, b) => b.count.compareTo(a.count));

    return RecursosKpiData(
      total: total,
      esteMes: esteMes,
      porCategoria: porCategoria,
      fechas: fechas,
      porInteres: porInteres,
      conInteres: conInteres,
    );
  }
}
