function [] = generateTransformedMeshes_DG(doPlot)

if nargin < 1
    doPlot = true;
end

close all

t1 = 0;
dt = 10;
endTime = 880;

mkdir('Images');
I = dir('*.stl');

    
    i=0;
   

    if doPlot
        %figure
        hfig = figure('Color',[0 0 0]);
        set(hfig,'Position',[10 10 1080 1920])
        videoLength = 0.88;
        noSteps = round(endTime/dt);
        fps = noSteps / videoLength;
        videoName = 'P137';
        filename = [videoName '_surface'];
        v = VideoWriter(filename,'Uncompressed AVI');
        v.FrameRate = fps;
        open(v);
    end

    for t = t1+dt:dt:endTime
        i = i+1;
        meshOutName = I(i).name;
        if doPlot
            if exist('h_t','var')
                delete(h_t);
            end
            
            [Vsurface,Fsurface,~] = STL_Import(meshOutName);            
            if i == 1
                h = patch('Vertices',Vsurface,'Faces',Fsurface,'facecolor', 'g');
                set(h, 'EdgeColor','none');
                set(gca,'Color',[0 0 0]);
                set(gca,'ycolor',[0 0 0]);
                set(gca,'xcolor',[0 0 0]);
                xl = min(min(Vsurface(:,1)));
                xh = max(max(Vsurface(:,1)));
                yl = min(min(Vsurface(:,2)));
                yh = max(max(Vsurface(:,2)));
                zl = min(min(Vsurface(:,3)));
                zh = max(max(Vsurface(:,3)));
                xt = xh;
                yt = yl + ((yh - yl) / 2);
                zt = zl + ((zh - zl) / 2);
                
                daspect([1 1 1]);
                
                view(48,2);
                lightangle(-45,30)
                h.FaceLighting = 'gouraud';
                h.EdgeLighting = 'none'; 
                h.AmbientStrength = 0.3;
                h.DiffuseStrength = 0.8;
                h.SpecularStrength = 0.9;
                h.SpecularExponent = 25;
                set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual', 'ZLimMode', 'manual');
                xlim([xl-10 xh+10]);
                ylim([yl-10 yh+10]);
                zlim([zl-10 zh+10]);
            else
                h.Faces = Fsurface;
                h.Vertices = Vsurface;
            
            end
            drawnow();
            F(i) = getframe;
            if i==1                
                vidSize = size(F(i).cdata);
            else
            end
            writeVideo(v,F(i));
            saveas(hfig,['Images/' num2str(i,'%03d') '.png']);
        end
    end
    if doPlot
        close(v)
    end