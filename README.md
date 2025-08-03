# schedule_generator
Schedule generating project using SWI-prolog.
Introduction 
Below is a complete Prolog implementation of the Schedule 
Generator Program with all requested features: Register & 
Login (with verification), Set task 
constraints/preferences/duration/priority, Generate schedule 
diagram, Modify & View diagram, and Save & Export schedule. 
The code is modularized for clarity, with each feature 
implemented as a separate predicate or set of predicates. The 
program uses logic programming principles to manage tasks 
and constraints, and it includes basic input validation and file 
handling for saving/exporting. 
Assumptions and Notes 
• Task Representation: Tasks are stored as task(TaskID, 
UserID, StartTime, Duration, Priority, Description) with 
an additional UserID to associate tasks with users. 
• Constraints:Tasks must not overlap for a user, and 
priorities influence scheduling (high-priority tasks are 
scheduled earlier). 
• ScheduleDiagram: The diagram is a text-based table sorted 
by start time, as Prolog lacks native GUI support in this 
context. 
• File Handling: Schedules are saved/exported as text files 
with a simple format. 
• Login Verification: Passwords are stored as plain text for 
simplicity (in a real system, use hashing). 
• Time Format: Start times are integers (e.g., 900 for 9:00 
AM, 1430 for 2:30 PM) for simplicity. 
• Dynamic Predicates: User and task data are stored in 
memory using :- dynamic. 
• Error Handling: Basic validation ensures tasks exist, users 
are logged in, and constraints are met.
