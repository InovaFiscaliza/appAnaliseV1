classdef (Abstract) datatip

    methods (Static = true)
        %-----------------------------------------------------------------%
        function [ParentTag, DataIndex, XData, YData] = Search(dtParent)

            hDataTip  = findobj(dtParent, 'Type', 'datatip');

            ParentTag = arrayfun(@(x) x.Parent.Tag, hDataTip, "UniformOutput", false);
            DataIndex = arrayfun(@(x) x.DataIndex,  hDataTip, "UniformOutput", false);
            XData     = arrayfun(@(x) x.X,          hDataTip, "UniformOutput", false);
            YData     = arrayfun(@(x) x.Y,          hDataTip, "UniformOutput", false);

        end


        %-----------------------------------------------------------------%
        function Create(callingFcn, dtConfig, dtParent)
            arguments
                callingFcn char {mustBeMember(callingFcn, {'customPlayback', 'redrawWaterfall'})}
                dtConfig   struct
                dtParent
            end

            switch callingFcn
                case 'customPlayback'
                    % dtConfig = struct('ParentTag', {}, 'DataIndex', {})
                    for ii = 1:numel(dtConfig)
                        hLine = findobj(dtParent, 'Tag', dtConfig(ii).ParentTag);

                        if ~isempty(hLine)
                            datatip(hLine(1), 'DataIndex', dtConfig(ii).DataIndex);
                        end
                    end

                case 'redrawWaterfall'
                    % dtConfig = struct('XData', {}, 'YData', {})
                    for ii = 1:numel(dtConfig)
                        datatip(dtParent, dtConfig(ii).XData, dtConfig(ii).YData);
                    end
            end
        end


        %-----------------------------------------------------------------%
        function Template(dtParent, dtType, varargin)
            arguments
                dtParent
                dtType char {mustBeMember(dtType, {'Frequency+Level', ...
                                                   'Frequency+Occupancy', ...
                                                   'Frequency+Timestamp+Level', ...
                                                   'Coordinates', ...
                                                   'Coordinates+Frequency' ...
                                                   'SweepID+ChannelPower+Coordinates' ...
                                                   'SweepID+ChannelPower' ...
                                                   'winRFDataHub.Geographic' ...
                                                   'winRFDataHub.SelectedNode' ...
                                                   'winRFDataHub.Histogram1' ...
                                                   'winRFDataHub.Histogram2' ...
                                                   'winRFDataHub.SimulationLink'})}
            end

            arguments (Repeating)
                varargin
            end

            if isempty(dtParent)
                return
            elseif ~isprop(dtParent, 'DataTipTemplate')
                % 'images.roi.line' e 'images.roi.Rectangle' não suportam DataTip
                try
                    dt = datatip(dtParent, Visible = 'off');
                catch
                    return
                end
            end

            set(dtParent.DataTipTemplate, FontName='Calibri', FontSize=10)

            switch dtType
                case 'Frequency+Level'
                    hUnit = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';                    
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                    try
                    dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f ' hUnit];
                    catch ME
                        ME
                    end

                case 'Frequency+Occupancy'
                    hUnit = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';                    
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                    dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f' hUnit];

                case 'Frequency+Timestamp+Level'
                    hUnit = varargin{1};

                    switch class(dtParent)
                        case 'matlab.graphics.chart.primitive.Surface'
                            dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(2).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(3).Label  = '';
                                            
                            dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f MHz';
                            dtParent.DataTipTemplate.DataTipRows(2).Format =  'dd/MM/yyyy HH:mm:ss';
                            dtParent.DataTipTemplate.DataTipRows(3).Format =  ['%.1f ' hUnit];

                        case 'matlab.graphics.primitive.Image'
                            dtParent.DataTipTemplate.DataTipRows(1).Label  = '';
                            dtParent.DataTipTemplate.DataTipRows(2).Label  = '';

                            dtParent.DataTipTemplate.DataTipRows(1).Format = '%.3f';
                            dtParent.DataTipTemplate.DataTipRows(2).Format = ['%.1f ' hUnit];
                            dtParent.DataTipTemplate.DataTipRows(3)        = [];
                    end

                case 'Coordinates'
                    dtParent.DataTipTemplate.DataTipRows(1).Label = 'Latitude:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label = 'Longitude:';
                    if numel(dtParent.DataTipTemplate.DataTipRows) > 2
                        dtParent.DataTipTemplate.DataTipRows(3:end) = [];
                    end

                case 'Coordinates+Frequency'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1).Label = 'Latitude:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label = 'Longitude:';
                    dtParent.DataTipTemplate.DataTipRows(3)       = dataTipTextRow('Frequência:', hTable.Frequency, '%.3f MHz');
                    dtParent.DataTipTemplate.DataTipRows(4)       = dataTipTextRow('Entidade:',   hTable.Name);

                    dtParent.DataTipTemplate.DataTipRows          = dtParent.DataTipTemplate.DataTipRows([3:4,1:2]);

                case 'SweepID+ChannelPower+Coordinates'
                    hTable = table((1:numel(dtParent.LatitudeData))', 'VariableNames', {'ID'});

                    dtParent.DataTipTemplate.DataTipRows(1).Label = 'Latitude:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label = 'Longitude:';
                    dtParent.DataTipTemplate.DataTipRows(3)       = dataTipTextRow('ID:', hTable.ID);
                    dtParent.DataTipTemplate.DataTipRows(4)       = dataTipTextRow('Potência:', 'CData', '%.1f dBm');

                    if numel(dtParent.DataTipTemplate.DataTipRows) > 4
                        dtParent.DataTipTemplate.DataTipRows(5:end) = [];
                    end

                    dtParent.DataTipTemplate.DataTipRows          = dtParent.DataTipTemplate.DataTipRows([3:4,1:2]);

                case 'SweepID+ChannelPower'
                    hUnit = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1).Label = 'ID:';
                    dtParent.DataTipTemplate.DataTipRows(2)       = dataTipTextRow('Potência:', 'YData', ['%.1f ' hUnit]);


                case 'winRFDataHub.Geographic'
                    hTable = varargin{1};

                    dtParent.DataTipTemplate.DataTipRows(1)     = dataTipTextRow('', hTable.Frequency, '%.3f MHz');
                    dtParent.DataTipTemplate.DataTipRows(2)     = dataTipTextRow('', hTable.Distance,  '%.0f km');

                    ROWS = height(hTable);
                    if ROWS == 1
                        dtParent.DataTipTemplate.DataTipRows(3) = dataTipTextRow('ID:', {hTable{:,1}});
                        dtParent.DataTipTemplate.DataTipRows(4) = dataTipTextRow('',    {hTable{:,5}});

                    elseif ROWS > 1
                        dtParent.DataTipTemplate.DataTipRows(3) = dataTipTextRow('ID:', hTable{:,1});
                        dtParent.DataTipTemplate.DataTipRows(4) = dataTipTextRow('',    hTable{:,5});
                    end

                    dtParent.DataTipTemplate.DataTipRows        = dtParent.DataTipTemplate.DataTipRows([3,1,4,2]);

                case 'winRFDataHub.SelectedNode'
                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Latitude:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Longitude:';

                    if numel(dtParent.DataTipTemplate.DataTipRows) > 2
                        dtParent.DataTipTemplate.DataTipRows(3:end) = [];
                    end

                case 'winRFDataHub.Histogram1'
                    dtParent.DataTipTemplate.DataTipRows           = flip(dtParent.DataTipTemplate.DataTipRows);
                    
                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Banda (MHz):';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Registros:';

                case 'winRFDataHub.Histogram2'
                    dtParent.DataTipTemplate.DataTipRows           = flip(dtParent.DataTipTemplate.DataTipRows);

                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Serviço:';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Registros:';

                case 'winRFDataHub.SimulationLink'
                    dtParent.DataTipTemplate.DataTipRows(1).Label  = 'Distância:';
                    dtParent.DataTipTemplate.DataTipRows(1).Format = '%.1f km';
                    dtParent.DataTipTemplate.DataTipRows(2).Label  = 'Elevação:';
                    dtParent.DataTipTemplate.DataTipRows(2).Format = '%.1f m';
            end

            if exist('dt', 'var')
                delete(dt)
            end
        end
    end
end