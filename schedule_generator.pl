% Schedule Generator Program in Prolog
% Features: Register/Login, Set Tasks, Generate Schedule, Modify/View Schedule, Save/Export Schedule

:- dynamic user/3. % user(UserID, Password, Name)
:- dynamic task/6. % task(TaskID, UserID, StartTime, Duration, Priority, Description)
:- dynamic logged_in/1. % logged_in(UserID)

% -----------------------------------
% Feature 1: Register & Login (with Verification)
% -----------------------------------

% Register a new user
register_user(UserID, Password, Name) :-
    \+ user(UserID, _, _),
    assertz(user(UserID, Password, Name)),
    write('User registered successfully.'), nl.
register_user(UserID, _, _) :-
    user(UserID, _, _),
    write('Error: User ID already exists.'), nl.

% Login with verification
login_user(UserID, Password) :-
    user(UserID, Password, _),
    \+ logged_in(_), % Ensure no one else is logged in
    assertz(logged_in(UserID)),
    write('Login successful. Welcome, '), 
    user(UserID, _, Name), write(Name), write('.'), nl.
login_user(UserID, _) :-
    user(UserID, _, _),
    logged_in(_),
    write('Error: Another user is already logged in.'), nl.
login_user(UserID, _) :-
    \+ user(UserID, _, _),
    write('Error: User ID does not exist.'), nl.
login_user(UserID, Password) :-
    user(UserID, ActualPassword, _),
    Password \= ActualPassword,
    write('Error: Incorrect password.'), nl.

% Logout
logout :-
    logged_in(UserID),
    retract(logged_in(UserID)),
    write('Logged out successfully.'), nl.
logout :-
    \+ logged_in(_),
    write('Error: No user is logged in.'), nl.

% -----------------------------------
% Feature 2: Set Task Constraints, Preferences, Duration, and Priority
% -----------------------------------

% Add a new task with constraints
add_task(TaskID, StartTime, Duration, Priority, Description) :-
    logged_in(UserID),
    valid_time(StartTime),
    valid_duration(Duration),
    valid_priority(Priority),
    \+ task(TaskID, UserID, _, _, _, _), % Ensure TaskID is unique for user
    check_no_overlap(UserID, StartTime, Duration, TaskID),
    assertz(task(TaskID, UserID, StartTime, Duration, Priority, Description)),
    write('Task added successfully.'), nl.
add_task(_, _, _, _, _) :-
    \+ logged_in(_),
    write('Error: Please log in first.'), nl.
add_task(TaskID, _, _, _, _) :-
    logged_in(UserID),
    task(TaskID, UserID, _, _, _, _),
    write('Error: Task ID already exists for this user.'), nl.
add_task(_, StartTime, _, _, _) :-
    \+ valid_time(StartTime),
    write('Error: Invalid start time (must be between 0 and 2359).'), nl.
add_task(_, _, Duration, _, _) :-
    \+ valid_duration(Duration),
    write('Error: Invalid duration (must be positive).'), nl.
add_task(_, _, _, Priority, _) :-
    \+ valid_priority(Priority),
    write('Error: Invalid priority (must be high, medium, or low).'), nl.
add_task(_, StartTime, Duration, _, _) :-
    logged_in(UserID),
    \+ check_no_overlap(UserID, StartTime, Duration, none),
    write('Error: Task overlaps with existing task.'), nl.

% Validate time (between 00:00 and 23:59)
valid_time(Time) :-
    integer(Time), Time >= 0, Time =< 2359.

% Validate duration (positive integer)
valid_duration(Duration) :-
    integer(Duration), Duration > 0.

% Validate priority (high, medium, low)
valid_priority(Priority) :-
    member(Priority, [high, medium, low]).

% Check for no overlap with existing tasks
check_no_overlap(UserID, StartTime, Duration, TaskID) :-
    EndTime is StartTime + Duration,
    \+ (task(OtherTaskID, UserID, OtherStart, OtherDuration, _, _),
        OtherTaskID \= TaskID,
        OtherEnd is OtherStart + OtherDuration,
        StartTime < OtherEnd,
        EndTime > OtherStart).

% -----------------------------------
% Feature 3: Generate Schedule Diagram
% -----------------------------------

% Generate and display schedule for the logged-in user
generate_schedule :-
    logged_in(UserID),
    findall(task(TaskID, UserID, StartTime, Duration, Priority, Description),
            task(TaskID, UserID, StartTime, Duration, Priority, Description),
            Tasks),
    sort_tasks_by_priority_and_time(Tasks, SortedTasks),
    display_schedule(SortedTasks),
    write('Schedule generated successfully.'), nl.
generate_schedule :-
    \+ logged_in(_),
    write('Error: Please log in first.'), nl.

% Sort tasks by priority (high > medium > low) and then start time
sort_tasks_by_priority_and_time(Tasks, SortedTasks) :-
    predsort(compare_tasks_priority, Tasks, SortedTasks).

compare_tasks_priority(Order, task(_, _, Start1, _, Priority1, _), task(_, _, Start2, _, Priority2, _)) :-
    priority_value(Priority1, Val1),
    priority_value(Priority2, Val2),
    (Val1 \= Val2 -> compare(Order, Val2, Val1) ; compare(Order, Start1, Start2)).

priority_value(high, 3).
priority_value(medium, 2).
priority_value(low, 1).

% Display schedule as a formatted table
display_schedule(Tasks) :-
    write('Schedule:'), nl,
    write('--------------------------------------------------'), nl,
    write('| Task ID | Start Time | Duration | Priority | Description |'), nl,
    write('--------------------------------------------------'), nl,
    display_tasks(Tasks),
    write('--------------------------------------------------'), nl.

display_tasks([]).
display_tasks([task(TaskID, _, StartTime, Duration, Priority, Description)|Rest]) :-
    format('| ~w | ~w | ~w | ~w | ~w |~n', [TaskID, StartTime, Duration, Priority, Description]),
    display_tasks(Rest).

% -----------------------------------
% Feature 4: Modify & View Schedule
% -----------------------------------

% Modify a task's attributes
modify_task(TaskID, NewStartTime, NewDuration, NewPriority, NewDescription) :-
    logged_in(UserID),
    task(TaskID, UserID, _, _, _, _),
    valid_time(NewStartTime),
    valid_duration(NewDuration),
    valid_priority(NewPriority),
    check_no_overlap(UserID, NewStartTime, NewDuration, TaskID),
    retract(task(TaskID, UserID, _, _, _, _)),
    assertz(task(TaskID, UserID, NewStartTime, NewDuration, NewPriority, NewDescription)),
    write('Task modified successfully.'), nl,
    generate_schedule. % Automatically display updated schedule
modify_task(TaskID, _, _, _, _) :-
    logged_in(UserID),
    \+ task(TaskID, UserID, _, _, _, _),
    write('Error: Task ID does not exist.'), nl.
modify_task(_, _, _, _, _) :-
    \+ logged_in(_),
    write('Error: Please log in first.'), nl.
modify_task(_, NewStartTime, _, _, _) :-
    \+ valid_time(NewStartTime),
    write('Error: Invalid start time (must be between 0 and 2359).'), nl.
modify_task(_, _, NewDuration, _, _) :-
    \+ valid_duration(NewDuration),
    write('Error: Invalid duration (must be positive).'), nl.
modify_task(_, _, _, NewPriority, _) :-
    \+ valid_priority(NewPriority),
    write('Error: Invalid priority (must be high, medium, or low).'), nl.
modify_task(_, NewStartTime, NewDuration, _, _) :-
    logged_in(UserID),
    \+ check_no_overlap(UserID, NewStartTime, NewDuration, none),
    write('Error: Modified task would overlap with existing task.'), nl.

% View the current schedule (same as generate_schedule)
view_schedule :-
    generate_schedule.

% -----------------------------------
% Feature 5: Save & Export Schedule
% -----------------------------------

% Save schedule to a file
save_schedule(Filename) :-
    logged_in(UserID),
    findall(task(TaskID, UserID, StartTime, Duration, Priority, Description),
            task(TaskID, UserID, StartTime, Duration, Priority, Description),
            Tasks),
    sort_tasks_by_priority_and_time(Tasks, SortedTasks),
    tell(Filename),
    write('Schedule for User: '), write(UserID), nl,
    write('--------------------------------------------------'), nl,
    write('| Task ID | Start Time | Duration | Priority | Description |'), nl,
    write('--------------------------------------------------'), nl,
    write_tasks_to_file(SortedTasks),
    write('--------------------------------------------------'), nl,
    told,
    write('Schedule saved to '), write(Filename), write('.'), nl.
save_schedule(_) :-
    \+ logged_in(_),
    write('Error: Please log in first.'), nl.

write_tasks_to_file([]).
write_tasks_to_file([task(TaskID, _, StartTime, Duration, Priority, Description)|Rest]) :-
    format('| ~w | ~w | ~w | ~w | ~w |~n', [TaskID, StartTime, Duration, Priority, Description]),
    write_tasks_to_file(Rest).

% -----------------------------------
% Example Usage
% -----------------------------------
/*
?- register_user("alice", "pass123", "Alice Smith").
?- login_user("alice", "pass123").
?- add_task(1, 900, 60, high, "Morning Meeting").
?- add_task(2, 1100, 30, low, "Email Check").
?- generate_schedule.
?- modify_task(1, 1000, 90, medium, "Team Sync").
?- save_schedule('schedule.txt').
?- logout.
*/