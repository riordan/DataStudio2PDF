
#!/bin/bash

#Vars
curDate=`date +"%m_%d_%Y"`
timeStamp="_${curDate}"
pages=()
screen=1

#mainMenu
function menu {

   echo "What would you like to do?"
   echo "You can choose from:"
   echo "Create new project (new)"
   echo "Create PDF (pdf)"
   echo "Change your format settings (settings)"
   echo "and remove project (remove)"
  read Command
  if [[ $Command == "new" ]]
    then
      new
  elif [[ $Command == "pdf" ]]
    then
      pdf
  elif [[ $Command == "settings" ]]
    then
      settings
  elif [[ $Command == "remove" ]]
    then
      remove
  else
   echo "Command unknown"
   menu
  fi

}

# Add Project
function new {

      echo What should the new project be called?
      read newProject
      
      echo "Open the appropriate project in Datastudio"
      echo "The URL for your project looks something like this: https://datastudio.google.com/#/org//reporting/ajdhshjsiejfhjdsguhj/page/XYZ"
      echo "Enter the project name from the URL"
      echo "In the example the project name would be "ajdhshjsiejfhjdsguhj""
      read newProjectName
      
      echo "Enter the page name from the URL"
      echo "In the example, the page name would be "XYZ""
      read newProjectPage
      newProjectPages+=($newProjectPage)
      
      echo "Did you want to add another page(y/n)?"
      read mehr
      while [ $mehr == "y" ]; do
        echo "Open the next page and specify the page name"
        read newProjectPage
        newProjectPages+=($newProjectPage)
        echo "Did you want to add another page(y/n)?"
        read mehr
      done
      echo $newProject >> files/projects.txt
      echo $newProjectName > files/$newProject.txt
      for projectPage in "${newProjectPages[@]}"
      do
          echo $projectPage >> files/$newProject.txt
      done
      menu

}

# Load Files
function pdf {
  projects=()
  projectinfo="files/projects.txt"
    while read -r projectName || [[ -n $projectName ]]; do
      projects+=($projectName)
    done < $projectinfo
# Select Project
  echo "Please provide the shortcut for your request."
  echo "You can choose from:"
  echo ${projects[@]}
  read selection

#Read chosenProject Data
  for projectName in "${projects[@]}"
  do
    if [ $selection == $projectName ]
      then
        chosenProject="files/$selection.txt"
        while read -r projectData || [[ -n $projectData ]]
        do
          if [[ $first == "false" ]]; then
              pages+=($projectData)
            else
              selectedProject=$projectData
              first="false"
            fi
        done < $chosenProject
      fi
  done

  # Read Format
  echo "Is the file in portrait (h) or landscape (q) format?"

  read format

    if [ $format == "q" ]; then
        x=300
        y=200
        w=1100
        h=820
        echo "Set the browser to full screen and set the zoom level to 90%"
        read go
      elif [ $format == "h" ]; then
        x=540
        y=180
        w=600
        h=800
        echo "Set the browser to full screen and set the zoom level to 67%"
        read go
      else
        echo "ERR0R detected. Shutting down."
        exit
    fi

  # Create PDF
  echo "Your data is now being loaded, please do not touch anything while the program is running"

    for page in ${pages[@]}
    do
      open https://datastudio.google.com/\#/org//reporting/$selectedProject/page/$page
      screencapture -t pdf -T 5 -x -m -R $x,$y,$w,$h ./temp/sample_$screen.pdf
      screen=$((screen+1))
      sleep 10
    done
    pdfunite ./temp/*.pdf output/$selection$timeStamp.pdf
    rm -rfv temp/*.pdf
    echo "done!"
    menu
}

function settings {
  echo "Use default? (y/n)"
  read default
  if [ $default == "y" ]; then
    qFormat=(300,200,1100,820);
    hFormat=(540,180,600,800);
    echo $qFormat > files/settings.txt
    echo $hFormat >> files/settings.txt
    echo "Default restored"
    menu
  fi
    echo "Do you want to adjust the parameters? (y/n)"
    read anpassen
  if [ $anpassen == "y" ]; then
    echo "Take a screenshot in full screen via cmd, shift and 4 [Mac]"
    echo "Read the landscape data in the top left corner"
    qFormat=()
    echo "X="
    read qFormatX
    echo "Y="
    read qFormatY
    echo "Hold the left mouse button and move to the bottom right corner"
    echo "W="
    read qFormatW
    echo "H="
    read qFormatH
    qFormat+=($qFormatX,$qFormatY,$qFormatW,$qFormatH)

    echo "Read the data for portrait mode in the top left corner"
    hFormat=()
    echo "X="
    read hFormatX
    echo "Y="
    read hFormatY
    echo "Hold the left mouse button and move to the bottom right corner"
    echo "W="
    read hFormatW
    echo "H="
    read hFormatH
    hFormat+=($hFormatX,$hFormatY,$hFormatW,$hFormatH)
    echo $qFormat > files/settings.txt
    echo $hFormat >> files/settings.txt
    echo "Your changes have been saved"
  fi
  menu
}

function remove {
  projects=()
  projectinfo="files/projects.txt"
  while read -r projectName || [[ -n $projectName ]]; do
    projects+=($projectName)
  done < $projectinfo
  echo "Which project do you want to remove?"
  echo "You can choose from:"
  echo ${projects[@]}
  read removeFile
#Read chosenProject Data
  for projectName in "${projects[@]}"
  do
    if [ $removeFile == $projectName ]
      then
        rm files/$removeFile.txt
        echo "$(sed "/$removeFile/d" files/projects.txt)" >files/projects.txt


       echo "Your project has been deleted"
        menu
      fi
    done
    echo "Unfortunately, the project name is not known.
    menu

}


#onload

echo "This tool is used to create PDF files from Google Datastudio."
echo "IMPORTANT: Make sure poppler (install poppler) and pdfunite (brew install poppler) are installed."
echo "created by Maximilian Becher für Ueberbit; copyright© 2017"

menu
