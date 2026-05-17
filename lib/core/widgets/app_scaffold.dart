import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTabSpec {
  const AppTabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<AppTabSpec> appTabs = [
  AppTabSpec(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppTabSpec(
    label: 'Search',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search,
  ),
  AppTabSpec(
    label: 'Activity',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
  ),
  AppTabSpec(
    label: 'Profile',
    icon: Icons.person_outlined,
    selectedIcon: Icons.person,
  ),
];

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text(appTabs[index].label),
        centerTitle: true,
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          for (final tab in appTabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '$title tab content goes here.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
