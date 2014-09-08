AnimeGet
========

irssi, perl, script, to download next anime ep from XDCC bot.

1. place AnimeGet.pl in .irssi/scripts/autorun/
2. make folder .irssi/AnimeGet/
3. place SeriesDB, GetQueue and getconfig in .irssi/AnimeGet
4. Add series to SeriesDB in format: SeriesName::lastepnr::Quality1080p::AlternativeQuality720p
5. GetQueue should be empty
6. getconfig holds the name of the XDCC bot you want to download from
7. set irssi config set auto connect server: autoconnect= "yes";
8. set irssi config set auto join channel: autojoin = "yes";
9. set irssi config set dcc_autoget in your irssi config file under settings: "irc/dcc" = { dcc_autoget = "yes"; dcc_autoget_masks = "XDCCBOTNAME"; };
10. run irssi as deamon.

1. # bot anounces a new download
2. # script checks it against the SeriesDB
3. # add to GetQueue
4. # if not already downloading, than start download
5. # update GetQueue and SeriesDB
