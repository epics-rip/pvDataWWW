@echo off
set /p CP=<target\cp.txt
java -classpath target\*;%CP% org.epics.trainingJava.maths.MathsService  %*
