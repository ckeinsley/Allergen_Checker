import 'package:allergen_checker/app_state.dart';
import 'package:allergen_checker/models/checked_image.dart';
import 'package:allergen_checker/widgets/image_result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    late CheckedImage selectedHistory;
    var appState = context.watch<MyAppState>();
    var history = appState.history;

    // Edit Saved Title of Word
    void showEditDialog(BuildContext context, int index) {
      TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: history[index].title),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() {
                    history[index].setTitle(controller.text);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Image History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(history[index].title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showEditDialog(context, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        history.removeAt(index);
                        history.shuffle();
                      });
                    },
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  selectedHistory = history[index];
                });
                // Navigate to a new page to display the selected favorite
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedHistoryPage(selectedHistory),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SelectedHistoryPage extends StatelessWidget {
  final CheckedImage checkedImage;
  final logger = Logger();

  SelectedHistoryPage(this.checkedImage, {super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(checkedImage.title),
        ),
        body: Center(
            child: Column(
              children: [
                ImageResult(
                    checkedWords: checkedImage.checkedWords,
                    image: checkedImage.image),
              ],
            )));
  }
}
