import 'package:flutter/material.dart';
import '../utils/extensions.dart';
import '../widgets/language_selector_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Function() onReset;

  const AppBarWidget({
    Key? key,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue.shade800,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/american_flag_icon.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.americanDream,
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.settings_outlined, color: Colors.blue.shade800),
        onPressed: () {
          // Ayarlar menüsünü göster
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        // Dil seçici düğmesi - daha belirgin yapalım
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: LanguageSelectorWidget(
            iconColor: Colors.blue.shade800,
            iconSize: 24,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, color: Colors.blue.shade800),
          offset: const Offset(0, 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) async {
            if (value == 'reset') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(context.l10n.attention),
                  content: Text(context.l10n.resetProgressWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.l10n.reset),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ) ?? false;
              
              if (confirmed) {
                onReset();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.progressReset),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'reset',
              child: Row(
                children: [
                  const Icon(Icons.restore, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.resetProgress,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
