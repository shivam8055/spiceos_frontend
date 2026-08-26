import 'package:flutter/material.dart';

import 'responsive_layout.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppTopBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = ResponsiveLayout.isMobile(context);

    return AppBar(
      automaticallyImplyLeading: mobile,
      titleSpacing: mobile ? 4 : 16,
      title: Text(
        title,
        style: TextStyle(
          fontSize: mobile ? 20 : 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        Padding(
          padding: EdgeInsets.only(right: mobile ? 8 : 16, left: 4),
          child: const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person, size: 20),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
