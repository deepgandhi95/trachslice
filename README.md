# trachslice
TrachSlice

Description: 
This repository contains functions and scripts to perform geometric analysis of neonatal trachea. 

The function trachSlice_Alister.m performs the geometric analysis of trachea with given inputs - trachea surface '.stl' file and a centerline '.vtk' file for the same trachea surface

There are two scripts 'Automated_TrachSlice.m' and 'Automated_TrachSlice_DG_OSA.m' used for neonates with bronchopulmonary dysplasia and adoloscents with obstructive sleep apnea, respectively, that demonstrate the use of trachSlcie_Alister.m

Requirements to run:
1. MATLAB 2020b or later
2. python 3.6 or later
3. Paraview 5.10 or later
4. Other matlab functions and python scripts included in this repository

Usage:
[arcLength, area, goodpos, missedPlane] = trachSlice_Alister(STLfilename,VTKfilename);

Inputs:
STLfilename = name of the trachea surface .stl file
VTKfilename = name of the centerline .vtk file

Outputs:
arcLength = Arc length of the trachea surface
area = Cross sectional geometric area of the trachea
goodpos = positions along which the cross-sectional area was measured
missedPlane = locations along the trachea where cross-sectional area measurement was not possible

Authors:
Deep B. Gandhi and Alister J. Bates
