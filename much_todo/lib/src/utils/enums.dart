import 'package:flutter/material.dart';

enum TaskSortOptions {
	name(0, 'Name'),
	priority(1, 'Priority'),
	effort(2, 'Effort'),
	room(3, 'Room Name'),
	cost(4, 'Estimated Cost'),
	creationDate(5, 'Creation Date'),
	dueBy(6, 'Due By'), // todo refactor to completeBy
	inProgress(7, 'In Progress');

	const TaskSortOptions(this.value, this.label);

	final int value; 
	final String label;
}

enum RoomSortOptions {
	name(0, 'Name'),
	taskCount(1, 'Task Count'),
	totalCost(2, 'Total Cost'),
	creationDate(3, 'Creation Date');

	const RoomSortOptions(this.value, this.label);

	final int value; 
	final String label;
}

enum SortDirection {
	descending(0, Icon(Icons.arrow_downward)),
	ascending(1, Icon(Icons.arrow_upward));

	const SortDirection(this.value, this.widget);

	final int value; 
	final Widget widget;
}

enum EqualityComparisons {
	greaterThan(0, '>'),
	greaterThanOrEqualTo(1, '≥'),
	equalTo(2, '='),
	lessThan(3, '<'),
	lessThanOrEqualTo(4, '≤');

	const EqualityComparisons(this.value, this.label);

	final int value; 
	final String label;
}

enum DateEqualityComparisons {
	after(0, '>'),
	equalTo(1, '='),
	before(2, '<');

	const DateEqualityComparisons(this.value, this.label);

	final int value; 
	final String label;
}

enum PriorityFilter {
	one(1, '1'),
	two(2, '2'),
	three(3, '3'),
	four(4, '4'),
	five(5, '5');

	const PriorityFilter(this.value, this.label);

	final int value; 
	final String label;
}

enum EffortFilter {
	one(1, 'Low'),
	two(2, 'Medium'),
	three(3, 'High');

	const EffortFilter(this.value, this.label);

	final int value; 
	final String label;
}