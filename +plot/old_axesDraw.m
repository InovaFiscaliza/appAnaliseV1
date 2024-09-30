classdef (Abstract) old_axesDraw

    properties (Constant)
        %-----------------------------------------------------------------%
        figureSize = [1244, 660] % antigo: [650, 800]
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function execute(plotName, hAxes, SpecInfo, Parameters, srcFcn)
            cla(hAxes)
            switch plotName
                case 'Spectrum';         plot.old_axesDraw.cartesianAxes__type1(hAxes, SpecInfo, Parameters)
                case 'Persistance';      plot.old_axesDraw.cartesianAxes__type2(hAxes, SpecInfo, Parameters)
                case 'OccupancyPerBin';  plot.old_axesDraw.cartesianAxes__type3(hAxes, SpecInfo, Parameters)
                case 'Waterfall';        plot.old_axesDraw.cartesianAxes__type4(hAxes, SpecInfo, Parameters)
              % case 'OccupancyPerHour'; plot.old_axesDraw.cartesianAxes__type5(hAxes, SpecInfo, Parameters)
              % case 'OccupancyPerDay';  plot.old_axesDraw.cartesianAxes__type6(hAxes, SpecInfo, Parameters)
              % case 'SamplesPerLevel';  plot.old_axesDraw.cartesianAxes__type7(hAxes, SpecInfo, Parameters)
              % case 'ChannelPower';     plot.old_axesDraw.cartesianAxes__type8(hAxes, SpecInfo, Parameters)
                case 'DriveTest';        plot.old_axesDraw.geographicAxes_type1(hAxes, Parameters, srcFcn)
                case 'DriveTestRoute';   plot.old_axesDraw.geographicAxes_type2(hAxes, Parameters)
              % case 'Stations';         plot.old_axesDraw.geographicAxes_type3(hAxes, SpecInfo, Parameters)
              % case 'Link';             plot.old_axesDraw.geographicAxes_type4(hAxes, SpecInfo, Parameters)
            end
        end


        %-----------------------------------------------------------------%
        % EIXO CARTESIANO: CONTROLE
        %-----------------------------------------------------------------%
        function cartesianAxes__type1(hAxes, SpecInfo, Parameters)          % Spectrum
            MinHold  = Parameters.MinHold;
            Average  = Parameters.Average;
            MaxHold  = Parameters.MaxHold;
            ROI      = Parameters.EmissionROI;
            Axes     = Parameters.Axes;

            % PRÉ-PLOT
            [xLim, yLim, ~, xIndexLim, xArray] = plot.old_axesDraw.Limits(SpecInfo, Parameters, 'ordinary level');
            plot.old_prePlotConfiguration(hAxes, xLim, yLim, 'linear')
        
            % PLOT
            plot.old_axesDraw.OrdinaryPlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, 'MinHold', MinHold)
            plot.old_axesDraw.OrdinaryPlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, 'Average', Average)
            plot.old_axesDraw.OrdinaryPlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, 'MaxHold', MaxHold)            
            plot.old_axesDraw.BandLimitsPlot(hAxes, SpecInfo)
            plot.old_axesDraw.EmissionPlot(hAxes, SpecInfo, yLim, ROI)            
            plot.old_axesDraw.ThresholdPlot(hAxes, SpecInfo, xArray)

            plot.axes.StackingOrder.execute(hAxes, 'appAnalise:REPORT')

            % PÓS-PLOT
            plot.old_axesDraw.PostPlotConfig(hAxes, SpecInfo, Axes, 'Frequência (MHz)', ['Nível (' SpecInfo.MetaData.LevelUnit ')'])
        end


        %-----------------------------------------------------------------%
        function cartesianAxes__type2(hAxes, SpecInfo, Parameters)          % Persistance
            Average     = Parameters.Average;
            EmissionROI = Parameters.EmissionROI;
            Persistance = Parameters.Persistance;
            Axes        = Parameters.Axes;
            
            % PRÉ-PLOT
            [xLim, yLim, ~, xIndexLim, xArray] = plot.old_axesDraw.Limits(SpecInfo, Parameters, 'persistance level');
            plot.old_prePlotConfiguration(hAxes, xLim, yLim, 'linear', Persistance.Colormap)
            
            % PLOT        
            plot.old_axesDraw.PersistancePlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, Persistance)
            plot.old_axesDraw.OrdinaryPlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, 'Average', Average)
            plot.old_axesDraw.BandLimitsPlot(hAxes, SpecInfo)
            plot.old_axesDraw.EmissionPlot(hAxes, SpecInfo, yLim, EmissionROI);            
            plot.old_axesDraw.ThresholdPlot(hAxes, SpecInfo, xArray)

            plot.axes.StackingOrder.execute(hAxes, 'appAnalise:REPORT')

            % PÓS-PLOT
            plot.old_axesDraw.PostPlotConfig(hAxes, SpecInfo, Axes, 'Frequência (MHz)', ['Nível (' SpecInfo.MetaData.LevelUnit ')'])
        end


        %-----------------------------------------------------------------%
        function cartesianAxes__type3(hAxes, SpecInfo, Parameters)          % OccupancyPerBin
            occMinHold = Parameters.occMinHold;
            occAverage = Parameters.occAverage;
            occMaxHold = Parameters.occMaxHold;
            Axes       = Parameters.Axes;

            % PRÉ-PLOT
            [xLim, yLim, ~, xIndexLim, xArray] = plot.old_axesDraw.Limits(SpecInfo, Parameters, 'occupancy level');
            plot.old_prePlotConfiguration(hAxes, xLim, yLim, 'log')
        
            % PLOT
            plot.old_axesDraw.OccupancyPerBinPlot(hAxes, SpecInfo, xIndexLim, xArray, 'occMinHold', occMinHold)
            plot.old_axesDraw.OccupancyPerBinPlot(hAxes, SpecInfo, xIndexLim, xArray, 'occAverage', occAverage)
            plot.old_axesDraw.OccupancyPerBinPlot(hAxes, SpecInfo, xIndexLim, xArray, 'occMaxHold', occMaxHold)

            % PÓS-PLOT
            plot.old_axesDraw.PostPlotConfig(hAxes, SpecInfo, Axes, 'Frequência (MHz)', 'Ocupação (%)')
        end


        %-----------------------------------------------------------------%
        function cartesianAxes__type4(hAxes, SpecInfo, Parameters)          % Waterfall
            Waterfall = Parameters.Waterfall;
            Axes      = Parameters.Axes;

            % PRÉ-PLOT
            switch Waterfall.Fcn
                case 'mesh';  yUnit = 'time';
                case 'image'; yUnit = 'timeIndex';
            end
            [xLim, yLim, ~, xIndexLim, xArray] = plot.old_axesDraw.Limits(SpecInfo, Parameters, yUnit);
            plot.old_prePlotConfiguration(hAxes, xLim, yLim, 'linear', Waterfall.Colormap)

            % PLOT
            plot.old_axesDraw.WaterfallPlot(hAxes, SpecInfo, xIndexLim, xArray, Waterfall)

            % PÓS-PLOT
            plot.old_axesDraw.PostPlotConfig(hAxes, SpecInfo, Axes, 'Frequência (MHz)', 'Amostras')
        end


        %-----------------------------------------------------------------%
        % EIXO CARTESIANO: PLOT
        %-----------------------------------------------------------------%
        function OrdinaryPlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, plotMode, TraceMode)
            switch plotMode
                case 'MinHold'; idx = 1;
                case 'Average'; idx = 2;
                case 'MaxHold'; idx = 3;
            end

            switch TraceMode.Fcn
                case 'line'
                    p = plot(hAxes, xArray, SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),idx), 'Tag', plotMode, 'LineStyle', TraceMode.LineStyle, 'LineWidth', TraceMode.LineWidth, 'Color', TraceMode.EdgeColor);
                case 'area'
                    p = area(hAxes, xArray, SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),idx), 'Tag', plotMode, 'LineStyle', TraceMode.LineStyle, 'LineWidth', TraceMode.LineWidth, 'EdgeColor', TraceMode.EdgeColor, 'FaceColor', TraceMode.FaceColor, 'BaseValue', yLim(1));
            end
            plot.datatip.Template(p, 'Frequency+Level', SpecInfo.MetaData.LevelUnit)
        end


        %-----------------------------------------------------------------%
        function PersistancePlot(hAxes, SpecInfo, xIndexLim, xArray, yLim, Persistance)
            DataPoints  = numel(xArray);
            nSweeps     = numel(SpecInfo.Data{1});

            xResolution = min(801, DataPoints);
            yResolution = 201;

            xEdges      = linspace(xArray(1), xArray(end), xResolution+1);
            yEdges      = linspace(yLim(1), yLim(2), yResolution+1);

            specHist    = histcounts2(SpecInfo.Data{2}(xIndexLim(1):xIndexLim(2),:), repmat(xArray', 1, nSweeps), yEdges, xEdges);    

            image(hAxes, specHist, 'XData', [xArray(1), xArray(end)], 'YData', yLim, 'CData', (100 * specHist ./ sum(specHist)), ...
                                   'AlphaData', specHist, 'CDataMapping', 'scaled', 'Interpolation', Persistance.Interpolation,   ...
                                   'PickableParts', 'none', 'Tag', 'Persistance');
        end


        %-----------------------------------------------------------------%
        function WaterfallPlot(hAxes, SpecInfo, xIndexLim, xArray, Waterfall)
            DataPoints  = numel(xArray);
            nSweeps     = numel(SpecInfo.Data{1});

            switch Waterfall.Fcn
                case 'mesh'
                    nWaterFallPoints    = DataPoints*nSweeps;
                    nMaxWaterFallPoints = class.Constants.nMaxWaterFallPoints;
                    if nWaterFallPoints > nMaxWaterFallPoints; Decimate = ceil(nWaterFallPoints/nMaxWaterFallPoints);
                    else;                                      Decimate = 1;
                    end
        
                    while true
                        tArray = SpecInfo.Data{1}(1:Decimate:end);
                        if numel(tArray) > 1; break
                        else;                 Decimate = round(Decimate/2);
                        end
                    end
        
                    if tArray(1) == tArray(end)
                        tArray(end) = tArray(1)+seconds(1);
                    end
        
                    [X, Y] = meshgrid(xArray, tArray);
                    p = mesh(hAxes, X, Y, SpecInfo.Data{2}(xIndexLim(1):xIndexLim(2),1:Decimate:end)', 'MeshStyle', Waterfall.MeshStyle, 'SelectionHighlight', 'off', 'Tag', 'Waterfall');                    

                case 'image'
                    p = image(hAxes, xArray, 1:nSweeps, SpecInfo.Data{2}(xIndexLim(1):xIndexLim(2),:)', 'CDataMapping', 'scaled', 'Tag', 'Waterfall');                    
            end
            plot.datatip.Template(p, 'Frequency+Timestamp+Level', SpecInfo.MetaData.LevelUnit)

            hAxes.CLim(2) = round(hAxes.CLim(2));
            hAxes.CLim(1) = round(hAxes.CLim(2) - diff(hAxes.CLim)/2);
        end


        %-----------------------------------------------------------------%
        function OccupancyPerBinPlot(hAxes, SpecInfo, xIndexLim, xArray, plotMode, Occupancy)
            occIndex = SpecInfo.UserData.occMethod.CacheIndex;
            if isempty(occIndex)
                return
            end

            switch plotMode
                case 'occMinHold'; idx = 1;
                case 'occAverage'; idx = 2;
                case 'occMaxHold'; idx = 3;
            end

            occData = SpecInfo.UserData.occCache(occIndex).Data{3}(:,idx);
            occData(occData==0) = .1;

            switch Occupancy.Fcn
                case 'line'
                    p = plot(hAxes, xArray, occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'Color', Occupancy.EdgeColor);
                case 'area'
                    p = area(hAxes, xArray, occData(xIndexLim(1):xIndexLim(2)), 'Tag', plotMode, 'LineStyle', Occupancy.LineStyle, 'LineWidth', Occupancy.LineWidth, 'EdgeColor', Occupancy.EdgeColor, 'FaceColor', Occupancy.FaceColor, 'BaseValue', .1);
            end
            plot.datatip.Template(p, 'Frequency+Occupancy', '%%')
        end


        %-----------------------------------------------------------------%
        function EmissionPlot(hAxes, SpecInfo, yLim, ROI)
            pks = SpecInfo.UserData.Emissions;
            if ~isempty(pks)
                for ii = 1:height(pks)
                    if ischar(ROI.Color)
                        ROI.Color = hex2rgb(ROI.Color);
                    end
                    drawrectangle(hAxes, 'Position', [pks.Frequency(ii)-pks.BW(ii)/2000, yLim(1)+1, pks.BW(ii)/1000, diff(yLim)-2],                   ...
                                         'Color', ROI.Color, 'EdgeAlpha', ROI.EdgeAlpha, 'FaceAlpha', ROI.FaceAlpha, 'MarkerSize', 5, 'LineWidth', 1, ...
                                         'Deletable', 0, 'InteractionsAllowed', 'none', 'Tag', 'mkrROI');
                end

                NN = height(pks);
                pksLabel = string((1:NN)'); % Opcionalmente: "P_" + string((1:NN)')
                text(hAxes, pks.Frequency, repmat(yLim(1)+ROI.LabelOffset, NN, 1), pksLabel, ...
                           'Color', ROI.LabelColor, 'BackgroundColor', ROI.Color,            ...
                           'FontSize', ROI.LabelFontSize, 'FontWeight', 'bold',              ...
                           'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'PickableParts', 'none', 'Tag', 'mkrLabels');
            end
        end


        %-----------------------------------------------------------------%
        function ThresholdPlot(hAxes, SpecInfo, xArray)
            occIndex = SpecInfo.UserData.occMethod.CacheIndex;
            if isempty(occIndex)
                return
            end

            occMethod = SpecInfo.UserData.occCache(occIndex).Info.Method;
            occTHR    = SpecInfo.UserData.occCache(occIndex).THR;

            switch occMethod
                case {'Linear fixo (COLETA)', 'Linear fixo'}
                    p    = plot(hAxes, [xArray(1), xArray(end)], [occTHR, occTHR]);
                case 'Linear adaptativo'
                    [minTHR, maxTHR] = bounds(occTHR);
                    p(1) = plot(hAxes, [xArray(1), xArray(end)], [minTHR, minTHR]);
                    p(2) = plot(hAxes, [xArray(1), xArray(end)], [maxTHR, maxTHR]);
                case 'Envoltória do ruído'
                    p    = plot(hAxes, xArray, occTHR);
            end
            arrayfun(@(x) set(x, Color='red', LineStyle='-.', LineWidth=.5, Marker='o',                                           ...
                                 MarkerSize=4, MarkerIndices=[1, numel(x.XData)], MarkerFaceColor='red', MarkerEdgeColor='black', ...
                                 PickableParts='none', Tag='occTHR'), p)
        end


        %-----------------------------------------------------------------%
        function BandLimitsPlot(hAxes, SpecInfo)
            if SpecInfo.UserData.bandLimitsStatus
                yLevel = hAxes.YLim(2)-1;
            
                for ii = 1:height(SpecInfo.UserData.bandLimitsTable)
                    FreqStart = SpecInfo.UserData.bandLimitsTable.FreqStart(ii);
                    FreqStop  = SpecInfo.UserData.bandLimitsTable.FreqStop(ii);
                    
                    % Cria uma linha por subfaixa a analise, posicionando-o na parte 
                    % inferior do plot.
                    line(hAxes, [FreqStart, FreqStop], [yLevel, yLevel], ...
                                Color=[.5 .5 .5], LineWidth=5,           ...
                                PickableParts='none',  Tag='BandLimits')
                end
            end
        end


        %-----------------------------------------------------------------%
        % EIXO GEOGRÁFICO: CONTROLE
        %-----------------------------------------------------------------%
        function geographicAxes_type1(hAxes, Parameters, srcFcn)
            if isempty(Parameters)
                error('Unexpected parameters value.')
            end

            % PRÉ-PLOT
            cla(hAxes)

            % AJUSTE DO BASEMAP
            if isfield(Parameters, 'Basemap') && ~strcmp(hAxes.Basemap, Parameters.Basemap)
                hAxes.Basemap = Parameters.Basemap;
            end

            % PLOT
            if strcmp(srcFcn, 'ReportGenerator')
                plot.old_axesDraw.DriveTestFilterPlot(hAxes, Parameters, 'GeographicPlot');
            end            
            plot.old_axesDraw.DriveTestRoutePlot(hAxes, Parameters)
            plot.old_axesDraw.DriveTestPointsPlot(hAxes, Parameters);

            hDistortionVisibility = 0;
            hDensityVisibility    = 0;
            switch Parameters.plotType
                case 'distortion'
                    hDistortionVisibility = 1;
                case 'density'
                    hDensityVisibility    = 1;
            end

            switch Parameters.Source
                case {'Raw', 'Filtered'}
                    srcTable = Parameters.specFilteredTable;
                case 'Data-Binning'
                    srcTable = Parameters.specBinTable;
            end

            plot.old_axesDraw.DriveTestDistortionlPlot(hAxes, srcTable, Parameters, hDistortionVisibility);
            plot.old_axesDraw.DriveTestDensityPlot(hAxes, srcTable, Parameters, hDensityVisibility);
            geolimits(hAxes, 'auto')

            % PÓS-PLOT
            plot.axes.StackingOrder.execute(hAxes, 'appAnalise:DRIVETEST')
        end


        %-----------------------------------------------------------------%
        function geographicAxes_type2(hAxes, Parameters)
            if isempty(Parameters)
                error('Unexpected parameters value.')
            end

            % PLOT
            specData   = Parameters.specData;
            gpsPerFile = vertcat(specData.RelatedFiles.GPS{:});
            gpsMatrix  = vertcat(gpsPerFile.Matrix);

            geoplot(hAxes, gpsMatrix(:,1), gpsMatrix(:,2));
            geolimits(hAxes, 'auto')
        end
        
        
        %-----------------------------------------------------------------%
        % EIXO GEOGRÁFICO: PLOT
        %-----------------------------------------------------------------%
        function DriveTestFilterPlot(hAxes, Parameters, plotType)
            delete(findobj(hAxes.Children, 'Tag', 'FilterROI'))

            filterTable = Parameters.filterTable;

            for ii = 1:height(filterTable)
                subtype = filterTable.subtype{ii};

                switch subtype
                    case 'Threshold'
                        if ~strcmp(plotType, 'CartesianPlot')
                            continue
                        end
                        hROI = images.roi.Line(hAxes, 'Color', 'red', 'MarkerSize', 4, 'LineWidth', 1, 'Deletable', 0, 'InteractionsAllowed', 'translate', 'Tag', 'FilterROI');

                    case {'Circle', 'Rectangle', 'Polygon'}
                        if ~strcmp(plotType, 'GeographicPlot')
                            continue
                        end

                        switch subtype
                            case 'Circle';    roiFcn = 'Circle';    roiNameArgument = '';
                            case 'Rectangle'; roiFcn = 'Rectangle'; roiNameArgument = 'Rotatable=true, ';
                            case 'Polygon';   roiFcn = 'Polygon';   roiNameArgument = '';
                        end
                        eval(sprintf('hROI = images.roi.%s(hAxes, LineWidth=1, Deletable=0, FaceSelectable=0, %sTag="FilterROI");', roiFcn, roiNameArgument))
                end

                fieldsList = fields(filterTable.roi(ii).specification);
                for jj = 1:numel(fieldsList)
                    hROI.(fieldsList{jj}) = filterTable.roi(ii).specification.(fieldsList{jj});
                end
            end
        end

        %-----------------------------------------------------------------%
        function DriveTestRoutePlot(hAxes, Parameters)
            delete(findobj(hAxes.Children, 'Tag', 'OutRoute', '-or', 'Tag', 'InRoute'))

            specTable   = Parameters.specRawTable;
            filtTable   = Parameters.specFilteredTable;

            OutTable    = specTable(~specTable.Filtered,:);
            InTable     = filtTable;

            switch Parameters.route_LineStyle
                case 'none'; markerSize = 1;
                otherwise;   markerSize = 8*Parameters.route_MarkerSize;
            end

            geoplot(hAxes, OutTable.Latitude, OutTable.Longitude, 'Marker', '.', 'Color', Parameters.route_OutColor, 'MarkerFaceColor', Parameters.route_OutColor, 'MarkerEdgeColor', Parameters.route_OutColor, 'MarkerSize', markerSize, 'LineStyle', 'none',                     'Tag', 'OutRoute');
            geoplot(hAxes,  InTable.Latitude,  InTable.Longitude, 'Marker', '.', 'Color', Parameters.route_InColor,  'MarkerFaceColor', Parameters.route_InColor,  'MarkerEdgeColor', Parameters.route_InColor,  'MarkerSize', markerSize, 'LineStyle', Parameters.route_LineStyle, 'Tag', 'InRoute');
        end

        %-----------------------------------------------------------------%
        function DriveTestDistortionlPlot(hAxes, srcTable, Parameters, hDistortionVisibility)
            geoscatter(hAxes, srcTable.Latitude, srcTable.Longitude, [], srcTable.ChannelPower, ...
                'filled', 'SizeData', 20*Parameters.plotSize, 'Tag', 'Distortion', 'Visible', hDistortionVisibility);
        end


        %-----------------------------------------------------------------%
        function hDensity = DriveTestDensityPlot(hAxes, srcTable, Parameters, hDensityVisibility)
            weights = srcTable.ChannelPower;
            if min(weights) < 0
                weights = weights+abs(min(weights));
            end

            geodensityplot(hAxes, srcTable.Latitude, srcTable.Longitude, weights, ...
                'FaceColor','interp', 'Radius', 100*Parameters.plotSize,          ...
                'PickableParts', 'none', 'Tag', 'Density', 'Visible', hDensityVisibility);
        end


        %-----------------------------------------------------------------%
        function DriveTestPointsPlot(hAxes, Parameters)
            delete(findobj(hAxes.Children, 'Tag', 'Points'))
            pointsTable = Parameters.pointsTable;

            for ii = 1:height(pointsTable)
                if ~pointsTable.visible(ii)
                    continue
                end

                Coordinates = pointsTable.value(ii).Coordinates;
                switch pointsTable.type{ii}
                    case 'RFDataHub'
                        hStation = geoplot(hAxes, Coordinates(:,1), Coordinates(:,2),                                                        ...
                                                  'LineStyle', 'none', 'Color', Parameters.points_Color, 'Marker', Parameters.points_Marker, ...
                                                  'MarkerSize', Parameters.points_Size, 'MarkerFaceColor', Parameters.points_Color,          ...
                                                  'MarkerEdgeColor', Parameters.points_Color, 'Tag', 'Points');
                    case 'FindPeaks'
                        geoplot(hAxes, Coordinates(:,1), Coordinates(:,2),                                                                          ...
                                       'LineStyle', 'none', 'Color', Parameters.points_Color, 'Marker', Parameters.points_Marker,                   ...
                                       'MarkerSize', Parameters.points_Size, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', Parameters.points_Color, ...
                                       'PickableParts', 'none', 'Tag', 'Points');
                end
            end
        end


        %-----------------------------------------------------------------%
        % FUNÇÕES AUXILIARES
        %-----------------------------------------------------------------%
        function [imgFileName, hContainer] = plot2report(hContainer, SpecInfo, reportInfo, plotInfo)
            % Limpa container.
            if ~isempty(hContainer.Children)
                delete(hContainer.Children)
            end

            % Criação dos eixos e disposição no layout indicado no JSON do
            % modelo do relatório.
            if strcmp(reportInfo.General.Parameters.Plot.Type, 'Emission')
                idxDriveTest = find(strcmp({plotInfo.Name}, 'DriveTest'));
                idxEmission  = reportInfo.General.Parameters.Plot.emissionIndex;
                
                if ~isempty(idxDriveTest) && isempty(SpecInfo.UserData.Emissions.UserData(idxEmission).DriveTest)
                    plotInfo(idxDriveTest) = [];
                end
            end

            if isempty(plotInfo)
                error('Empty plot list!')
            end

            tiledPos  = 1;
            tiledSpan = [plotInfo.Layout];

            t = tiledlayout(hContainer, sum(tiledSpan), 1, "Padding", "tight", "TileSpacing", "tight");
           
            axesType = plot.old_DataAxesTypeMapping({plotInfo.Name});

            for ii = 1:numel(plotInfo)
                switch plotInfo(ii).Name
                    case 'DriveTest'; Parameters = reportInfo.General.Parameters.DriveTest;
                    otherwise;        Parameters = reportInfo.General.Parameters;
                end

                hAxes     = plot.axes.Creation(t, axesType{ii});
                xTickFlag = true;

                switch axesType{ii}
                    case 'Geographic'
                        geolimits(hAxes, 'auto')
                    case 'Cartesian'
                        if (numel(plotInfo) > 1) && (ii < numel(plotInfo)) && any(strcmp(axesType(2:end), 'Cartesian'))
                            xTickFlag = false;
                        end
                end

                hAxes.Layout.Tile     = tiledPos;
                hAxes.Layout.TileSpan = [tiledSpan(ii) 1];

                plot.old_axesDraw.execute(plotInfo(ii).Name, hAxes, SpecInfo, Parameters, 'ReportGenerator')

                if ~xTickFlag
                    hAxes.XTickLabel = {};
                    xlabel(hAxes, '')
                end
                tiledPos = tiledPos+tiledSpan(ii);
            end

            % Espera renderizar e salva a imagem...
            defaultFilename = class.Constants.DefaultFileName(reportInfo.General.UserPath, sprintf('Image_ID%d', SpecInfo.RelatedFiles.ID(1)), -1);
            imgFileName     = sprintf('%s.%s', defaultFilename, reportInfo.General.Image.Format);
            if ~strcmp(reportInfo.General.Version, 'Definitiva')
                imgFileName = replace(imgFileName, 'Image', '~Image');
            end
            
            exportgraphics(hContainer, imgFileName, 'ContentType', 'image', 'Resolution', reportInfo.General.Image.Resolution)
            drawnow nocallbacks
            while true
                pause(.100)
                if isfile(imgFileName)
                    break
                end
            end
        end

        %-----------------------------------------------------------------%
        function PostPlotConfig(hAxes, SpecInfo, Axes, xUnit, yUnit)
            % xyLabels
            if Axes.xLabel;     xlabel(hAxes, xUnit)
            else;               xlabel(hAxes, '')
            end

            if Axes.yLabel;     ylabel(hAxes, yUnit)
            else;               ylabel(hAxes, '')
            end

            % xyTicks
            [xTick, xTickLabel, yTick, yTickLabel] = plot.old_axesDraw.Tick(hAxes, SpecInfo);
            set(hAxes, 'XTick', xTick, 'YTick', yTick);

            if Axes.xTickLabel; hAxes.XTickLabel = xTickLabel;
            else;               hAxes.XTickLabel = {};
            end

            if Axes.yTickLabel; hAxes.YTickLabel = yTickLabel;
            else;               hAxes.YTickLabel = {};
            end
        end


        %-----------------------------------------------------------------%
        function [xLim, yLim, zLim, xIndexLim, xArray] = Limits(SpecInfo, Parameters, yUnit)
            FreqStart     = SpecInfo.MetaData.FreqStart / 1e+6;
            FreqStop      = SpecInfo.MetaData.FreqStop  / 1e+6;
            DataPoints    = SpecInfo.MetaData.DataPoints;

            xArray        = round(linspace(FreqStart, FreqStop, DataPoints), 3);            

            switch Parameters.Plot.Type
                case 'Band'
                    FreqStartView = FreqStart;
                    FreqStopView  = FreqStop;
                    xIndexLim     = [1, DataPoints];

                case 'Emission'
                    emissionIndex = Parameters.Plot.emissionIndex;
                    if emissionIndex == -1
                        error('Unexpected value.')
                    end
    
                    emissionBW    = SpecInfo.UserData.Emissions.BW(emissionIndex)/1000;
                    xGuardBand    = Parameters.Axes.xGuardBandFactor * emissionBW;
    
                    FreqStartView = SpecInfo.UserData.Emissions.Frequency(emissionIndex) - (emissionBW + xGuardBand)/2;
                    FreqStopView  = SpecInfo.UserData.Emissions.Frequency(emissionIndex) + (emissionBW + xGuardBand)/2;
                    xIndexLim     = [plot.old_axesDraw.freq2idx(SpecInfo, FreqStartView*1e+6, 'fix'), plot.old_axesDraw.freq2idx(SpecInfo, FreqStopView*1e+6, 'ceil')];

                    xArray        = xArray(xIndexLim(1):xIndexLim(2));
            end

            xLim = [FreqStartView, FreqStopView];

            switch yUnit
                case {'ordinary level', 'persistance level'}
                    yLim = plot.old_axesDraw.yzLimits(SpecInfo, yUnit, xIndexLim);
                    zLim = [-1, 1];
                case 'occupancy level'
                    yLim = [0, 100];
                    zLim = [-1, 1];
                case 'time'
                    yLim = [SpecInfo.Data{1}(1), SpecInfo.Data{1}(end)];
                    zLim = plot.old_axesDraw.yzLimits(SpecInfo, yUnit, xIndexLim);
                case 'timeIndex'
                    yLim = [1, numel(SpecInfo.Data{1})];
                    zLim = [-1, 1];
            end
        end


        %-----------------------------------------------------------------%
        function yzLim = yzLimits(SpecInfo, yUnit, xIndexLim)
            yzLim  = [min(SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),1)), max(SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),end))];

            if ismember(yUnit, {'persistance level', 'time'})
                yzAmplitude = class.Constants.yMaxLimRange;

                yzLim(2)    = max(yzLim(1)+yzAmplitude, yzLim(2));
                yzLim(1)    = yzLim(2)-yzAmplitude;
            end
        end


        %-----------------------------------------------------------------%
        function idx = freq2idx(SpecInfo, FrequencyInHertz, RoundType)
            FreqStartInHertz = SpecInfo.MetaData.FreqStart;
            FreqStopInHertz  = SpecInfo.MetaData.FreqStop;
            DataPoints       = SpecInfo.MetaData.DataPoints;

            % FrequencyInHertz = aCoef * idx + bCoef;
            aCoef = (FreqStopInHertz - FreqStartInHertz) / (DataPoints - 1);
            bCoef = FreqStartInHertz - aCoef;

            switch RoundType
                case 'fix';  idx = fix((FrequencyInHertz  - bCoef) / aCoef);
                case 'ceil'; idx = ceil((FrequencyInHertz - bCoef) / aCoef);
            end

            if idx < 1
                idx = 1;
            elseif idx > DataPoints
                idx = DataPoints;
            end
        end


        %-----------------------------------------------------------------%
        function [xTick, xTickLabel, yTick, yTickLabel] = Tick(hAxes, SpecInfo)
            xTickFlag = true;
            yTickFlag = true;

            for ii = 5:-1:1
                if xTickFlag
                    xTick = linspace(hAxes.XLim(1), hAxes.XLim(2), ii);

                    if issorted(xTick, "strictascend")
                        xTickFlag  = false;
                        xTickLabel = string(round(xTick, 3));
                    end
                end

                if yTickFlag
                    yTick = linspace(hAxes.YLim(1), hAxes.YLim(2), ii);

                    if issorted(yTick, "strictascend")
                        yTickFlag = false;

                        switch class(yTick)
                            case 'datetime'
                                yTickLabel = [];
                                for jj = 1:numel(yTick)
                                    [~, yTickIndex]   = min(abs(SpecInfo.Data{1} - yTick(jj)));
                                    yTickLabel(end+1) = yTickIndex;
                                end
                            otherwise
                                yTickLabel = round(yTick);
                        end
                        yTickLabel = string(yTickLabel);
                    end
                end

                if ~xTickFlag && ~yTickFlag
                    break
                end
            end
        end
    end
end