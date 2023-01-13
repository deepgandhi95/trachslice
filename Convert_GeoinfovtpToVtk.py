# trace generated using paraview version 5.6.2
#
# To ensure correct image size when batch processing, please search 
# for and uncomment the line `# renderView*.ViewSize = [*,*]`

#### import the simple module from the paraview

from paraview.simple import *
import os
import sys
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()
file = sys.argv[1]
fileout = sys.argv[2]
# create a new 'XML PolyData Reader'
out_000000_centerline_geoinfovtp = XMLPolyDataReader(FileName=['C:/Users/GAN5EH/Test_trachsliceAuto_CG/{}'.format(file)])
out_000000_centerline_geoinfovtp.CellArrayStatus = ['Length', 'Tortuosity']
out_000000_centerline_geoinfovtp.PointArrayStatus = ['MaximumInscribedSphereRadius', 'Curvature', 'Torsion', 'FrenetTangent', 'FrenetNormal', 'FrenetBinormal']
cwd = os.getcwd
# save data
SaveData('C:/Users/GAN5EH/PycharmProjects/VirtualBronchoscopy/Test_BlueJournal_video/{}'.format(fileout), proxy=out_000000_centerline_geoinfovtp, FileType='Ascii')
#### uncomment the following to render all views
# RenderAllViews()
# alternatively, if you want to write images, you can use SaveScreenshot(...).