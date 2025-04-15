# To Do Application using Flutter and ObjectBox

**Davin Fisabilillah Reynard Putra - 5025221137**

Mobile Programming (C)

On this assignment, due to my nrp being modulo by 4 is equal to 1. I am using **ObjectBox** as my database. ObjectBox is a high-performance NoSQL database designed specifically for mobile and embedded applications. It provides a fast and efficient way to persist data locally in Flutter apps. The app that i created to connect with the database is a grouped to do app. In the homepage, the users will be able to see the group of the task they created (e.g work, school, etc) and they have an option to add another group by interacting with a button located on the below portion of the app. When clicked, users will be able to create a name for the group and choose the color for the group button. Users then can see the task in each group by clicking the group and transfering to another page where the task for selected group are listed. The users have the option to add another task, checking the checkbox to signaling a task is done, and deleting a task. That is basically the explanation of the UI portion of the project, i will be explaining the logic and implementation of the database below.

## Setting up dependencies
To use ObjectBox in a flutter project, we have to add some lines in `pubsec.yaml`
```dart
dependencies:
  flutter:
    sdk: flutter
  objectbox: ^4.1.0
  objectbox_flutter_libs: any
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.0.0
  objectbox_generator: any
```
Because i am building an Android app, i will need to increase the NDK Version in `/android/app/build.gradle.kts`
```dart
android {
    ...
    ndkVersion = "27.0.12077973"
    ...
}
```

To install the packages, we need to run this command
```dart
flutter pub get
```

# Creating Entity
In this project, i defined two entites which is `Task` and `Group` which forms a one-to-many relationship. What that means is a group can have multiple task but a task can be only in 1 group. 

## Task.dart
```dart
import 'package:objectbox/objectbox.dart';

import 'group.dart';

@Entity()
class Task {
  int id = 0;
  String description;
  bool completed = false;

  final group = ToOne<Group>();

  Task({required this.description});
}
```
The Task class represents individual tasks and in objectbox, it is marked with the `@Entity()` annotation to indicate it's a database model. Each task has an id and if you set the id value to 0, it will auto-generate another id incrementally for the next data. The task also has a description string, and a completed boolean to know if the task is completed or not. A Task also includes a ToOne<Group> field named group, which establishes a one-to-one relationship indicating that each task belongs to a single group.

## group.dart
```dart
import 'package:objectbox/objectbox.dart';

import 'task.dart';

@Entity()
class Group {
  int id = 0;
  String name;
  int color;

  @Backlink()
  final tasks = ToMany<Task>();

  Group({required this.name, required this.color});

  String tasksDescription() {
    final tasksCompleted = tasks.where((task) => task.completed).length;
    if (tasks.isEmpty) {
      return '';
    }
    return '$tasksCompleted of ${tasks.length}';
  }
}

```
the Group class represents the groupings of tasks. It includes an id, a name string, and a color integer, used for the visual of the groups in the UI. The Group class has a ToMany<Task> collection called tasks, which is annotated with @Backlink(). This tells ObjectBox to automatically populate this list based on the tasks that reference the group from their ToOne relationship. This setup ensures that a single group can contain multiple tasks, effectively creating a one-to-many relationship. Additionally, the Group class provides a helper method, tasksDescription(), which returns a string indicating how many of its tasks are completed out of the total, such as "2 of 5". If the group has no tasks, it returns an empty string.

Then we need to run this command to generate helper files for ObjectBox that defines how these classes are stored in the database. It will create `objectbox.g.dart` and `objectbox-model.json`
```dart
flutter pub run build_runner build
```

# CRUD Method with ObjectBox

## Group Screen
`groups_screen.dart` serves as the homepage where users can view, add, and delete groups that contain tasks. First, we need to set up the database Store and opening a `Box<Group>`, which acts like a table for storing Group objects in ObjectBox. This is done asynchronously in the `_loadStore()` method during the `initState()` lifecycle, ensuring the data is ready when the UI is rendered. Once the ObjectBox store is initialized, the `_loadGroups()` method reads all existing Group records from the box using `getAll()` and updates the local group list. To create a new group, the method that is used is `_addGroup()`. If the user press the add group button, it will display a dialog screen. If a new group object is created, `_groupsBox.put(result)` will save it to the database then reloads the list to update the UI. To delete a group, the `_deleteGroup()` method is used and erase the object from the database using remove(group.id). Each group is displayed in a grid using `_GroupItem`, a custom widget that renders the group’s name, color, and task completion status (from group.tasksDescription()), along with a delete button.

## Add Group Screen
`add_group_screen.dart` serves as the screen where the users can create a new group. The screen is a alert dialog where user can input a group name and choose a color for the visualisation. Once the user submit the form, a new object is created and the user will be transferred back to the homepage. The method that was being used for the form validation and object creation is `_onSave()`. Instead of inserting it directly to the database, the object will be passed to the `group_screen.dart` where it handle the insertion by calling `put(result)` on the `Box<Group>` it manages.

## Task Screen
`tasks_screen.dart` serves as the screen where the users can view, add, mark as complete, and delete a task entities in a group. First, we need to initialized with a `Group` and an `ObjectBox Store`, and it uses the `Box<Task>` to interact with the database. The `initState` method loads the list of tasks associated with the group using the `group.tasks` relationship. `_reloadTasks()` method is used throughout the file to fetch fresh data. This method constructs a query using ObjectBox’s query builder to find tasks that are linked to the current group `(builder.link(...))`, executes it, and fill the `_tasks` list. The Create operation is handled in `_onSave()`. When a user submits a new task, a new task object will be created and it will be associated to its group with `group.target`. This object then will be inserted to the database using `box.put(task)`. For each task, the user has the ability to mark a task as done by clicking the checkbox. It will give a line through the text of the marked task. The method `_onUpdate()` will update the `completed` atribute of the selected task and save the changes using box.put(task). Lastly, the user is also able to delete a task by clicking the delete icon. The `_onDelete()` method removes a task from the database using `box.remove(task.id)`.

# References that was used to create this project
* https://www.youtube.com/watch?v=6YPSQPS_bhU
* https://medium.com/@nandhuraj/building-a-simple-note-app-with-flutter-and-objectbox-9186aa0f14bc
* https://github.com/eliezerantonio/objectbox_example_flutter
