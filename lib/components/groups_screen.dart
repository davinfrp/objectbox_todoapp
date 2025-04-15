import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

import '../models/group.dart';
import '../objectbox.g.dart';
import 'add_group_screen.dart';
import 'tasks_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groups = <Group>[];
  late final Store _store;
  late final Box<Group> _groupsBox;

  Future<void> _addGroup() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const AddGroupScreen(),
    );

    if (result != null && result is Group) {
      _groupsBox.put(result);
      _loadGroups();
    }
  }

  void _loadGroups() {
    _groups.clear();
    setState(() {
      _groups.addAll(_groupsBox.getAll());
    });
  }

  Future<void> _loadStore() async {
    _store = await openStore();
    _groupsBox = _store.box<Group>();
    _loadGroups();
  }

  Future<void> _goToTasks(Group group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TasksScreen(group: group, store: _store),
      ),
    );

    _loadGroups();
  }

  void _deleteGroup(Group group) {
    _groupsBox.remove(group.id);
    _loadGroups();
  }

  @override
  void initState() {
    _loadStore();
    super.initState();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TODO List')),
      body:
          _groups.isEmpty
              ? const Center(child: Text('There are no Groups'))
              : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _GroupItem(
                      group: group,
                      onTap: () => _goToTasks(group),
                      onDelete: () => _deleteGroup(group),
                    ),
                  );
                },
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add group'),
        onPressed: _addGroup,
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({
    required this.group,
    required this.onTap,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  final Group group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final description = group.tasksDescription();
    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                color: Color(group.color),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }
}
