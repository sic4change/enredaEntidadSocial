import '../../models/userEnreda.dart';
import '../../models/initialReport.dart';
import '../../models/closureReport.dart';
import '../../models/derivationReport.dart';
import '../../services/database.dart';
import '../../services/api_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  const ParticipantesKpiData({
    required this.total,
    required this.porEstado,
    required this.porGenero,
    required this.porNacionalidad,
    this.users = const [],
    this.situacionEmpleoInicial = const [],
    this.situacionEmpleoActual = const [],
    this.totalConInformeInicialCompleto = 0,
  });

  static ParticipantesKpiData empty() {
    return const ParticipantesKpiData(
      total: 0,
      porEstado: [
        StackedBarRow(label: 'Activos', count: 0, percentage: 0, color: KpiColors.turquoise),
        StackedBarRow(label: 'En espera', count: 0, percentage: 0, color: KpiColors.lightTurquoise),
        StackedBarRow(label: 'Inactivos', count: 0, percentage: 0, color: KpiColors.borderLight),
      ],
      porGenero: [
        StackedBarRow(label: 'Mujeres', count: 0, percentage: 0, color: KpiColors.yellow),
        StackedBarRow(label: 'Hombres', count: 0, percentage: 0, color: KpiColors.primaryDark),
        StackedBarRow(label: 'No binario', count: 0, percentage: 0, color: KpiColors.slate),
      ],
      porNacionalidad: [
        StackedBarRow(label: 'Nacional', count: 0, percentage: 0, color: KpiColors.primaryDark),
        StackedBarRow(label: 'Extranjera', count: 0, percentage: 0, color: KpiColors.turquoise),
      ],
      situacionEmpleoInicial: [],
      situacionEmpleoActual: [],
      totalConInformeInicialCompleto: 0,
    );
  }
}

class KpiService {
  final Database database;

  KpiService(this.database);

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
          if (u.role == 'Desempleado' || (u.role == null && u.assignedEntityId != null)) {
            users.add(u);
          }
        } catch (_) {}
      }
      return users;
    }

    // Para Global o subsidios, cargamos participantes de la colección de usuarios
    // Filtramos los que tengan rol 'Desempleado' o sean participantes asignados
    final snap = await firestore
        .collection(APIPath.users())
        .get();

    final List<UserEnreda> users = [];
    for (final doc in snap.docs) {
      try {
        final u = UserEnreda.fromMap(doc.data(), doc.id);
        if (u.role == 'Desempleado' || (u.role == null && (u.assignedEntityId != null || u.socialEntityId != null))) {
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
      firestore.collection(APIPath.initialReports()).get(),
      firestore.collection(APIPath.closureReports()).get(),
      firestore.collection(APIPath.derivationReports()).get(),
    ]);

    final Map<String, InitialReport> initialReportsByUser = {};
    for (final doc in results[0].docs) {
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
    for (final doc in results[1].docs) {
      try {
        final report = ClosureReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          closureReportsByUser[report.userId!] = report;
        }
        closureReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    final Map<String, DerivationReport> derivationReportsByUser = {};
    for (final doc in results[2].docs) {
      try {
        final report = DerivationReport.fromMap(doc.data(), doc.id);
        if (report.userId != null && report.userId!.isNotEmpty) {
          derivationReportsByUser[report.userId!] = report;
        }
        derivationReportsByUser[doc.id] = report;
      } catch (_) {}
    }

    // 2. Filtrar lista de usuarios según el filterId seleccionado
    final List<UserEnreda> filteredUsers = users.where((u) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null && initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      final sub = (initReport?.subsidy ?? '').trim();

      // Si el filtro es por subsidio
      if (filterId == '529760' || filterId.contains('529760')) {
        return sub.contains('529760') || sub.toUpperCase().contains('MEDICOS DEL MUNDO');
      } else if (filterId == '529775' || filterId.contains('529775')) {
        return sub.contains('529775') || sub.toUpperCase().contains('SICFCH');
      } else if (filterId == 'seimlab' || filterId.contains('0080')) {
        return sub.toUpperCase().contains('SEIMLAB') || sub.contains('0080');
      } else if (filterId == 'global') {
        return true;
      } else {
        // Por entidad (currentSocialEntityId)
        return (u.assignedEntityId == currentSocialEntityId || u.socialEntityId == currentSocialEntityId);
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
      final initReport = (u.initialReportId != null && initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      final closureReport = (u.closureReportId != null && closureReportsByUser.containsKey(u.closureReportId))
          ? closureReportsByUser[u.closureReportId]
          : (closureReportsByUser[uId] ?? closureReportsByUser[u.email]);
      final derivationReport = (u.derivationReportId != null && derivationReportsByUser.containsKey(u.derivationReportId))
          ? derivationReportsByUser[u.derivationReportId]
          : (derivationReportsByUser[uId] ?? derivationReportsByUser[u.email]);

      final bool isInitFinished = initReport != null && (initReport.finished == true || initReport.completedDate != null);
      final bool isClosureFinished = closureReport != null && (closureReport.finished == true || closureReport.completedDate != null);
      final bool isDerivationFinished = derivationReport != null && (derivationReport.finished == true || derivationReport.completedDate != null);

      // Estado:
      // "Inactivos": informe de cierre completado y sin informe de reapertura
      // (si tiene socialItineraryHistory, comprobamos si tiene un nuevo ciclo activo reabierto)
      final bool hasReopening = u.initialReportId != null && u.socialItineraryHistory.isNotEmpty;

      if (isClosureFinished && !hasReopening) {
        countInactivos++;
      } else if (isInitFinished && !isClosureFinished && !isDerivationFinished) {
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
      } else if (genderStr == 'hombre' || genderStr == 'masculino' || genderStr == 'm') {
        countHombres++;
      } else {
        countNoBinario++;
      }

      // Nacionalidad:
      // "Nacional" si es España, "Extranjera" en caso contrario
      final natStr = (u.nationality ?? '').trim().toLowerCase();
      if (natStr == 'españa' || natStr == 'espana' || natStr == 'española' || natStr == 'espanola') {
        countNacional++;
      } else {
        countExtranjera++;
      }
    }

    double pct(int count) => total > 0 ? ((count / total) * 100) : 0.0;

    final situacionInicial = _calculateSituacionEmpleo(
      users: filteredUsers,
      initialReportsByUser: initialReportsByUser,
      isActual: false,
    );

    final situacionActual = _calculateSituacionEmpleo(
      users: filteredUsers,
      initialReportsByUser: initialReportsByUser,
      closureReportsByUser: closureReportsByUser,
      isActual: true,
    );

    int totalConInformeInicialCompleto = 0;
    for (final u in filteredUsers) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null && initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);
      if (initReport != null && (initReport.finished == true || initReport.completedDate != null)) {
        totalConInformeInicialCompleto++;
      }
    }

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
    );
  }

  /// Calcula el desglose de situación de empleo por género
  /// teniendo en cuenta únicamente los participantes con informe inicial completado
  List<SituacionEmpleoRow> _calculateSituacionEmpleo({
    required List<UserEnreda> users,
    required Map<String, InitialReport> initialReportsByUser,
    Map<String, ClosureReport>? closureReportsByUser,
    bool isActual = false,
  }) {
    int cortaM = 0, cortaH = 0, cortaNB = 0;
    int largaM = 0, largaH = 0, largaNB = 0;
    int otherDesempM = 0, otherDesempH = 0, otherDesempNB = 0;
    int inactM = 0, inactH = 0, inactNB = 0;
    int empM = 0, empH = 0, empNB = 0;
    int unspecM = 0, unspecH = 0, unspecNB = 0;

    for (final u in users) {
      final uId = u.userId ?? '';
      final initReport = (u.initialReportId != null && initialReportsByUser.containsKey(u.initialReportId))
          ? initialReportsByUser[u.initialReportId]
          : (initialReportsByUser[uId] ?? initialReportsByUser[u.email]);

      // Solo tener en cuenta los participantes con informe inicial completo
      final bool isInitFinished = initReport != null && (initReport.finished == true || initReport.completedDate != null);
      if (!isInitFinished) continue;

      String laborSituation = (initReport.laborSituation ?? '').trim();

      // Si es situación actual y tiene informe de cierre con situación laboral, se toma la más reciente
      if (isActual && closureReportsByUser != null) {
        final closureReport = (u.closureReportId != null && closureReportsByUser.containsKey(u.closureReportId))
            ? closureReportsByUser[u.closureReportId]
            : (closureReportsByUser[uId] ?? closureReportsByUser[u.email]);
        if (closureReport != null && (closureReport.laborSituation ?? '').trim().isNotEmpty) {
          laborSituation = closureReport.laborSituation!.trim();
        }
      }

      final gStr = (u.gender ?? '').trim().toLowerCase();
      final bool isMujer = (gStr == 'mujer' || gStr == 'femenino' || gStr == 'f');
      final bool isHombre = (gStr == 'hombre' || gStr == 'masculino' || gStr == 'm');

      final ls = laborSituation.toLowerCase();

      if (ls.contains('corta')) {
        if (isMujer) cortaM++; else if (isHombre) cortaH++; else cortaNB++;
      } else if (ls.contains('larga')) {
        if (isMujer) largaM++; else if (isHombre) largaH++; else largaNB++;
      } else if (ls.contains('desemplead')) {
        if (isMujer) otherDesempM++; else if (isHombre) otherDesempH++; else otherDesempNB++;
      } else if (ls.contains('inactiv')) {
        if (isMujer) inactM++; else if (isHombre) inactH++; else inactNB++;
      } else if (ls.contains('ocupada') || ls.contains('emplead')) {
        if (isMujer) empM++; else if (isHombre) empH++; else empNB++;
      } else {
        if (isMujer) unspecM++; else if (isHombre) unspecH++; else unspecNB++;
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
        label: '↳ Corta duración',
        mujeres: cortaM,
        hombres: cortaH,
        noBinario: cortaNB,
        total: cortaTotal,
        isIndented: true,
      ),
      SituacionEmpleoRow(
        label: '↳ Larga duración',
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
}
