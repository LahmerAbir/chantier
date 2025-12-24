import 'package:chantier/model/homme.dart';
import 'package:chantier/pages/client_page.dart';
import 'package:chantier/pages/planning_page.dart';
import 'package:chantier/ui/common/loading.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../model/chantier.dart';
import '../repository/chantier_repository.dart';
import '../resources/images.dart';
import '../utils/utils.dart';
import 'chantier.dart';
import 'devis&facture.dart';
import 'listing_camion.dart';
import 'listing_homme.dart';
import 'listing_mat.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion BTP Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF767676)),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ChantiersPage(),
    const PlanningScreen(),
    const DocumentsPage(),
    ClientManagementScreen(), // Devis & Factures
    const MatManagementScreen(
      title: "Gestion des Matériels",
      entityName: "Matériel",
    ),
    const HommeManagementScreen(
      title: "Gestion des Employées",
      entityName: "hommes",
    ),
    const CamionManagementScreen(
      title: "Gestion des Camions",
      entityName: "Camion",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          if (!isMobile)
            NavigationSideBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
            ),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: NavigationSideBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
    );
  }
}

class NavigationSideBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavigationSideBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Hero(
                    tag: 'logo_hero_tag', // Tag UNiQUE pour la transition
                    child: Image(
                      image: AssetImage(Utils.getImagePath(DeliveryImage.logo)),
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "BuildPro",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: "Tableau de bord",
            index: 0,
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.construction,
            label: "Chantiers",
            index: 1,
            isSelected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.list_alt,
            label: "Planning",
            index: 2,
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _NavItem(
            icon: Icons.receipt_long_outlined,
            label: "Devis & Factures",
            index: 3,
            isSelected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          _NavItem(
            icon: Icons.perm_contact_cal_rounded,
            label: "Clients",
            index: 4,
            isSelected: selectedIndex == 4,
            onTap: () => onDestinationSelected(4),
          ),
          _NavItem(
            icon: Icons.handyman_outlined,
            label: "Matériel",
            index: 5,
            isSelected: selectedIndex == 5,
            onTap: () => onDestinationSelected(5),
          ),
          // Autres items simulés
          _NavItem(
            icon: Icons.person,
            label: "Hommes",
            index: 6,
            isSelected: selectedIndex == 6,
            onTap: () {
              onDestinationSelected(6);
            },
          ),
          _NavItem(
            icon: Icons.emoji_transportation,
            label: "Camions",
            index: 7,
            isSelected: selectedIndex == 7,
            onTap: () {
              onDestinationSelected(7);
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.grey.shade700 : Colors.grey.shade500,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.grey.shade700 : Colors.grey.shade500,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.grey.shade50,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (!isMobile) const SizedBox(width: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 10),

              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Abir Lahmer",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Administrateur",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  double totalVentes = 0.0;
  double totalAchats = 0.0;
  double totalFraisGeneraux = 0.0;
  double beneficeReel = 0.0;
  List<Chantier> chantiers = [];
  List<Homme> hommes = [];
  List<Camion> camions = [];
  List<Materiel> materiels = [];
  bool isLoading = true;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        chantiers = await ChantierRepository().getChantiers() ?? [];
        materiels = await ChantierRepository().getMateriel() ?? [];
        hommes = await ChantierRepository().getHommes() ?? [];
        camions = await ChantierRepository().getCamions() ?? [];
        totalVentes = chantiers.fold(
          0,
          (sum, item) => sum + (item.total!.toDouble() +  200.000) ?? 0,
        ) ;
        totalAchats = chantiers.fold(
          0,
          (sum, item) => sum + item.total!.toDouble(),
        );
        totalFraisGeneraux = 300000.0000;
        beneficeReel = 10000000.000;

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("exception list chantier $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double pourcentage = (beneficeReel / totalVentes) * 100;
    return isLoading
        ? Loader()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tableau de bord",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                const Text(
                  "Vue d'ensemble de vos chantiers et activités",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                defaultTargetPlatform != TargetPlatform.android &&
                        defaultTargetPlatform != TargetPlatform.iOS
                    ? Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _StatCard(
                            title: "Chantiers actifs",
                            value: chantiers.length.toString(),
                            icon: Icons.business,
                            color: Colors.yellow,
                          ),
                          _StatCard(
                            title: "Matériel",
                            value: materiels.length.toString(),
                            icon: Icons.account_tree_outlined,
                            color: Colors.blue,
                          ),
                          _StatCard(
                            title: "Camions",
                            value: camions.length.toString(),
                            icon: Icons.emoji_transportation,
                            color: Colors.green,
                          ),
                          _StatCard(
                            title: "Ouvriers",
                            value: hommes.length.toString(),
                            icon: Icons.person,
                            color: Colors.red,
                          ),
                        ],
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatCardMobile(
                            title: "Chantiers actifs",
                            value: "2",
                            icon: Icons.business,
                            color: Colors.blue,
                          ),
                          _StatCardMobile(
                            title: "Matériel",
                            value: "20",
                            icon: Icons.account_tree_outlined,
                            color: Colors.blue,
                          ),
                          _StatCardMobile(
                            title: "Camions",
                            value: "4",
                            icon: Icons.emoji_transportation,
                            color: Colors.blue,
                          ),
                          _StatCardMobile(
                            title: "Factures impayées",
                            value: "3",
                            icon: Icons.receipt_long,
                            color: Colors.red,
                          ),
                          _StatCardMobile(
                            title: "Tâches auj.",
                            value: "5",
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ],
                      ),
                const SizedBox(height: 20),

                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
               //       height: 400,
                     // width: 500,
                      child: Column(

                        children: [
                          Align(alignment : Alignment.topLeft ,child: Text("Rentabilité de chantier" ,style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold),)) ,
                          SizedBox(
                            height: 250,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 60,
                                // Pour faire un Donut Chart (plus moderne)
                                sections: [
                                  // Achats
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: totalAchats,
                                    title: '',
                                    // On cache le titre sur le cercle pour la clarté
                                    radius: 50,
                                  ),
                                  // Frais Généraux
                                  PieChartSectionData(
                                    color: Colors.redAccent,
                                    value: totalFraisGeneraux,
                                    title: '',
                                    radius: 50,
                                  ),
                                  // Bénéfice
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: beneficeReel,
                                    title: '${pourcentage.toStringAsFixed(1)}%',
                                    // Affiche le %
                                    radius:
                                        60, // Légèrement plus grand pour le mettre en valeur
                                    //     textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLegend(),
                        ],
                      ),
                    ),
                  ),
                ),

                defaultTargetPlatform != TargetPlatform.android &&
                        defaultTargetPlatform != TargetPlatform.iOS
                    ? SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            //    Expanded(flex: 2, child: HorizontalBarChart()),
                            Expanded(flex: 2, child: AnimatedPieChart()),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: HorizontalBarChart()),
                          ],
                        ),
                      ),
                defaultTargetPlatform == TargetPlatform.android &&
                        defaultTargetPlatform == TargetPlatform.iOS
                    ? SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: AnimatedPieChart()),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _legendItem("Ventes Totales", totalVentes, Colors.blue),
        _legendItem("Achats", totalAchats, Colors.orange),
        _legendItem("Frais Généraux", totalFraisGeneraux, Colors.redAccent),
        _legendItem("Bénéfice Net", beneficeReel, Colors.green),
      ],
    );
  }

  Widget _legendItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            "${value.toStringAsFixed(2)} DT",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatCardMobile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardMobile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
        ],
      ),
    );
  }
}

class HorizontalBarChart extends StatelessWidget {
  const HorizontalBarChart({super.key});

  final List<double> projectCounts = const [
    1,
    2,
    1,
  ]; // Actif, En Attente, Terminé
  final List<String> statusLabels = const ['Actifs', 'En Attente', 'Terminés'];
  final List<Color> colors = const [Colors.blue, Colors.orange, Colors.green];

  // Largeur maximale des barres
  static const double barWidth = 12;

  @override
  Widget build(BuildContext context) {
    // Calcul de la valeur maximale pour l'axe X (pour l'échelle)
    final double maxX = projectCounts.reduce((a, b) => a > b ? a : b) + 1;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          right: 10,
          left: 10,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statut des Chantiers",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _getBarGroups(maxX),
                  alignment: BarChartAlignment.center,
                  maxY: 3,
                  // Nous avons 3 catégories (Actif, En Attente, Terminé)
                  minY: 0,

                  // Inverser les axes pour l'horizontal
                  titlesData: _getTitlesData(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),

                  //  minX: 0,
                  // maxX: maxX,

                  // Rendre les barres horizontales (Animation implicite)
                  barTouchData: BarTouchData(enabled: false),
                ),
                swapAnimationDuration: const Duration(
                  milliseconds: 500,
                ), // Animation au changement
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Création des Barres Horizontales
  List<BarChartGroupData> _getBarGroups(double maxX) {
    return List.generate(projectCounts.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            // toY est la hauteur dans un graphique normal, ici c'est la longueur
            toY: projectCounts[index],
            color: colors[index],
            width: barWidth,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  // Configuration des Titres des Axes (Inversés pour l'Horizontal)
  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: true,

      // Axe du bas (Horizontal - les valeurs du nombre de projets)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30, // Espace pour les chiffres
          getTitlesWidget: (value, meta) {
            if (value % 2 == 0) {
              // Affiche seulement les chiffres pairs
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 5.0,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),

      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 90,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < statusLabels.length) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4.0,
                child: Text(
                  statusLabels[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}

class AnimatedBarChart extends StatelessWidget {
  AnimatedBarChart({super.key});

  final List<BarChartGroupData> barGroups = [
    BarChartGroupData(
      x: 0,
      barRods: [BarChartRodData(toY: 40, width: 10, color: Color(0xFF2563EB))],
    ),

    BarChartGroupData(
      x: 1,
      barRods: [BarChartRodData(toY: 50, width: 10, color: Color(0xFF2563EB))],
    ),

    BarChartGroupData(
      x: 2,
      barRods: [BarChartRodData(toY: 45, width: 10, color: Color(0xFF2563EB))],
    ),

    BarChartGroupData(
      x: 3,
      barRods: [BarChartRodData(toY: 60, width: 10, color: Color(0xFF2563EB))],
    ),

    BarChartGroupData(
      x: 4,
      barRods: [BarChartRodData(toY: 80, width: 10, color: Color(0xFF2563EB))],
    ),

    BarChartGroupData(
      x: 5,
      barRods: [BarChartRodData(toY: 55, width: 10, color: Color(0xFF2563EB))],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          right: 20,
          left: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chiffre d'affaires mensuel (K€)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  titlesData: _getTitlesData(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  maxY: 100,
                  minY: 0,
                  barGroups: barGroups,

                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} ',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles()),
      topTitles: const AxisTitles(sideTitles: SideTitles()),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            const style = TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
            String text;
            switch (value.toInt()) {
              case 0:
                text = 'Juil';
                break;
              case 1:
                text = 'Août';
                break;
              case 2:
                text = 'Sept';
                break;
              case 3:
                text = 'Oct';
                break;
              case 4:
                text = 'Nov';
                break;
              case 5:
                text = 'Déc';
                break;
              default:
                text = '';
                break;
            }
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4.0,
              child: Text(text, style: style),
            );
          },
        ),
      ),

      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitlesWidget: (value, meta) {
            if (value == 0 || value == 50 || value == 100) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }
}

class AnimatedPieChart extends StatelessWidget {
  const AnimatedPieChart({super.key});

  final totalProjects = 10;

  final List<Map<String, dynamic>> statusData = const [
    {'status': 'Actif', 'count': 5, 'color': Color(0xFF2563EB)},
    {'status': 'En Attente', 'count': 2, 'color': Color(0xFFFBBF24)},
    {'status': 'Terminé', 'count': 3, 'color': Color(0xFF10B981)},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statut des Chantiers",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2, // Espace entre les tranches
                  centerSpaceRadius: 40, // Donne l'effet Doughnut (anneau)

                  sections: _getPieSections(),

                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Vous pouvez ajouter une action ici (ex: afficher les détails du statut)
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(
                  milliseconds: 750,
                ), // Animation au chargement
              ),
            ),
            const SizedBox(height: 10),
            // Légende du graphique
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections() {
    return statusData.map((data) {
      final isNotEmpty = data['count'] > 0;
      final percentage = (data['count'] / totalProjects) * 100;

      return PieChartSectionData(
        color: data['color'] as Color,
        value: data['count'].toDouble(),
        title: isNotEmpty ? '${percentage.toInt()}%' : '',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Crée la légende pour le graphique
  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statusData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: data['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data['status']} (${data['count']})',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class MaterielPage extends StatelessWidget {
  const MaterielPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Parc matériel",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.4,
              children: [
                _EquipCard(
                  name: "Grue mobile 50T",
                  status: "En utilisation",
                  price: "850€/j",
                  color: Colors.orange,
                ),
                _EquipCard(
                  name: "Pelleteuse CAT 320",
                  status: "Disponible",
                  price: "650€/j",
                  color: Colors.green,
                ),
                _EquipCard(
                  name: "Camion-benne 20m³",
                  status: "En maintenance",
                  price: "380€/j",
                  color: Colors.red,
                ),
                _EquipCard(
                  name: "Bétonnière 500L",
                  status: "Disponible",
                  price: "120€/j",
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipCard extends StatelessWidget {
  final String name;
  final String status;
  final String price;
  final Color color;

  const _EquipCard({
    required this.name,
    required this.status,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.agriculture, size: 30, color: Colors.grey.shade700),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tarif: $price",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Voir détails"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
