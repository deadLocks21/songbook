import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/pages/song_list_viewer/providers/song_list_viewer.provider.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('SongListViewerPage', () {
    testWidgets('should display first song on load', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(
            songId: 'song-1',
            songName: 'Amazing Grace',
            songCode: 'AG01',
          )
          .withSongEntry(
            songId: 'song-2',
            songName: 'Holy Spirit',
            songCode: 'HS01',
          )
          .build();

      final songs = [
        aSong()
            .withId('song-1')
            .withCode('AG01')
            .withName('Amazing Grace')
            .build(),
        aSong()
            .withId('song-2')
            .withCode('HS01')
            .withName('Holy Spirit')
            .build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(tester, viewerData: viewerData))
          .expectSongCodeIs('AG01')
          .expectSongNameIs('Amazing Grace')
          .expectPositionIs('1/2')
          .execute();
    });

    testWidgets('should navigate to next song', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'S01')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'S02')
          .withSongEntry(songId: 'song-3', songName: 'Song 3', songCode: 'S03')
          .build();

      final songs = [
        aSong().withId('song-1').withCode('S01').withName('Song 1').build(),
        aSong().withId('song-2').withCode('S02').withName('Song 2').build(),
        aSong().withId('song-3').withCode('S03').withName('Song 3').build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(tester, viewerData: viewerData))
          .expectPositionIs('1/3')
          .tapNextButton()
          .expectPositionIs('2/3')
          .expectSongCodeIs('S02')
          .execute();
    });

    testWidgets('should navigate to previous song', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'S01')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'S02')
          .build();

      final songs = [
        aSong().withId('song-1').withCode('S01').withName('Song 1').build(),
        aSong().withId('song-2').withCode('S02').withName('Song 2').build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(tester, viewerData: viewerData))
          .tapNextButton()
          .expectPositionIs('2/2')
          .tapPreviousButton()
          .expectPositionIs('1/2')
          .expectSongCodeIs('S01')
          .execute();
    });

    testWidgets('should hide previous button on first song', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'S01')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'S02')
          .build();

      final songs = [
        aSong().withId('song-1').withCode('S01').withName('Song 1').build(),
        aSong().withId('song-2').withCode('S02').withName('Song 2').build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(
        tester,
        viewerData: viewerData,
      )).expectPreviousButtonNotVisible().expectNextButtonVisible().execute();
    });

    testWidgets('should hide next button on last song', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'S01')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'S02')
          .build();

      final songs = [
        aSong().withId('song-1').withCode('S01').withName('Song 1').build(),
        aSong().withId('song-2').withCode('S02').withName('Song 2').build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(tester, viewerData: viewerData))
          .tapNextButton()
          .expectNextButtonNotVisible()
          .expectPreviousButtonVisible()
          .execute();
    });

    testWidgets('should hide both buttons with single song', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'S01')
          .build();

      final songs = [
        aSong().withId('song-1').withCode('S01').withName('Song 1').build(),
      ];

      final viewerData = SongListViewerData(songList: songList, songs: songs);

      await (await startInSongListViewerPage(tester, viewerData: viewerData))
          .expectPreviousButtonNotVisible()
          .expectNextButtonNotVisible()
          .expectPositionIs('1/1')
          .execute();
    });
  });
}
