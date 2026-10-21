import 'package:flutter/material.dart';

void main() {
  runApp(const CounterDeepApp());
}

/// 应用根 Widget —— 一个 [StatelessWidget]。
///
/// 它只负责应用级配置（title / theme / home），自身不持有任何可变状态，
/// 因此用 StatelessWidget 即可，符合“能 Stateless 就 Stateless”的选择原则。
class CounterDeepApp extends StatelessWidget {
  const CounterDeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'counter_deep',
      // 主题定制：改这一处种子色，全应用的按钮、水波纹、AppBar 会同步变化。
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CounterPage(),
    );
  }
}

/// 计数器页面 —— 一个 [StatefulWidget]。
///
/// 它本身只做一件事：创建并返回 State 对象；可变数据与逻辑都住在 State 里。
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  /// 可变状态 1：当前计数。
  int _count = 0;

  /// 可变状态 2：当前步长（1 / 2 / 5）。
  int _step = 1;

  // ------------------------------------------------------------------
  // 生命周期日志：每个钩子打印一行，配合热重载(r)与热重启(R)观察执行顺序。
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    debugPrint('[lifecycle] initState'); // 一次性初始化（订阅、控制器等）
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('[lifecycle] didChangeDependencies'); // 依赖变化（如主题、InheritedWidget）
  }

  @override
  void didUpdateWidget(CounterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('[lifecycle] didUpdateWidget'); // 父级重建并传入新配置
  }

  @override
  void dispose() {
    debugPrint('[lifecycle] dispose'); // 销毁清理（取消订阅、释放控制器）
    super.dispose();
  }

  // ------------------------------------------------------------------
  // 状态修改：setState 回调里只放“改数据”，不放耗时操作。
  // ------------------------------------------------------------------

  void _addStep() => setState(() => _count += _step);

  void _pickStep(int step) => setState(() => _step = step);

  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    debugPrint('[lifecycle] build  count=$_count step=$_step');

    // Theme.of(context) 取用 1：配色方案（主色用于计数文字）。
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Theme.of(context) 取用 2：文本主题（用于计数文字字号）。
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('counter_deep'),
        // 资源替换：把自定义图片（assets/images/logo.jpg）铺作 AppBar 背景。
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
            // 压一层渐变遮罩，保证标题在图片上仍然清晰可读。
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x99000000)],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 自定义 StatelessWidget：纯按入参渲染，无内部可变状态。
            CountDisplay(
              count: _count,
              style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('当前步长：$_step', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            // 自定义 StatelessWidget：步长弹层选择器（1 / 2 / 5）。
            StepSelector(step: _step, onSelected: _pickStep),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('重置'),
            ),
          ],
        ),
      ),
      // FAB 每次按当前步长累加（等价于“每点 +step”）。
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStep,
        icon: const Icon(Icons.add),
        label: Text('+$_step'),
      ),
    );
  }
}

/// 自定义 [StatelessWidget]：只根据入参 count 渲染计数文字。
class CountDisplay extends StatelessWidget {
  const CountDisplay({super.key, required this.count, this.style});

  final int count;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text('$count', style: style);
  }
}

/// 自定义 [StatelessWidget]：步长弹层选择器，点击后弹出 1 / 2 / 5。
class StepSelector extends StatelessWidget {
  const StepSelector({super.key, required this.step, required this.onSelected});

  final int step;
  final ValueChanged<int> onSelected;

  static const List<int> options = <int>[1, 2, 5];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: '选择步长',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        for (final int option in options)
          PopupMenuItem<int>(value: option, child: Text('步长 $option')),
      ],
      child: Chip(
        avatar: const Icon(Icons.speed, size: 18),
        label: Text('步长：$step（点击选择 1/2/5）'),
      ),
    );
  }
}
