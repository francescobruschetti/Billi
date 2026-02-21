import 'package:Billy/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() =>
      _CreateGroupPageState();
}

class _CreateGroupPageState
    extends ConsumerState<CreateGroupPage> {

  final controller = TextEditingController();
  bool isLoading = false;

  Future<void> _create() async {
    setState(() => isLoading = true);

    await ref
        .read(groupsProvider.notifier)
        .createGroup(controller.text);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Group name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _create,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create"),
            )
          ],
        ),
      ),
    );
  }
}
