import 'package:dai_viet_ki_tran_game/app/design_system/game_colors.dart';
import 'package:dai_viet_ki_tran_game/app/di/dependencies.dart';
import 'package:dai_viet_ki_tran_game/audio/application/audio_settings_cubit.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Presentation widget displaying user audio sliders and mute toggle.
class AudioSettingsSection extends StatelessWidget {
  const AudioSettingsSection({this.cubit, super.key});

  final AudioSettingsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<AudioSettingsCubit>.value(
        value: cubit!,
        child: const _AudioSettingsContent(),
      );
    }

    if (getIt.isRegistered<AudioSettingsCubit>()) {
      return BlocProvider<AudioSettingsCubit>.value(
        value: getIt<AudioSettingsCubit>(),
        child: const _AudioSettingsContent(),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AudioSettingsContent extends StatelessWidget {
  const _AudioSettingsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioSettingsCubit, AudioSettings>(
      builder: (context, settings) {
        final cubit = context.read<AudioSettingsCubit>();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GameColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GameColors.panelBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cài Đặt Âm Thanh',
                    style: TextStyle(
                      color: GameColors.goldPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.muted ? 'Đã Tắt Âm' : 'Bật Âm',
                        style: TextStyle(
                          color: settings.muted
                              ? GameColors.hpRed
                              : GameColors.hpGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        key: const Key('audio_mute_switch'),
                        value: !settings.muted,
                        activeThumbColor: GameColors.goldPrimary,
                        onChanged: (_) => cubit.toggleMute(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: GameColors.panelBorder, height: 24),
              _buildSliderRow(
                key: const Key('audio_master_slider'),
                title: 'Âm lượng tổng (Master)',
                value: settings.masterVolume,
                muted: settings.muted,
                icon: Icons.volume_up_rounded,
                onChanged: cubit.setMasterVolume,
              ),
              const SizedBox(height: 12),
              _buildSliderRow(
                key: const Key('audio_music_slider'),
                title: 'Nhạc nền (Music)',
                value: settings.musicVolume,
                muted: settings.muted,
                icon: Icons.music_note_rounded,
                onChanged: cubit.setMusicVolume,
              ),
              const SizedBox(height: 12),
              _buildSliderRow(
                key: const Key('audio_sfx_slider'),
                title: 'Hiệu ứng (SFX)',
                value: settings.sfxVolume,
                muted: settings.muted,
                icon: Icons.graphic_eq_rounded,
                onChanged: cubit.setSfxVolume,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliderRow({
    required Key key,
    required String title,
    required double value,
    required bool muted,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    final percent = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: GameColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              muted ? 'Muted' : '$percent%',
              style: TextStyle(
                color: muted ? GameColors.textMuted : GameColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: muted ? GameColors.textMuted : GameColors.goldPrimary,
            inactiveTrackColor: GameColors.surfaceElevated,
            thumbColor: muted ? GameColors.textMuted : GameColors.goldPrimary,
            overlayColor: GameColors.goldPrimary.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            key: key,
            value: value,
            onChanged: muted ? null : onChanged,
          ),
        ),
      ],
    );
  }
}
