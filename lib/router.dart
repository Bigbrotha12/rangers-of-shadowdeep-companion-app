import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/ui/core/navigation/scaffold_with_nav_bar.dart';
import 'package:rangers_mobile/ui/features/companions/views/assign_skill_bonus_view.dart';
import 'package:rangers_mobile/ui/features/companions/views/companion_detail_view.dart';
import 'package:rangers_mobile/ui/features/companions/views/companion_progression_view.dart';
import 'package:rangers_mobile/ui/features/companions/views/companion_types_browser.dart';
import 'package:rangers_mobile/ui/features/companions/views/recruit_companions_view.dart';
import 'package:rangers_mobile/ui/features/rangers/views/ranger_creation_wizard.dart';
import 'package:rangers_mobile/ui/features/rangers/views/ranger_detail_view.dart';
import 'package:rangers_mobile/ui/features/rangers/views/rangers_list_view.dart';
import 'package:rangers_mobile/ui/features/reference/views/quick_reference_card_view.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_category_view.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_detail_view.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_home_view.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_search_view.dart';
import 'package:rangers_mobile/ui/features/session/views/post_game_view.dart';
import 'package:rangers_mobile/ui/features/session/views/session_active_view.dart';
import 'package:rangers_mobile/ui/features/session/views/session_list_view.dart';
import 'package:rangers_mobile/ui/features/session/views/session_setup_view.dart';
import 'package:rangers_mobile/ui/features/settings/views/settings_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/rangers',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rangers',
              builder: (context, state) => const RangersListView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/session',
              builder: (context, state) => const SessionListView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reference',
              builder: (context, state) => const ReferenceHomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsView(),
            ),
          ],
        ),
      ],
    ),
    // Ranger creation wizard
    GoRoute(
      path: '/rangers/create',
      builder: (context, state) => const RangerCreationWizardView(),
    ),
    // Ranger detail
    GoRoute(
      path: '/rangers/:rangerId',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        return RangerDetailView(rangerId: rangerId);
      },
    ),
    // Companion routes
    GoRoute(
      path: '/rangers/:rangerId/companions',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        return CompanionTypesBrowser(rangerId: rangerId);
      },
    ),
    GoRoute(
      path: '/rangers/:rangerId/companions/recruit',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        final baseRecruitmentPoints = state.uri.queryParameters['brp'] != null
            ? int.parse(state.uri.queryParameters['brp']!)
            : 100;
        return RecruitCompanionsView(
          rangerId: rangerId,
          baseRecruitmentPoints: baseRecruitmentPoints,
        );
      },
    ),
    GoRoute(
      path: '/rangers/:rangerId/companions/:companionId',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        final companionId = int.parse(state.pathParameters['companionId']!);
        return CompanionDetailView(
          rangerId: rangerId,
          companionId: companionId,
        );
      },
    ),
    GoRoute(
      path: '/rangers/:rangerId/companions/:companionId/assign-skill',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        final companionId = int.parse(state.pathParameters['companionId']!);
        return AssignSkillBonusView(
          rangerId: rangerId,
          companionId: companionId,
        );
      },
    ),
    GoRoute(
      path: '/rangers/:rangerId/companions/:companionId/progression',
      builder: (context, state) {
        final rangerId = int.parse(state.pathParameters['rangerId']!);
        final companionId = int.parse(state.pathParameters['companionId']!);
        return CompanionProgressionView(
          rangerId: rangerId,
          companionId: companionId,
        );
      },
    ),
    // Reference routes
    GoRoute(
      path: '/reference/search',
      builder: (context, state) => const ReferenceSearchView(),
    ),
    GoRoute(
      path: '/reference/quick_reference/:entryId',
      builder: (context, state) {
        final entryId = state.pathParameters['entryId']!;
        return QuickReferenceCardView(entryId: entryId);
      },
    ),
    GoRoute(
      path: '/reference/:categoryKey',
      builder: (context, state) {
        final categoryKey = state.pathParameters['categoryKey']!;
        return ReferenceCategoryView(categoryKey: categoryKey);
      },
      routes: [
        GoRoute(
          path: ':entryId',
          builder: (context, state) {
            final categoryKey = state.pathParameters['categoryKey']!;
            final entryId = state.pathParameters['entryId']!;
            return ReferenceDetailView(
              categoryKey: categoryKey,
              entryId: entryId,
            );
          },
        ),
      ],
    ),
    // Session routes
    GoRoute(
      path: '/session/setup',
      builder: (context, state) => const SessionSetupView(),
    ),
    GoRoute(
      path: '/session/active/:sessionId',
      builder: (context, state) {
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        return SessionActiveView(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/session/post-game/:sessionId',
      builder: (context, state) {
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        return PostGameView(sessionId: sessionId);
      },
    ),
  ],
);
