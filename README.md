# taskpi 
A task manager intended for my Raspberry Pi Zero W with a hyperpixel 4.0" display.

Uses:
  * Taskwarrior and taskd (task server)
  * Timewarrior

## Components

### User Interface Written in Java
A java program to interact with tasks and display visually pleasing and informative task analysis.

### Twitter Bot
A twitter bot using Twython that posts a pie chart of yesterday's completed tasks.

### Current Task Display on Main Computer
A terminal display of the current task being worked on to stay focused when working.

---

My Taskwarrior Workflow:
  A Taskwarrior server is running on a raspberry pi zero and it also runs a twitter bot script that posts a daily pie chart analysis of the tasks completed on the preceding day.
The intention is to have a second portable raspberry that I call the **taskpi** to start, finish, and modify tasks on the go, with extra features. The taskpi has two hooks. One to integrate with timewarrior, and one to sync to the server and main work computer after every task command.
  My main work computer uses a terminal display on a second monitor that shows the current task being worked on and how long since it was initially started. This helps me to stay focused on a task and to not get sidetracked.

Why on raspberrypi:
  I can ssh from a phone or use any of the available apps but I would rather have one minimalist device with the sole purpose of managing tasks and staying focused. If I am out of the house and want those tasks included in the end of the day analysis I will probably ssh to the server remotely from my phone, but this device is intended for working at home in the studio, and is supposed to be highly personalized to my workflow.

Features to include:
  - A Minimal, Clean, and Visually Pleasing UI
  - Voice Activation and Interaction
  - Sound/TTS Audio Feedback
  - Smart and Personalized Recommendations
  - Automation of task projects setup
