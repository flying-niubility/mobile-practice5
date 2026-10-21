// counter_deep 的 Widget 测试。
//
// 这里直接测试自定义 StatelessWidget（CountDisplay / StepSelector），
// 不加载图片资源，避免测试环境下的资源绑定问题。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_deep/main.dart';

void main() {
  testWidgets('点击 FAB 按当前步长累加，切换步长 2 后每次 +2', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterPage()));

    // 初始：计数 0，步长 1
    expect(find.text('0'), findsOneWidget);

    // 点一次 FAB：0 → 1
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // 打开步长弹层，选择步长 2
    await tester.tap(find.byType(PopupMenuButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('步长 2').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('当前步长：2'), findsOneWidget);

    // 再点一次 FAB：1 → 3
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('CountDisplay 按入参渲染计数', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CountDisplay(count: 7)));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('StepSelector 点击弹层可选步长', (WidgetTester tester) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepSelector(step: 1, onSelected: (int value) => picked = value),
        ),
      ),
    );

    expect(find.textContaining('步长：1'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('步长 5').last);
    await tester.pumpAndSettle();

    expect(picked, 5);
  });
}
