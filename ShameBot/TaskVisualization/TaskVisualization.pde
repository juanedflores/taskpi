import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

// Font
PFont myFont;
PFont boldFont;

// JSON array
JSONArray values;
JSONArray sunvalues;

// Key appearance constants.
int secondsinday = 86400;
int chartcenterX = 400;
int chartcenterY = 225;
int keyposXright = 650;
int keyposYright = 44;
int keyposXleft = 150;
int keyposYleft = 44;
int keyrectXoffset = 24;
int keyrectYoffset = 4;
int keylineXoffset = 7;
int keylineYoffset = 13;
int keylinelength = 32;
int keyspacing = 50;
int keydataoffset = 20;
int keypercentoffset = 80;
color keyStrokeColor = color(0);
color keyDurationColor = color(80);

// Daily task goal percentages.
color completetaskcol = color(16, 71, 20);
color incompletetaskcol = color(163, 54, 3);
float sleepmin = 27.0;
float sleepmax = 33.3;
float exhibitionmin = 8.3;
float languagemin = 2.0;
float miscmin = 4.16;

// Array to keep track of special categories.
String[] categories;
color[] randomcolors;

// Arrays to keep track of pie chart angles of all tasks.
float[][] angles;
int[] miscangles;
int misctotalseconds = 0;

// Arrays to keep track of starting position of all tasks.
float[] startx;
float[] startxmisc;

void setup() {
  size(800, 465);
  background(210);
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("KohinoorTelugu-Light", 16);
  boldFont = createFont("KohinoorTelugu-Bold", 16);

  // Get json file.
  values = loadJSONArray("/home/pi/ShameBot/TaskVisualization/timewjson.json");
  sunvalues = loadJSONArray("/home/pi/ShameBot/TaskVisualization/sundata.json");

  // Instantiate total angle arrays to keep count.
  int anglecount = 0;
  int miscanglecount = 0;

  // Go through every task in json file.
  for (int i = 0; i < values.size(); i++) {
    JSONObject task = values.getJSONObject(i);
    JSONArray tag = task.getJSONArray("tags");

    // If there is more than one tag, then it is a special category.
    if (tag.size() > 1) {
      anglecount++;
    } else {
      miscanglecount++;
      misctotalseconds += task.getInt("seconds");
    }
  }

  // Instantiate the arrays.
  categories = new String[anglecount];
  angles = new float[3][anglecount];
  startx = new float[anglecount];

  miscangles = new int[miscanglecount];
  startxmisc = new float[miscanglecount];
  
  randomcolors = new color[anglecount];

  // Go through each task again to transfer info to arrays.
  int index = 0;
  int miscindex = 0;
  for (int i = 0; i < values.size(); i++) {
    JSONObject task = values.getJSONObject(i);
    JSONArray tag = task.getJSONArray("tags");

    // If special category, add category name and angles, else add angles to misc category. 
    if (tag.size() > 1) {
      // Store the special category for the pie chart key.
      String displaytag = task.getString("displaytag");
      categories[index] = displaytag;

      angles[0][index] = task.getInt("seconds");
      angles[1][index] = map(task.getInt("seconds"), 0, secondsinday, 0, 360);
      startx[index] = map(task.getFloat("startx"), 0, 24.0, 0.0, 360.0)+90;
      index++;
    } else {
      miscangles[miscindex] = ceil(map(task.getInt("seconds"), 0, secondsinday, 0, 360));
      startxmisc[miscindex] = map(task.getFloat("startx"), 0, 24.0, 0.0, 360.0)+90;
      miscindex++;
    }
  }

  // We must calculate the total seconds of every special category that gets repeated.
  // We will store the total seconds in the index where the special tag first appears.
  for (int i = 0; i < categories.length; i++) {
    for (int j = 0; j < i; j++) {
      if (categories[i].equals(categories[j])) {
        angles[0][j] += angles[0][i];
      }
    }
  }

  // Draw pie chart, save image, then exit program.
  angles = sortCategories(300, angles);
  pieTime(325);
  pieChart(300, angles, miscangles);
  saveFrame("visualization.png");
  exit();
}

void pieTime(float diameter) {

  /* Get sun info */
  JSONObject sundata = sunvalues.getJSONObject(0);
  JSONObject sunarray = sundata.getJSONObject("results");
  String sunrise = sunarray.getString("sunrise");
  String sunset = sunarray.getString("sunset");

  int sunrisehour = int(sunrise.substring(0, 2));
  // FIX: Possibly a temporary fix, daylight savings causes issue of being hour behind or ahead
  sunrisehour++;
  int sunriseminute = int((float(sunrise.substring(3, 5))/60)*100);
  float sunrisehrfract = float(str(sunrisehour)+"."+str(sunriseminute)); 

  int sunsethour = int(sunset.substring(0, 2));
  // FIX: Possibly a temporary fix, daylight savings causes issue of being hour behind or ahead
  sunsethour++;
  int sunsetminute = int((float(sunset.substring(3, 5))/60)*100);
  float sunsethrfract = float(str(sunsethour)+"."+str(sunsetminute)); 
  //println(sunrisehrfract);
  //println(sunsethrfract);

  /* Draw sun info*/
  stroke(0);
  float sunriseX = chartcenterX + cos(radians(map(sunrisehrfract, 0, 24, 0, 360)+90))*(diameter/2);
  float sunriseY = chartcenterY + sin(radians(map(sunrisehrfract, 0, 24, 0, 360)+90))*(diameter/2);
  line(chartcenterX, chartcenterY, sunriseX, sunriseY);
  float sunsetX = chartcenterX + cos(radians(map(sunsethrfract, 0, 24, 0, 360)+90))*(diameter/2);
  float sunsetY = chartcenterY + sin(radians(map(sunsethrfract, 0, 24, 0, 360)+90))*(diameter/2);
  line(chartcenterX, chartcenterY, sunsetX, sunsetY);
  fill(255, 140, 20);
  noStroke();
  arc(chartcenterX, chartcenterY, diameter+25, diameter+25, radians(map(sunrisehrfract, 0, 24, 0, 360)+90), radians(map(sunsethrfract, 0, 24, 0, 360)+90));
  fill(40, 140, 255);
  arc(chartcenterX, chartcenterY, diameter, diameter, radians(map(sunsethrfract, 0, 24, 0, 360)+90), radians(map(sunrisehrfract, 0, 24, 0, 360)+450));

  /* Draw hours */
  float angle = 0;
  float px = 0;
  float py = 0;
  float p2x = 0;
  float p2y = 0;
  float p3x = 0;
  float p3y = 0;
  int hour = 18;
  int sunoffset = 0;

  for (int i = 0; i < 24; i++) {

    if ((i+18)%24 >= sunrisehrfract && (i+18)%24 <= sunsethrfract) {
      sunoffset = 25;
    } else {
      sunoffset = 0;
    }

    // Draw a point and line.
    px = chartcenterX + cos(radians(angle))*((diameter + sunoffset)/2);
    py = chartcenterY + sin(radians(angle))*((diameter + sunoffset)/2);
    stroke(210);
    strokeWeight(5);
    point(px, py);

    p2x = chartcenterX + cos(radians(angle))*((diameter + 16+sunoffset)/2);
    p2y = chartcenterY + sin(radians(angle))*((diameter + 16+sunoffset)/2);
    p3x = chartcenterX + cos(radians(angle))*((diameter + 44+sunoffset)/2);
    p3y = chartcenterY-2 + sin(radians(angle))*((diameter + 44+sunoffset)/2);
    stroke(0);
    strokeWeight(1.5);
    line(px, py, p2x, p2y);

    // Draw the hour.
    textAlign(CENTER, CENTER);
    fill(125);
    if (hour == 24) {
      text("00", p3x, p3y);
    } else if (hour < 10) {
      String hourtext = "0" + hour;
      text(hourtext, p3x, p3y);
    } else {
      text(hour, p3x, p3y);
    }

    hour++;

    if (hour == 25) {
      hour = 1;
    }
    angle += 15;
  }
}

void pieChart(float diameter, float[][] data, int[] miscdata) {

  // Draw background of pie chart.
  fill(30, 20, 10); 
  noStroke();
  ellipse(chartcenterX, chartcenterY, diameter, diameter);

  // Draw miscellaneous task slices first.
  for (int i = 0; i < miscdata.length; i++) {
    strokeWeight(0.5);
    stroke(255, 255, 0);
    float gray = map(i, 0, miscdata.length, 200, 70);
    fill(gray);
    arc(chartcenterX, chartcenterY, diameter, diameter, radians(startxmisc[i]), radians(startxmisc[i])+radians(miscdata[i]), PIE);
  } 

  // Draw special category task slices.
  color percentcol = color(255, 0, 0);
  for (int i = 0; i < data[0].length; i++) {
    
    // Frequent tag colors. If not a frequent tag, make it a random color.
    if (categories[i].equals("SLEEP")) {

      /* GOAL */
      // Minimum of 6.5 hours and maximum of 8 hours of sleep.
      float percentage = data[1][i]/360.0*100;
      if ( percentage >= sleepmin && percentage <= sleepmax) {
        percentcol = completetaskcol;
      } else {
        percentcol = incompletetaskcol;
      }

      stroke(177, 119, 189);
      fill(20, 15, 92);
    } else if (categories[i].equals("EAT")) { 
      stroke(86, 158, 71);
      percentcol = keyStrokeColor;
      fill(97, 40, 26);
    } else if (categories[i].equals("SPANISH") || categories[i].equals("ESPAÑOL")) {

      /* GOAL */
      // Minimum of 6.5 hours and maximum of 8 hours of sleep.
      float percentage = data[1][i]/360.0*100;
      if ( percentage >= languagemin) {
        percentcol = completetaskcol;
      } else {
        percentcol = incompletetaskcol;
      }

      stroke(keyStrokeColor);
      fill(0, 115, 150);
    } else if (categories[i].equals("GERMAN") || categories[i].equals("DEUTSCH")) {

      /* GOAL */
      // Minimum of 6.5 hours and maximum of 8 hours of sleep.
      float percentage = data[1][i]/360.0*100;
      if ( percentage >= languagemin) {
        percentcol = completetaskcol;
      } else {
        percentcol = incompletetaskcol;
      }

      stroke(keyStrokeColor);
      fill(12, 148, 0);
    } else if (categories[i].equals("GUITAR")) {

      /* GOAL */
      // Minimum of 6.5 hours and maximum of 8 hours of sleep.
      float percentage = data[1][i]/360.0*100;
      if ( percentage >= languagemin) {
        percentcol = completetaskcol;
      } else {
        percentcol = incompletetaskcol;
      }

      stroke(keyStrokeColor);
      fill(219, 179, 100);
    } else if (categories[i].equals("EXHIBITION")) {

      /* GOAL */
      // Minimum of 2 hours working on exhibition/art practice.
      float percentage = data[1][i]/360.0*100;
      if ( percentage >= exhibitionmin) {
        percentcol = completetaskcol;
      } else {
        percentcol = incompletetaskcol;
      }

      stroke(keyStrokeColor);
      fill(132, 191, 209);
    } else {
      stroke(keyStrokeColor);
      color rancol = color(random(255), random(255), random(255));
      fill(rancol);

      randomcolors[i] = rancol;
    }
    
    // The drawkey boolean is to prevent repeats of keys.
    boolean drawkey = true;
    for (int j = 0; j < i; j++) {
      if (categories[j].equals(categories[i])) {
        drawkey = false;
        if (randomcolors[i] != 0) {
          fill(randomcolors[j]);
        }
      }
    }

    // Draw special category slice.
    strokeWeight(0.5);
    arc(chartcenterX, chartcenterY, diameter, diameter, radians(startx[i]), radians(startx[i])+radians(data[1][i]), PIE);
    // Draw the special category point.
    float arcmidpoint = startx[i]+data[1][i]/2;
    float midX = chartcenterX + cos(radians(arcmidpoint)) * diameter/2;
    float midY = chartcenterY + sin(radians(arcmidpoint)) * diameter/2;
    strokeWeight(6); 
    point(midX, midY);

    boolean right = true;
    if (data[2][i] == 0.0) {
      right = false;
    } 

    if (drawkey) {
      if (right) {
        // Drawing the key color.
        strokeWeight(1);
        rectMode(CENTER);
        rect(keyposXright-keyrectXoffset, keyposYright-keyrectYoffset, 16, 16);

        // Draw a line.
        stroke(175);
        line(keyposXright-keylineXoffset, keyposYright-keylineYoffset, keyposXright-keylineXoffset, keyposYright-keylineYoffset+keylinelength);

        // Drawing the key text.
        fill(keyStrokeColor);
        textSize(18);
        textFont(myFont);
        textAlign(LEFT);
        text(categories[i], keyposXright, keyposYright);

        // Draw the duration of task.
        fill(keyDurationColor);
        textSize(12);
        int minutes = int(data[0][i]/60);
        int hours = 0;
        if (minutes >= 60) {
          hours = minutes / 60;
          minutes = minutes % 60;
        }      
        text(hours + " hrs " + minutes + " mins ", keyposXright, keyposYright-2+keydataoffset);

        // // Draw the percentage.
        fill(percentcol);
        textSize(12);
        float percentage = data[0][i]/86400.0*100;
        String strpercent = nf(percentage, 2, 2) + "%";
        text(strpercent, keyposXright + keypercentoffset, keyposYright-2+keydataoffset);

        keyposYright = keyposYright+keyspacing;
      } else {
        // Drawing the key color.
        strokeWeight(1);
        rectMode(CENTER);
        rect(keyposXleft+keyrectXoffset, keyposYleft-keyrectYoffset, 15, 15);

        // Draw a line.
        stroke(175);
        line(keyposXleft+keylineXoffset, keyposYleft-keylineYoffset, keyposXleft+keylineXoffset, keyposYleft-keylineYoffset+keylinelength);

        // Drawing the key text.
        fill(keyStrokeColor);
        textSize(18);
        textFont(myFont);
        textAlign(RIGHT);
        text(categories[i], keyposXleft, keyposYleft);

        // Draw the duration of task.
        fill(keyDurationColor);
        textSize(12);
        int minutes = int(data[0][i]/60);
        int hours = 0;
        if (minutes >= 60) {
          hours = minutes / 60;
          minutes = minutes % 60;
        }      
        text(hours + " hrs " + minutes + " mins ", keyposXleft, keyposYleft-2+keydataoffset);

        // // Draw the percentage.
        fill(percentcol);
        textSize(12);
        float percentage = data[0][i]/86400.0*100;
        String strpercent = nf(percentage, 2, 2) + "%";
        text(strpercent, keyposXleft - keypercentoffset, keyposYleft-2+keydataoffset);

        keyposYleft = keyposYleft+keyspacing;
      }
    }
  }

  // Add a misc category to key.    
  strokeWeight(1);
  stroke(255, 255, 0);
  fill(125);
  rectMode(CENTER);
  rect(keyposXright-keyrectXoffset, keyposYright-keyrectYoffset, 15, 15);
  // Draw a line.
  stroke(175);
  line(keyposXright-keylineXoffset, keyposYright-keylineYoffset, keyposXright-keylineXoffset, keyposYright-keylineYoffset+keylinelength);
  fill(125);
  textSize(18);
  textAlign(LEFT);
  text("misc.", keyposXright, keyposYright);
  // Draw the total duration of misctask(s).
  fill(125);
  textSize(12);
  int miscminutes = misctotalseconds/60;
  int mischours = 0;
  if (miscminutes >= 60) {
    mischours = miscminutes / 60;
    miscminutes = miscminutes % 60;
  }
  text(mischours + " hrs " + miscminutes + " mins ", keyposXright, keyposYright-2+keydataoffset);

  /* GOAL */
  // Minimum of 1 hour of miscellaneous work.
  // Draw the percentage.
  textSize(12);
  float percentage = misctotalseconds/86400.0*100;
  if ( percentage >= miscmin) {
    percentcol = completetaskcol;
  } else {
    percentcol = incompletetaskcol;
  }
  String strpercent = nf(percentage, 2, 2) + "%";
  fill(percentcol);
  text(strpercent, keyposXright + keypercentoffset, keyposYright-2+keydataoffset);

  // Draw border of pie chart.
  stroke(255, 100, 30);
  noStroke();
  noFill(); 
  ellipse(chartcenterX, chartcenterY, diameter, diameter);
  
  // Draw the date.
  fill(30, 20, 10); 
  textAlign(CENTER);
  textSize(17);
  textFont(boldFont);
  
  LocalDate today = LocalDate.now();
  LocalDate yesterday = today.minusDays(1);
  DateTimeFormatter formatted = DateTimeFormatter.ofPattern("EEEE,  MMMM - dd - yyyy");
  String formattedString = yesterday.format(formatted);

  text(formattedString, width/2, height-18);
}

float[][] sortCategories(float diameter, float[][] data) {

  // Instantiate new array that will store sorted values.
  float sorted[][] = new float[3][data[0].length];
  String newcategories[] = new String[data[0].length];
  float newstartx[] = new float[data[0].length];
  
  // Determine if slice is on the left side or right side.
  for (int i = 0; i < data[0].length; i++) {
    float arcmidpoint = startx[i]+data[1][i]/2;
    float midX = chartcenterX + cos(radians(arcmidpoint)) * diameter/2;
    if (midX >= width/2) {
      data[2][i] = 1;
    } else if (midX < width/2) {
      data[2][i] = 0;
    }
  }
  
  // Get all Y values of the center edge of each pie slice.
  float[] sortedMidY = new float[data[0].length];
  for (int i = 0; i < data[0].length; i++) {
    float arcmidpoint = startx[i]+data[1][i]/2;
    float midY = chartcenterY + sin(radians(arcmidpoint)) * diameter/2;
    sortedMidY[i] = midY;
  }
  
  // Sort the list of Y values.
  sortedMidY = sort(sortedMidY);

  // Look for the matching values to make the appropriate switch of index.
  // NOTE: If Y values are the same, I think it could lead to a bug, but I realized that the
  // lists are sort of sorted by going along the circumference with the value "startx", this causes
  // the order to be from one side (right, or left) to the other side. Perhaps looking into
  // this bug might not be necessary.
  for (int i = 0; i < data[0].length; i++) {
    float arcmidpoint = startx[i]+data[1][i]/2;
    float midY = chartcenterY + sin(radians(arcmidpoint)) * diameter/2;
    for (int j = 0; j < data[0].length; j++) {
      if (midY == sortedMidY[j]) {
        // Data[0] seconds, data[1] angles, data[2] right or left position (1 right, 0, left)
        // categories[] contains the names, startx[] contains the starting position in circumference. 
        sortedMidY[j] = -1;
        sorted[0][j] = data[0][i];
        sorted[1][j] = data[1][i];
        sorted[2][j] = data[2][i];
        newstartx[j] = startx[i];
        newcategories[j] = categories[i];
        break;
      }
    }
  }
  categories = newcategories;
  startx = newstartx;

  return sorted;
}
