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

## crontabmac
This is the file that automates the syncing process and sends the timew export file.
Make sure you can ssh and scp to the server pi without prompting for a password.

Steps:
`ssh-keygen -t rsa`
Will generate a private key `~/.ssh/id_rsa`.
Will generate a public key `~/.ssh/id_rsa.pub`.

Copy the content of the public key to the remote server in this file.
`/home/pi/.ssh/authorized_keys`

Verify that you can ssh or scp without prompting a password.

## Note on setting up a taskpi server
This is a complicated and annoying process. :(
If the server is intact and you just need to add the same user to the new client computer:

Follow this process:
* Install taskwarrior and taskd if you haven't already.
* task server in the pi generated some keys for the user. They might still be in the taskserver repo in the home directory. 
  - first_last.cert.pem
  - first_last.key.pem
  - ca.cert.pem
* Copy these three files to the client computer under ~/.task.
* Configure taskwarrior:
  - `task config taskd.certificate -- ~/.task/first_last.cert.pem`
  - `task config taskd.key -- ~/.task/first_last.key.pem`
  - `task config taskd.ca -- ~/.task/ca.cert.pem`
  - `task config taskd.server -- taskd:53589`
  - `task config taskd.credentials -- Public/First Last/cf31f287-ee9e-43a8-843e-e8bbd5de4294`

The key at the end of the last line can be found in the servers /var/taskd/orgs/Public/users/ directory.

The client should now be ready to sync.
Follow this guide if there are problems: https://gothenburgbitfactory.github.io/taskserver-setup/

## Note on setting up the pi taskd server after booting
This was also a complicated process.
I don't remember the what and why, but notice the taskd.service file running in systemd. `/etc/systemd/system`. Also note that it has a ExecStartPre to delay 30 milliseconds. This was needed because it needs to wait for another necessary process to start up first. I forgot what exactly but if you need to set up the server again which was a nightmare, read up on how to set up systemd services.
