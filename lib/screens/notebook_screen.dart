import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class NotebookListScreen extends StatelessWidget {
  const NotebookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final notes = AppStore.I.notebooks;
        return Scaffold(
          appBar: AppBar(title: const Text('DEFTERLER')),
          floatingActionButton: FloatingActionButton(
            backgroundColor: gold(context),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => NotebookEditor(note: null)),
            ),
            child: const Icon(Icons.add),
          ),
          body: notes.isEmpty
              ? const Center(child: Text('Defter yok. Sınırsız açabilirsin.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final n = notes[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => NotebookEditor(note: n)),
                        ),
                        child: SharpCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(
                                n.body.isEmpty ? 'Boş' : n.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class NotebookEditor extends StatefulWidget {
  final Notebook? note;
  const NotebookEditor({super.key, required this.note});

  @override
  State<NotebookEditor> createState() => _NotebookEditorState();
}

class _NotebookEditorState extends State<NotebookEditor> {
  late final TextEditingController _title;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title ?? '');
    _body = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim().isEmpty ? 'Defter' : _title.text.trim();
    await AppStore.I.saveNotebook(Notebook(
      id: widget.note?.id ?? newId(),
      title: title,
      body: _body.text,
      updated: dateKey(DateTime.now()),
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _save();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DEFTER'),
          actions: [
            if (widget.note != null)
              IconButton(
                onPressed: () async {
                  await AppStore.I.deleteNotebook(widget.note!.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _body,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(labelText: 'İçerik', alignLabelWithHint: true),
                ),
              ),
              const SizedBox(height: 12),
              GoldButton(label: 'KAYDET', onTap: _save),
            ],
          ),
        ),
      ),
    );
  }
}
