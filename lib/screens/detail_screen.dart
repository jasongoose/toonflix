import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_detail.dart';
import 'package:toonflix/models/webtoon_episode.dart';
import 'package:toonflix/models/webtoon_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/webtoon_episode.dart';

class DetailScreen extends StatefulWidget {
  final WebtoonModel webtoon;

  const DetailScreen({
    super.key,
    required this.webtoon,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoonDetail;
  late Future<List<WebtoonEpisodeModel>> webtoonEpisodes;
  late SharedPreferences prefs;
  bool isLiked = false;
  static final String likedToonsKey = 'likedToons';

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList(likedToonsKey);

    if (likedToons != null) {
      if (likedToons.contains(widget.webtoon.id)) {
        // 여길 기점으로 리빌드 실행
        // initState -> build -> initPrefs -> build
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList(likedToonsKey, []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoonDetail = ApiService.getToonById(widget.webtoon.id);
    webtoonEpisodes = ApiService.getLatestEpisodesById(widget.webtoon.id);
    initPrefs();
  }

  void onHeartTap() async {
    final likedToons = await prefs.getStringList(likedToonsKey);

    if (likedToons!.contains(widget.webtoon.id)) {
      likedToons.remove(widget.webtoon.id);
    } else {
      likedToons.add(widget.webtoon.id);
    }
    await prefs.setStringList(likedToonsKey, likedToons);
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.webtoon.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.webtoon.id,
                    child: Container(
                      width: 250,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            offset: Offset(10, 10),
                            color: Colors.black.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ],
                      ),
                      child: Image.network(
                        widget.webtoon.thumb,
                        headers: {
                          "Referer": "https://comic.naver.com",
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              FutureBuilder(
                future: webtoonDetail,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          '${snapshot.data!.genre} / ${snapshot.data!.age}',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        FutureBuilder(
                          future: webtoonEpisodes,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  for (var episode in snapshot.data!)
                                    WebtonnEpisode(
                                      episode: episode,
                                      webtoonId: widget.webtoon.id,
                                    ),
                                ],
                              );
                            }
                            return Container();
                          },
                        )
                      ],
                    );
                  }
                  return Text("...");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
