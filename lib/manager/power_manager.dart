import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_ext/window_ext.dart';

/// 处理 Windows WM_POWERBROADCAST 休眠/唤醒事件。
///
/// 系统休眠时若 VPN 正在运行，先停止以释放驱动句柄；
/// 唤醒后延迟 3 秒自动恢复，等待物理网卡就绪。
class PowerManager extends ConsumerStatefulWidget {
  final Widget child;

  const PowerManager({super.key, required this.child});

  @override
  ConsumerState<PowerManager> createState() => _PowerManagerState();
}

class _PowerManagerState extends ConsumerState<PowerManager>
    with WindowExtListener {
  bool _wasVpnRunningBeforeSuspend = false;

  @override
  void initState() {
    super.initState();
    windowExtManager.addListener(this);
  }

  @override
  void onPowerSuspend() {
    _wasVpnRunningBeforeSuspend = globalState.isStart;
    if (_wasVpnRunningBeforeSuspend) {
      commonPrint.log(
        'System Suspend: VPN running, stopping to release driver handles...',
      );
      globalState.appController.updateStatus(false);
    }
    super.onPowerSuspend();
  }

  @override
  void onPowerResume() {
    if (_wasVpnRunningBeforeSuspend) {
      commonPrint.log('System Resume: VPN was active, restarting in 3s...');
      _wasVpnRunningBeforeSuspend = false;
      Future.delayed(const Duration(seconds: 3), () {
        if (!globalState.isStart) {
          globalState.appController.updateStatus(true);
        }
      });
    }
    super.onPowerResume();
  }

  @override
  void dispose() {
    windowExtManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
