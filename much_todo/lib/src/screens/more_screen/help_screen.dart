import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        scrolledUnderElevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Tasks'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'Tasks are the bread and butter of Much To Do. They can be as broad or specific as you want them to be. The intention is for them to be used to track tasks that need doing around the house.\n\nYou must always associate a task with a given room. You can edit or duplicate a task by opening it, and can always edit it after creation.'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Rooms'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'At this time, rooms are only used for the purpose of separating tasks. Similar to tasks, rooms can be as generic as you want them to be. They can be inside or outside, small or large.'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Filtering'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'Harness the power of Much To Do by filtering tasks from the Task page on the home screen. You are able to apply filters to most components of a task (exceptions such as photos and links at this time).'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Completing Tasks'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'Once a task is done you can complete it either by opening it and clicking the complete button, or by swiping left on the task. Completing a task is essentially a soft delete. Photos associated with it will be deleted, and it will no longer be visible except from the completed tasks screen (accessible by specific room or the more screen)'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Random Task'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'Can\'t decide what to do next? Click the dice button to pick a random task! Note it will only pick a random task according to any filters that are applied.'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                // removes weird borders that are enabled by default on expansion tile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Upload Photos'),
                  textColor: Theme.of(context).colorScheme.primary,
                  children: [
                    const Divider(),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                              'A picture is worth a thousand words. You can add up to ${Constants.maxTaskPhotos} photos on a task to help describe what needs to be done.\n\n'
                              'Do note that each user is limited to a certain amount of storage. Pictures can be deleted at any time either directly on the task, or by visiting the uploaded photos page.'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
