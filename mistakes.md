Biggest Missing Concept
Right now your screen is basically:
UI only
There is no state.
No list.
No filtering.
No adding tasks.
No deleting tasks.
No completion toggle.
That is completely normal for Day 1 of the project.
The next step should be:
List<Task> tasks = [
  Task(
    title: 'Workout',
    description: 'Gym',
  ),
];
Store task data in a list and generate cards using ListView.builder.
That is where the real Flutter learning starts. Right now you've done the UI foundation, which is a solid start.