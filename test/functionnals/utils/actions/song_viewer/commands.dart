import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Commande pour vérifier le code du chant affiché.
class ExpectSongCodeIsCommand extends FluentCommand {
  final WidgetTester tester;
  final SongViewerPageFinders finders;
  final String expectedCode;

  ExpectSongCodeIsCommand(this.tester, this.finders, this.expectedCode);

  @override
  Future<void> execute() async {
    final textWidget = tester.widget<Text>(finders.songCode);
    expect(
      textWidget.data,
      expectedCode,
      reason: 'Song code should be $expectedCode',
    );
  }
}

/// Commande pour vérifier le nom du chant affiché.
class ExpectSongNameIsCommand extends FluentCommand {
  final WidgetTester tester;
  final SongViewerPageFinders finders;
  final String expectedName;

  ExpectSongNameIsCommand(this.tester, this.finders, this.expectedName);

  @override
  Future<void> execute() async {
    final textWidget = tester.widget<Text>(finders.songName);
    expect(
      textWidget.data,
      expectedName,
      reason: 'Song name should be $expectedName',
    );
  }
}

/// Commande pour vérifier que le visualiseur d'images est visible.
class ExpectImageViewerVisibleCommand extends FluentCommand {
  final SongViewerPageFinders finders;

  ExpectImageViewerVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.imageViewer,
      findsOneWidget,
      reason: 'Image viewer should be visible',
    );
  }
}

/// Commande pour vérifier que le message "aucune partition" est visible.
class ExpectNoImageMessageVisibleCommand extends FluentCommand {
  final SongViewerPageFinders finders;

  ExpectNoImageMessageVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.noImageMessage,
      findsOneWidget,
      reason: 'No image message should be visible',
    );
  }
}

/// Commande pour taper sur le bouton retour.
class TapBackButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongViewerPageFinders finders;

  TapBackButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.backButton);
    await tester.pumpAndSettle();
  }
}
