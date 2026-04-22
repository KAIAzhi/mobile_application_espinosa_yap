import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'home.dart';
import 'maps.dart';
import 'profile.dart';
import 'reports.dart';
import '../models/users.dart';  // ADD

class NotificationsPage extends StatefulWidget {
  final Users user;  // ADD
  const NotificationsPage({super.key, required this.user});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.read = false,
  });

  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool read;
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedIndex = 2;

  late List<_NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      const _NotificationItem(
        title: 'New hazard near you',
        body:
            'Flooding reported at Barangay Hall Perimeter. Stay informed and avoid the area if possible.',
        time: '12 min ago',
        icon: Icons.water_drop_rounded,
        color: AppTheme.accentAmber,
        read: false,
      ),
      const _NotificationItem(
        title: 'Report status updated',
        body:
            'Your report “Downed Utility Wire” is now UNDER INVESTIGATION. Emergency crew has been notified.',
        time: '2 hours ago',
        icon: Icons.assignment_turned_in_rounded,
        color: AppTheme.primaryBlue,
        read: false,
      ),
      const _NotificationItem(
        title: 'Safety advisory',
        body:
            'Heavy rain expected this evening. Secure loose objects and monitor official alerts.',
        time: 'Yesterday',
        icon: Icons.cloud_rounded,
        color: AppTheme.primaryBlueDark,
        read: true,
      ),
      const _NotificationItem(
        title: 'Community drill reminder',
        body:
            'Barangay evacuation drill scheduled Saturday 8:00 AM. Participation is encouraged.',
        time: '2 days ago',
        icon: Icons.groups_rounded,
        color: AppTheme.successGreen,
        read: true,
      ),
    ];
  }

  int get _unreadCount => _items.where((e) => !e.read).length;

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeWidget(user: widget.user)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportsWidget(user: widget.user)),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HazardDetailsPage(user: widget.user)),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
        );
        break;
    }
  }

  void _markAllRead() {
    setState(() {
      _items = _items
          .map(
            (e) => _NotificationItem(
              title: e.title,
              body: e.body,
              time: e.time,
              icon: e.icon,
              color: e.color,
              read: true,
            ),
          )
          .toList();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All notifications marked as read',
            style: GoogleFonts.outfit(),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _toggleRead(int index) {
    setState(() {
      final e = _items[index];
      _items[index] = _NotificationItem(
        title: e.title,
        body: e.body,
        time: e.time,
        icon: e.icon,
        color: e.color,
        read: !e.read,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1
                    ? Icons.assessment_rounded
                    : Icons.assessment_outlined,
              ),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _unreadCount > 0 && _selectedIndex != 2,
                label: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  style: const TextStyle(fontSize: 10),
                ),
                child: Icon(
                  _selectedIndex == 2
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined,
                ),
              ),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3 ? Icons.map_rounded : Icons.map_outlined,
              ),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 4
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_unreadCount > 0)
                          Text(
                            '$_unreadCount unread',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = _items[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _toggleRead(index),
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: AppTheme.cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: n.read
                                      ? Colors.grey.shade200
                                      : AppTheme.primaryBlue.withOpacity(0.35),
                                  width: n.read ? 1 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: n.color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(n.icon, color: n.color, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  n.title,
                                                  style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              if (!n.read)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: AppTheme.primaryBlue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n.body,
                                            style: GoogleFonts.outfit(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            n.time,
                                            style: GoogleFonts.outfit(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
