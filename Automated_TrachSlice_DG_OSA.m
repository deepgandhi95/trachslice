%% Code for Automated TrachSlice
%Get the STL file name
I = dir;
I(1:2) = [];
test = strsplit(I(1).name,'.');
subject = test{1,1};

%Run the VMTK centerline command
% command should be in the form: VMTK-python arg1 (python code) arg2 (STL
% name without extension)
command = "C:/Users/GAN5EH/AppData/Local/Continuum/vmtk/python C:/Users/GAN5EH/Python_scripts/tracheaCentreline_pypesDG_testing.py";
stl_folder = I.folder;
newChr = strrep(stl_folder,'\','/');
Final_command = strcat(command +" ",newChr+"/",subject);
system(Final_command)

% Convert vtp to vtk (ascii) file
% formatspec1 = '%s_centerline_geoinfo.vtp';
% formatspec2 = '%s_centerline_geoinfo.vtk';
% str1 = sprintf(formatspec1,subject);
% str2 = sprintf(formatspec2,subject);
% str3 = strcat(str1+" ",str2);
% 
% str4 = '"C:\Users\GAN5EH\OneDrive - cchmc\Documents\MATLAB\CPIR codes\TrachealAnalysisCode\Convert_GeoinfovtpToVtk.py"';
% %vtpTovtk_command = strcat(' "C:/Program Files/ParaView 5.8.0-Windows-Python3.7-msvc2015-64bit/bin/pvpython" '+ " ",str4+" ",stl_folder+"\",str1 + " ",stl_folder+"\",str2);
% vtpTovtk_command = strcat(' "C:/Program Files/ParaView 5.8.0-Windows-Python3.7-msvc2015-64bit/bin/pvpython" '+ " ",str4+" ",stl_folder+"\",subject);
% system(vtpTovtk_command);
%%
%Run trachSlice code
subject = 'DYMOSA803_withoutFace1000_remeshMeshlab';
STLfilename = strcat(subject,'.stl');
VTKfilename = strcat(subject, '_centerline_geoinfo.vtk');
mkdir('Sliced_planes');
cd('Sliced_planes');
[arcLength, area, goodpos, missedPlane] = trachSlice_OSA(STLfilename,VTKfilename);
filenameStart= STLfilename(1:end-4);

%Get various parameters
[perimeter, hydDiam, diameter] = PerimeterandhydDiamCalc(filenameStart, size(area,2), true);
RD = diameter(:,2)./diameter(:,1);
save([filenameStart '-RD.mat'], 'RD');

%Save data and write it to a csv file
dataToWrite(:,1) = arcLength';
dataToWrite(:,2) = area';
dataToWrite(:,3) = hydDiam;
dataToWrite(:,4) = diameter(:,1);
dataToWrite(:,5) = diameter(:,2);
dataToWrite(:,6) = RD;
dataToWrite(:,7) = perimeter;

Data = [STLfilename(1:end-4) '-Data' '.csv'];

csvwrite(Data, dataToWrite);

fid = fopen(Data, 'wt');
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s\n', 'Arc Length','Area','Hydraulic Diameter','Major Diameter','Minor Diameter','Ratio of Diameters','Perimeter');
fprintf(fid, '%g,%g,%g,%g,%g,%g,%g\n', dataToWrite.');   %transpose is important!
fclose(fid);