import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/constants/text_styles.dart';
import 'package:replica/services/project_service.dart'; // NEW
import 'package:replica/models/project.dart'; // NEW
import 'package:intl/intl.dart'; // To format dates

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = true;

  void _onLeftPanelItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final List<Widget> _pages = [
      _RecentFilesView(),
      _DraftsView(),
      _TeamsView(),
      _PluginsView(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: isMobile
            ? IconButton(
                icon: Icon(Icons.menu,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              )
            : IconButton(
                icon: Icon(
                    _isSidebarOpen
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: _toggleSidebar,
              ),
        title: Text(
          'Your Figma Workspace',
          style: Theme.of(context).brightness == Brightness.dark
              ? AppTextStyles.headlineMediumDark
              : AppTextStyles.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Search icon pressed!',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white))),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Notifications icon pressed!',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white))),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('User Profile icon pressed!',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white))),
                );
              },
              child: CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: Text(
                  'U',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              child: _buildDrawerContent(
                  context, _onLeftPanelItemTapped, _selectedIndex),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSidebarOpen ? 250 : 0,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: _isSidebarOpen
                  ? _buildDrawerContent(
                      context, _onLeftPanelItemTapped, _selectedIndex)
                  : const SizedBox.shrink(),
            ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final projectService =
              Provider.of<ProjectService>(context, listen: false);
          final newProject = projectService.createNewFile('Untitled Design');
          Navigator.pushNamed(context, '/dashboard', arguments: newProject);
        },
        label: Text('New Design',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDrawerContent(
      BuildContext context, Function(int) onTap, int selectedIndex) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildDrawerHeader(context),
        _buildListTile(
          Icons.recent_actors,
          'Recents',
          0,
          selectedIndex == 0,
          onTap,
          isDarkMode,
        ),
        _buildListTile(
          Icons.folder_open,
          'Drafts',
          1,
          selectedIndex == 1,
          onTap,
          isDarkMode,
        ),
        _buildListTile(
          Icons.group,
          'Teams',
          2,
          selectedIndex == 2,
          onTap,
          isDarkMode,
        ),
        _buildListTile(
          Icons.extension,
          'Plugins',
          3,
          selectedIndex == 3,
          onTap,
          isDarkMode,
        ),
        Divider(
            color: isDarkMode
                ? AppColors.borderColorDark.withOpacity(0.5)
                : AppColors.borderColorLight.withOpacity(0.5)),
        _buildListTile(
          Icons.settings,
          'Settings',
          -1,
          false,
          (index) {
            Navigator.pushNamed(context, '/settings');
            if (MediaQuery.of(context).size.width < 600) Navigator.pop(context);
          },
          isDarkMode,
        ),
        _buildListTile(
          Icons.logout,
          'Logout',
          -1,
          false,
          (index) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Logging out... (Simulated)',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white))),
            );
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacementNamed(context, '/login');
            });
            if (MediaQuery.of(context).size.width < 600) Navigator.pop(context);
          },
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accentPurple,
            child: Text('JD',
                style:
                    AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            'John Doe',
            style: isDarkMode
                ? AppTextStyles.bodyLargeDark
                : AppTextStyles.bodyLarge,
          ),
          Text(
            'john.doe@example.com',
            style: isDarkMode
                ? AppTextStyles.labelMediumDark
                : AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, int index, bool isSelected,
      Function(int) onTap, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? AppColors.primaryBlue
              : (isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight)),
      title: Text(
        title,
        style: isSelected
            ? (isDarkMode
                ? AppTextStyles.bodyMediumDark.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                : AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.primaryBlue))
            : (isDarkMode
                ? AppTextStyles.bodyMediumDark
                : AppTextStyles.bodyMedium),
      ),
      onTap: () => onTap(index),
      selected: isSelected,
      selectedTileColor: AppColors.primaryBlue.withOpacity(0.15),
      hoverColor: (isDarkMode ? AppColors.surfaceLight : AppColors.surfaceDark)
          .withOpacity(0.1),
    );
  }
}

class _RecentFilesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final projectService = Provider.of<ProjectService>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Files',
            style: isDarkMode
                ? AppTextStyles.headlineMediumDark
                : AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 250).floor();
                return projectService.recentFiles.isEmpty
                    ? Center(
                        child: Text(
                          'No recent files. Start a new design!',
                          style: isDarkMode
                              ? AppTextStyles.bodyMediumDark
                              : AppTextStyles.bodyMedium,
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              crossAxisCount > 0 ? crossAxisCount : 1,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: projectService.recentFiles.length,
                        itemBuilder: (context, index) {
                          final project = projectService.recentFiles[index];
                          return _buildFileCard(context, project);
                        },
                      );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Explore Templates',
            style: isDarkMode
                ? AppTextStyles.headlineMediumDark
                : AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: projectService.templates.isEmpty
                ? Center(
                    child: Text(
                      'No templates available.',
                      style: isDarkMode
                          ? AppTextStyles.bodyMediumDark
                          : AppTextStyles.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: projectService.templates.length,
                    itemBuilder: (context, index) {
                      final template = projectService.templates[index];
                      return _buildTemplateCard(context, template);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, Project project) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final formattedDate =
        DateFormat('MMM d, h:mm a').format(project.lastModified);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/dashboard', arguments: project);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? AppColors.shadowColorDark
                  : AppColors.shadowColorLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: isDarkMode
                      ? AppColors.backgroundLight.withOpacity(0.1)
                      : AppColors.backgroundDark.withOpacity(0.1),
                  child: Center(
                    child: Icon(Icons.art_track,
                        size: 50,
                        color: AppColors.primaryBlue), // Placeholder thumbnail
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                            .copyWith(fontWeight: FontWeight.w600)
                        : AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Edited $formattedDate',
                    style: isDarkMode
                        ? AppTextStyles.labelSmallDark
                        : AppTextStyles.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, Project template) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final projectService =
            Provider.of<ProjectService>(context, listen: false);
        // Create a new editable file from the template's shapes
        final newProject = projectService.createNewFile(
            '${template.name} (Copy)',
            initialShapes: template.canvasShapes
                .map((s) => s.copyWith(size: null, isSelected: false))
                .toList());
        Navigator.pushNamed(context, '/dashboard', arguments: newProject);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? AppColors.shadowColorDark
                  : AppColors.shadowColorLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: isDarkMode
                      ? AppColors.backgroundLight.withOpacity(0.1)
                      : AppColors.backgroundDark.withOpacity(0.1),
                  child: Center(
                    // Simple text representation for template uniqueness
                    child: Text(
                      template.name
                          .split(' ')
                          .map((e) => e[0])
                          .join()
                          .toUpperCase(),
                      style: AppTextStyles.headlineLarge
                          .copyWith(color: AppColors.accentPurple),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: isDarkMode
                        ? AppTextStyles.bodyMediumDark
                            .copyWith(fontWeight: FontWeight.w600)
                        : AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click to create new file',
                    style: isDarkMode
                        ? AppTextStyles.labelSmallDark
                        : AppTextStyles.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // For a real app, this would also fetch from ProjectService with a filter
    return Center(
      child: Text(
        'Your Private Drafts Go Here (Future Feature)',
        textAlign: TextAlign.center,
        style: isDarkMode
            ? AppTextStyles.headlineMediumDark
                .copyWith(color: AppColors.textSecondaryDark)
            : AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textSecondaryLight),
      ),
    );
  }
}

class _TeamsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'Collaborate with Your Teams (Future Feature)',
        textAlign: TextAlign.center,
        style: isDarkMode
            ? AppTextStyles.headlineMediumDark
                .copyWith(color: AppColors.textSecondaryDark)
            : AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textSecondaryLight),
      ),
    );
  }
}

class _PluginsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'Discover and Manage Plugins (Future Feature)',
        textAlign: TextAlign.center,
        style: isDarkMode
            ? AppTextStyles.headlineMediumDark
                .copyWith(color: AppColors.textSecondaryDark)
            : AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textSecondaryLight),
      ),
    );
  }
}
