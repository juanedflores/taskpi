const ansiEscapes = require("ansi-escapes");
const chalk = require("chalk");
const { toBlock, mapBlock, concatBlocks, toString } = require("terminal-block-fonts");
const fs = require("fs");
const readLastLines = require('read-last-lines');
const lineReader = require('line-reader');
const homedir = require('os').homedir();

// colors
const orange = chalk.hex('#FF7733');
const blue = chalk.hex('#36A3D9');
const green = chalk.hex('#BBCC52');
const red = chalk.hex('#F07178');

let task = "break time";
const taskfile = homedir + '/.task/pending.data';
let minutes = 0;
let hours = 0;
let myTimer;
let taskcolor = blue;

/*
 * Watch the text file.
 */
fs.watch(taskfile, (event, filename) => {
  process.stdout.write(ansiEscapes.eraseLines(24));
  getData();
});


async function getData () {
  foundtask = false;
  await lineReader.eachLine("/Users/juaneduardoflores/.task/pending.data", function(line) {
    // reset time.
    minutes = 0;
    hours = 0;
    data = line.split(/[:",]+/);
    for (let i = 0; i < data.length; i++) {
      if (data[i] == " start") {
	foundtask = true;
	taskcolor = green;
	console.log(data);
	task = data[1].replace(/['"]+/g, '');
	console.log(task);
	break;
      }
    }

    if (foundtask == false) {
      taskcolor = blue;
      task = "break time";
    }

    displayTask();
  });

  // await displayTask();
  // .then(() => displayTask())
  // .catch((err) => console.log(err));

  // loot at task data files for started task
  // await readLastLines.read(taskfile, 1)
  //   .then((lines) => data = lines.split(/[:",]+/))
  //   .then((data) => {
  //     taskcolor = blue;
  //     task = "break time";
  //     for (let i = 0; i < data.length; i++) {
  //       if (data[i] == " start") {
  //         taskcolor = green;
  //         console.log(data);
  //         task = data[1].replace(/['"]+/g, '');
  //         console.log(task);
  //         break;
  //       }
  //     }
  //   })
  //   .then(() => displayTask())
  //   .catch((err) => console.log(err));

  // clear timer if any.
  if (myTimer) {
    await clearInterval(myTimer);
  }
  // start timer.
  myTimer = setInterval(displayTask, 60000);
}

function displayTask () {
  const curTaskHead = toString(mapBlock(toBlock("current task:"), orange));
  const curTask = toString(mapBlock(toBlock(task), taskcolor));
  let elapsedTime = "ellapsed time:";

  if (hours) {
    elapsedTime += " " + hours + " hour";
    if (hours > 1) {
      elapsedTime += "s";
    }
  }
  if (minutes) {
    elapsedTime += " " + minutes + " minute";
    if (minutes > 1) {
      elapsedTime += "s";
    }
  }

  // keep track of time.
  if (minutes > 58) {
    minutes = 0;
    hours += 1;
  } else {
    minutes += 1;
  }

  process.stdout.write(ansiEscapes.eraseLines(24));
  process.stdout.write(curTaskHead);
  process.stdout.write("\n");
  process.stdout.write(curTask);
  process.stdout.write("\n\n\n");
  process.stdout.write(toString(mapBlock(toBlock(elapsedTime), red)));
}

getData();
