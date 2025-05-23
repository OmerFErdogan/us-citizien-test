import 'package:flutter/material.dart';
import '../services/settings/theme_service.dart';

class ThemeSwitcher extends StatelessWidget {
  final ThemeService themeService;
  
  const ThemeSwitcher({
    Key? key,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeService.isDarkMode 
                ? Icons.dark_mode 
                : themeService.isLightMode 
                    ? Icons.light_mode 
                    : Icons.auto_mode,
            color: Theme.of(context).iconTheme.color,
          ),
          onSelected: (ThemeMode mode) {
            themeService.setThemeMode(mode);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.auto_mode,
                    color: themeService.isSystemMode 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System',
                    style: TextStyle(
                      color: themeService.isSystemMode 
                          ? Theme.of(context).primaryColor 
                          : null,
                      fontWeight: themeService.isSystemMode 
                          ? FontWeight.bold 
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: themeService.isLightMode 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Light',
                    style: TextStyle(
                      color: themeService.isLightMode 
                          ? Theme.of(context).primaryColor 
                          : null,
                      fontWeight: themeService.isLightMode 
                          ? FontWeight.bold 
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: themeService.isDarkMode 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dark',
                    style: TextStyle(
                      color: themeService.isDarkMode 
                          ? Theme.of(context).primaryColor 
                          : null,
                      fontWeight: themeService.isDarkMode 
                          ? FontWeight.bold 
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Basit toggle button
class ThemeToggleButton extends StatelessWidget {
  final ThemeService themeService;
  
  const ThemeToggleButton({
    Key? key,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return IconButton(
          icon: Icon(
            themeService.isDarkMode 
                ? Icons.light_mode 
                : Icons.dark_mode,
          ),
          onPressed: () {
            themeService.toggleTheme();
          },
          tooltip: themeService.isDarkMode 
              ? 'Switch to Light Mode' 
              : 'Switch to Dark Mode',
        );
      },
    );
  }
}
