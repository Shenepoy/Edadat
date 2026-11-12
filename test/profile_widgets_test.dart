import 'package:material_ui/material_ui.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('ProfileSettingsCard shows title and invokes tap and action', (
    tester,
  ) async {
    var tapped = false;
    var edited = false;

    await tester.pumpWidget(
      _wrap(
        ProfileSettingsCard(
          leading: const CircleAvatar(child: Text('A')),
          title: const Text('Ada Lovelace'),
          subtitle: const Text('ada@example.com'),
          onTap: () => tapped = true,
          actions: [
            ProfileSettingsAction(
              icon: Icons.edit_outlined,
              tooltip: 'Edit',
              onPressed: () => edited = true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);

    await tester.tap(find.text('Ada Lovelace'));
    expect(tapped, isTrue);

    await tester.tap(find.byTooltip('Edit'));
    expect(edited, isTrue);
  });

  testWidgets('ProfileKpiStrip shows labels and values', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ProfileKpiStrip(
          items: const [
            ProfileKpiItem(
              icon: Icons.devices_outlined,
              label: 'Devices',
              value: '4',
            ),
            ProfileKpiItem(
              icon: Icons.notifications_outlined,
              label: 'Unread',
              value: '2',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Unread'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('ProfileKpiStrip scrolls horizontally when chips overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 240,
          child: ProfileKpiStrip(
            items: [
              ProfileKpiItem(
                icon: Icons.devices_outlined,
                label: 'Devices',
                value: '4',
              ),
              ProfileKpiItem(
                icon: Icons.star_outline,
                label: 'Shortcuts',
                value: '2',
              ),
              ProfileKpiItem(
                icon: Icons.archive_outlined,
                label: 'Archived',
                value: '1',
              ),
              ProfileKpiItem(
                icon: Icons.drafts_outlined,
                label: 'Drafts',
                value: '3',
              ),
            ],
          ),
        ),
      ),
    );

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ProfileKpiStrip),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.axis, Axis.horizontal);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    final start = scrollable.position.pixels;
    await tester.drag(find.byType(ProfileKpiStrip), const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(start));
  });

  testWidgets('ProfileBudgetCard applies attention color to the bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ProfileBudgetCard(
          title: Text('Downloads'),
          caption: Text('Monthly limit'),
          limit: Text('80 MB'),
          spent: Text('Used: 96 MB'),
          progress: 1.2,
          attention: ProfileBudgetAttention.over,
        ),
      ),
    );

    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('80 MB'), findsOneWidget);

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    final scheme = Theme.of(tester.element(find.byType(ProfileBudgetCard)))
        .colorScheme;
    expect(bar.color, scheme.error);
    expect(bar.value, 1);
  });

  testWidgets('ProfileNotificationTile tap and unread weight', (tester) async {
    var opened = false;

    await tester.pumpWidget(
      _wrap(
        ProfileNotificationTile(
          title: const Text('New sign-in'),
          subtitle: const Text('Chrome on this device'),
          unread: true,
          onTap: () => opened = true,
        ),
      ),
    );

    final style = DefaultTextStyle.of(tester.element(find.text('New sign-in')))
        .style;
    expect(style.fontWeight, FontWeight.w700);

    await tester.tap(find.text('New sign-in'));
    expect(opened, isTrue);
  });

  testWidgets('ProfileHeroMetric shows caption status value and footnote', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ProfileHeroMetric(
          caption: 'Plan usage',
          status: 'On track',
          value: '78%',
          footnote: '3 devices synced',
          tone: ProfileHeroTone.positive,
        ),
      ),
    );

    expect(find.text('Plan usage'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('3 devices synced'), findsOneWidget);
  });

  testWidgets('ProfileSectionHeader trailing tap', (tester) async {
    var seen = false;
    await tester.pumpWidget(
      _wrap(
        ProfileSectionHeader(
          title: const Text('Sessions'),
          trailing: TextButton(
            onPressed: () => seen = true,
            child: const Text('See all'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('See all'));
    expect(seen, isTrue);
  });

  testWidgets('ProfileStatusBanner uses warning accent', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ProfileStatusBanner(
          tone: ProfileBannerTone.warning,
          title: Text('Check backup'),
        ),
      ),
    );
    final banner = tester.widget<Container>(
      find.descendant(
        of: find.byType(ProfileStatusBanner),
        matching: find.byType(Container),
      ),
    );
    final scheme = Theme.of(tester.element(find.byType(ProfileStatusBanner)))
        .colorScheme;
    final decoration = banner.decoration! as BoxDecoration;
    expect(decoration.border, isA<Border>());
    expect((decoration.border! as Border).top.color.a, greaterThan(0));
    expect(
      (decoration.color ?? scheme.surface).toARGB32(),
      scheme.tertiary.withValues(alpha: 0.12).toARGB32(),
    );
  });

  testWidgets('ProfilePlaceholder kinds', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ProfilePlaceholder(
          kind: ProfilePlaceholderKind.loading,
          title: Text('Loading'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const ProfilePlaceholder(
          kind: ProfilePlaceholderKind.empty,
          icon: Icon(Icons.inbox_outlined),
          title: Text('Nothing here'),
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('ProfileSessionTile shows current badge', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ProfileSessionTile(
          title: Text('This laptop'),
          current: true,
          badge: Text('This device'),
        ),
      ),
    );
    expect(find.text('This device'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
  });

  testWidgets('ProfileLinkedAccountTile shows connected status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ProfileLinkedAccountTile(
          title: Text('Google'),
          connected: true,
          status: Text('Connected'),
        ),
      ),
    );
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('ProfileActionTile destructive tap', (tester) async {
    var signedOut = false;
    await tester.pumpWidget(
      _wrap(
        ProfileActionTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          destructive: true,
          onTap: () => signedOut = true,
        ),
      ),
    );
    final theme = Theme.of(tester.element(find.byType(ProfileActionTile)));
    final icon = tester.widget<Icon>(find.byIcon(Icons.logout));
    expect(
      icon.color ??
          IconTheme.of(tester.element(find.byIcon(Icons.logout))).color,
      theme.colorScheme.error,
    );
    await tester.tap(find.text('Sign out'));
    expect(signedOut, isTrue);
  });

  testWidgets('ProfilePlanCard shows name and status', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ProfilePlanCard(
          name: Text('Free plan'),
          status: Text('Active'),
          footnote: Text('Does not renew'),
        ),
      ),
    );
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Does not renew'), findsOneWidget);
  });

  testWidgets('ProfileChipRow reports selection', (tester) async {
    var picked = '';
    await tester.pumpWidget(
      _wrap(
        ProfileChipRow(
          chips: [
            ProfileChip(
              label: const Text('All'),
              selected: true,
              onTap: () => picked = 'all',
            ),
            ProfileChip(
              label: const Text('Security'),
              onTap: () => picked = 'security',
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Security'));
    expect(picked, 'security');
  });

  testWidgets('ProfileCopyRow invokes onCopy', (tester) async {
    var copied = false;
    await tester.pumpWidget(
      _wrap(
        ProfileCopyRow(
          label: const Text('Account ID'),
          value: const Text('ada-1042'),
          copyTooltip: 'Copy',
          onCopy: () => copied = true,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Copy'));
    expect(copied, isTrue);
  });

  testWidgets('ProfileStatGrid shows values', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ProfileStatGrid(
          items: const [
            ProfileStatItem(label: Text('Settings'), value: Text('12')),
            ProfileStatItem(label: Text('Languages'), value: Text('2')),
          ],
        ),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('ProfileSecurityTile ok vs warning icons', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ProfileSecurityTile(title: Text('Two-factor'), ok: true),
            ProfileSecurityTile(title: Text('Recovery email'), ok: false),
          ],
        ),
      ),
    );
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });
}
