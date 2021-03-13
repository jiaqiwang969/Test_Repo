from paraview.simple import *
import os
filePath = 'H:\\Stalled\\B2B_65layer\\'
fileName=os.listdir(filePath)
for i in fileName:
    text=filePath+i
    cgns = CGNSSeriesReader(FileNames=text)
    cgns.PointArrayStatus = ['Density', 'Static Pressure', 'Vm', 'Vorticity vector', 'Vr', 'Vt', 'Vxyz', 'Wt', 'Wxyz']
    text1=text.replace('cgns', 'csv')
    SaveData(text1, proxy=cgns, WriteTimeSteps=1,ChooseArraysToWrite=1,PointDataArrays=['Density', 'Static Pressure', 'Vm', 'Vorticity vector', 'Vr', 'Vt', 'Vxyz', 'Wt', 'Wxyz'],AddTime=1)
