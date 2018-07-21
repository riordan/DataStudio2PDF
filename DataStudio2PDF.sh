
#!/bin/bash

#Vars
curDate=`date +"%m_%d_%Y"`
timeStamp="_${curDate}"
pages=()
screen=1

#mainMenu
function menu {

  echo "Was möchten Sie tun?"
  echo "Zur Auswahl stehen:"
  echo "Neues Projekt anlegen (new)"
  echo "PDF erstellen (pdf)"
  echo "Ihre Formateinstellungen ändern (settings)"
  echo "und Projekt entfernen (remove)"
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
   echo "Befehl nicht bekannt"
   menu
  fi

}

# Add Project
function new {

      echo Wie soll das neue Projekt heißen?
      read newProject
      echo "Öffnen Sie das passende Projekt in Datastudio"
      echo "Die URL für Ihr Projekt sieht in etwa so aus: https://datastudio.google.com/#/org//reporting/ajdhshjsiejfhjdsguhj/page/XYZ"
      echo "Geben Sie den Projektnamen aus der URL an"
      echo "Im Beispiel wäre der Projektname "ajdhshjsiejfhjdsguhj""
      read newProjectName
      echo "Geben Sie den Seitenname aus der URL an"
      echo "Im Beispiel wäre der Seitenname "XYZ""
      read newProjectPage
      newProjectPages+=($newProjectPage)
      echo "Wollten Sie eine weitere Seite hinzufügen(y/n)?"
      read mehr
      while [ $mehr == "y" ]; do
        echo "Öffnen Sie die nächste Seite und geben Sie den Seitennamen an"
        read newProjectPage
        newProjectPages+=($newProjectPage)
        echo "Wollten Sie eine weitere Seite hinzufügen(y/n)?"
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
  echo "Bitte geben Sie den Shortcut für ihre Anfrage an."
  echo "Zur Auswahl stehen:"
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
  echo "Ist die Datei im Hoch-(h) oder Querformat(q)?"

  read format

    if [ $format == "q" ]; then
        x=300
        y=200
        w=1100
        h=820
        echo "Stellen Sie den Browser auf Vollbild und setzen Sie den Zoomlevel auf 90%"
        read go
      elif [ $format == "h" ]; then
        x=540
        y=180
        w=600
        h=800
        echo "Stellen Sie den Browser auf Vollbild und setzen Sie den Zoomlevel auf 67%"
        read go
      else
        echo "ERR0R detected. Shutting down."
        exit
    fi

  # Create PDF
  echo "Ihre Daten werden jetzt geladen, bitte fassen Sie nichts an während das Programm arbeitet"

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
  echo "Default Verwenden? (y/n)"
  read default
  if [ $default == "y" ]; then
    qFormat=(300,200,1100,820);
    hFormat=(540,180,600,800);
    echo $qFormat > files/settings.txt
    echo $hFormat >> files/settings.txt
    echo "Default wieder hergestellt"
    menu
  fi
    echo "Wollen Sie die Parameter anpassen? (y/n)"
    read anpassen
  if [ $anpassen == "y" ]; then
    echo "Machen Sie im Vollbildmodus einen Screenshot über cmd, shift und 4 [Mac]"
    echo "Lesen Sie die Daten für das Querformat in der linke Ecke oben ab"
    qFormat=()
    echo "X="
    read qFormatX
    echo "Y="
    read qFormatY
    echo "Halten Sie die linke Maustaste gedrückt und fahren Sie in die rechte Ecke unten"
    echo "W="
    read qFormatW
    echo "H="
    read qFormatH
    qFormat+=($qFormatX,$qFormatY,$qFormatW,$qFormatH)

    echo "Lesen Sie die Daten für das Hochformat in der linke Ecke oben ab"
    hFormat=()
    echo "X="
    read hFormatX
    echo "Y="
    read hFormatY
    echo "Halten Sie die linke Maustaste gedrückt und fahren Sie in die rechte Ecke unten"
    echo "W="
    read hFormatW
    echo "H="
    read hFormatH
    hFormat+=($hFormatX,$hFormatY,$hFormatW,$hFormatH)
    echo $qFormat > files/settings.txt
    echo $hFormat >> files/settings.txt
    echo "Ihre Änderungen wurden gespeichert"
  fi
  menu
}

function remove {
  projects=()
  projectinfo="files/projects.txt"
  while read -r projectName || [[ -n $projectName ]]; do
    projects+=($projectName)
  done < $projectinfo
  echo "Welches Projekt soll entfernt werden?"
  echo "Zur Auswahl stehen:"
  echo ${projects[@]}
  read removeFile
#Read chosenProject Data
  for projectName in "${projects[@]}"
  do
    if [ $removeFile == $projectName ]
      then
        rm files/$removeFile.txt
        echo "$(sed "/$removeFile/d" files/projects.txt)" >files/projects.txt


        echo "Ihr Projekt wurde gelöscht"
        menu
      fi
    done
    echo "Projektname ist leider nicht bekannt."
    menu

}


#onload

echo "Dieses Tool dient der Erstellung von PDF Dateien aus Google Datastudio."
echo "WICHTIG: Stellen Sie sicher, dass poppler (install poppler) und pdfunite ( brew install poppler) installiert sind."
echo "created by Maximilian Becher für Ueberbit; copyright© 2017"

menu
