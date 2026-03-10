import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/game_state.dart';
import '../state/game_state2.dart';
import '../services/audio_service.dart';
import '../theme.dart';
import '../widgets/neon_background.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _bgController;

  late Color _snakeColor;
  late Color _foodColor;
  late double _gameSpeed;
  late int _selectedThemeIndex;
  late String _selectedSkin;
  late bool _soundEnabled;
  late bool _musicEnabled;

  late String _verticalSkin;
  late int _verticalThemeIndex;
  late double _verticalSpeed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final gameState = Provider.of<GameState>(context, listen: false);
    final verticalState = Provider.of<VerticalGameState>(
      context,
      listen: false,
    );
    final audioService = Provider.of<AudioService>(context, listen: false);

    _snakeColor = gameState.snakeColor;
    _foodColor = gameState.foodColor;
    _gameSpeed = gameState.gameSpeed;
    _selectedThemeIndex = gameState.selectedThemeIndex;
    _selectedSkin = gameState.selectedSkin;
    _soundEnabled = audioService.isSoundEnabled;
    _musicEnabled = audioService.isMusicEnabled;

    _verticalSkin = verticalState.selectedSkin;
    _verticalThemeIndex = verticalState.selectedThemeIndex;
    _verticalSpeed = verticalState.gameSpeed;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final gameState = Provider.of<GameState>(context, listen: false);
    final verticalState = Provider.of<VerticalGameState>(
      context,
      listen: false,
    );
    final audioService = Provider.of<AudioService>(context, listen: false);

    gameState.updateSettings(
      snakeColor: _snakeColor,
      foodColor: _foodColor,
      gameSpeed: _gameSpeed,
      themeIndex: _selectedThemeIndex,
      skin: _selectedSkin,
    );

    verticalState.saveSettings(
      skin: _verticalSkin,
      themeIndex: _verticalThemeIndex,
      speed: _verticalSpeed,
    );

    audioService.setSoundEnabled(_soundEnabled);
    audioService.setMusicEnabled(_musicEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved successfully!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _restoreDefaults() {
    setState(() {
      _snakeColor = Colors.green;
      _foodColor = Colors.red;
      _gameSpeed = 0.5;
      _selectedThemeIndex = 0;
      _selectedSkin = 'Classic';
      _soundEnabled = true;
      _musicEnabled = true;
      _verticalSkin = 'Classic';
      _verticalThemeIndex = 0;
      _verticalSpeed = 5.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _restoreDefaults,
            icon: Icon(
              Icons.restore,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
            label: Text(
              'Reset',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 4,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            insets: const EdgeInsets.symmetric(horizontal: 16),
          ),
          tabs: const [
            Tab(text: 'Classic Mode'),
            Tab(text: 'Vertical Runner'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return NeonBackground(
                  progress: _bgController.value,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
          ),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [_buildClassicSettings(), _buildVerticalSettings()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: _NeonSaveButton(
            onTap: _saveChanges,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildClassicSettings() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Visuals'),
        _buildColorPickerTile(
          title: 'Snake Color',
          color: _snakeColor,
          onChanged: (c) => setState(() => _snakeColor = c),
        ),
        _buildColorPickerTile(
          title: 'Food Color',
          color: _foodColor,
          onChanged: (c) => setState(() => _foodColor = c),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionHeader('Environment'),
        _buildClassicThemeSelector(),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionHeader('Game Play'),
        _buildSpeedSliderTile(
          title: 'Classic Speed',
          value: _gameSpeed,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          onChanged: (v) => setState(() => _gameSpeed = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionHeader('Audio'),
        _buildSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Enable game actions sounds',
          value: _soundEnabled,
          onChanged: (v) => setState(() => _soundEnabled = v),
          icon: Icons.volume_up_rounded,
        ),
        _buildSwitchTile(
          title: 'Background Music',
          subtitle: 'Enable ambient background music',
          value: _musicEnabled,
          onChanged: (v) => setState(() => _musicEnabled = v),
          icon: Icons.music_note_rounded,
        ),
      ],
    );
  }

  Widget _buildVerticalSettings() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Runner Customization'),
        _buildSkinSelector(),
        const SizedBox(height: AppSpacing.lg),
        _buildThemeSelector(),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionHeader('Runner Mechanics'),
        _buildSpeedSliderTile(
          title: 'Scroll Speed',
          value: _verticalSpeed,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          accentColor: Colors.orangeAccent,
          onChanged: (v) => setState(() => _verticalSpeed = v),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
        left: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildColorPickerTile({
    required String title,
    required Color color,
    required ValueChanged<Color> onChanged,
  }) {
    final colors = [
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: colors.map((c) {
                    final isSelected = c.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () => onChanged(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSliderTile({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required int divisions,
    Color? accentColor,
  }) {
    final effectiveAccent =
        accentColor ?? Theme.of(context).colorScheme.secondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    value < 1.0
                        ? value.toStringAsFixed(1)
                        : '${value.toInt()}x',
                    style: TextStyle(
                      color: effectiveAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: effectiveAccent,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: Colors.white,
                  overlayColor: effectiveAccent.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.white70),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinSelector() {
    final skins = [
      {'name': 'Classic', 'color': Theme.of(context).colorScheme.primary},
      {'name': 'Cyber', 'color': Colors.cyanAccent},
      {'name': 'Lava', 'color': Colors.orangeAccent},
      {'name': 'Ghost', 'color': Colors.white},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Runner Skin',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: skins.map((skin) {
                  final isSelected = _verticalSkin == skin['name'];
                  final skinColor = skin['color'] as Color;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _verticalSkin = skin['name'] as String),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: skinColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? skinColor : Colors.white12,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.brush,
                              color: isSelected ? skinColor : Colors.white38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skin['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white38,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicThemeSelector() {
    final themes = [
      {'name': 'Deep Space', 'icon': Icons.dark_mode},
      {'name': 'Neon Grid', 'icon': Icons.grid_3x3},
      {'name': 'Minimalist', 'icon': Icons.remove_circle_outline},
      {'name': 'Matrix', 'icon': Icons.code},
    ];

    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Theme',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedThemeIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedThemeIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isSelected ? primary : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            themes[index]['icon'] as IconData,
                            color: isSelected ? primary : Colors.white38,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            themes[index]['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = [
      {'name': 'Deep Space', 'icon': Icons.dark_mode},
      {'name': 'Neon City', 'icon': Icons.flash_on},
      {'name': 'Forest', 'icon': Icons.forest},
      {'name': 'Abyss', 'icon': Icons.waves},
    ];

    final secondary = Theme.of(context).colorScheme.secondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Theme',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final isSelected = _verticalThemeIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _verticalThemeIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? secondary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isSelected ? secondary : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            themes[index]['icon'] as IconData,
                            color: isSelected ? secondary : Colors.white38,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            themes[index]['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonSaveButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const _NeonSaveButton({required this.onTap, required this.color});

  @override
  State<_NeonSaveButton> createState() => _NeonSaveButtonState();
}

class _NeonSaveButtonState extends State<_NeonSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 5.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'SAVE ALL CHANGES',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
