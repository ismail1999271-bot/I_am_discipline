import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class FilmScreen extends StatefulWidget {
  const FilmScreen({super.key});

  @override
  State<FilmScreen> createState() => _FilmScreenState();
}

class _FilmScreenState extends State<FilmScreen> {
  bool watched = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final list = AppStore.I.films.where((f) => f.watched == watched).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('FİLMLER')),
          floatingActionButton: FloatingActionButton(
            backgroundColor: gold(context),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            onPressed: () => _add(context),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: GoldButton(label: 'İZLENECEK', filled: !watched, onTap: () => setState(() => watched = false))),
                    const SizedBox(width: 8),
                    Expanded(child: GoldButton(label: 'İZLENEN', filled: watched, onTap: () => setState(() => watched = true))),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Liste boş.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _Tile(film: list[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _add(BuildContext context) async {
    final title = await askText(context, title: 'FİLM', hint: 'Ad');
    if (title == null || title.isEmpty) return;
    await AppStore.I.saveFilm(FilmItem(
      id: newId(),
      title: title,
      watched: watched,
      rating: 0,
      note: '',
    ));
  }
}

class _Tile extends StatelessWidget {
  final FilmItem film;
  const _Tile({required this.film});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SharpCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(film.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            if (film.note.isNotEmpty) Text(film.note, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                for (var n = 1; n <= 10; n++)
                  InkWell(
                    onTap: () => AppStore.I.saveFilm(film.copyWith(rating: n)),
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: film.rating == n ? gold(context) : Colors.transparent,
                        border: Border.all(color: gold(context)),
                      ),
                      child: Text(
                        '$n',
                        style: TextStyle(
                          color: film.rating == n ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GoldButton(
                    label: film.watched ? 'İZLENECEĞE AL' : 'İZLENDİ',
                    filled: false,
                    onTap: () => AppStore.I.saveFilm(film.copyWith(watched: !film.watched)),
                  ),
                ),
                IconButton(onPressed: () => _note(context), icon: const Icon(Icons.edit)),
                IconButton(onPressed: () => AppStore.I.deleteFilm(film.id), icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _note(BuildContext context) async {
    final text = await askText(context, title: 'NOT', initial: film.note, maxLines: 3);
    if (text == null) return;
    await AppStore.I.saveFilm(film.copyWith(note: text));
  }
}
