classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'appAnalise'
        appRelease    = 'R2024a'
        appVersion    = '1.80'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]

        gps2locAPI    = 'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=<Latitude>&longitude=<Longitude>&localityLanguage=pt'
        gps2loc_City  = 'city'
        gps2loc_Unit  = 'principalSubdivisionCode'

        Interactions  = {'datacursor', 'zoomin', 'restoreview'}

        yMinLimRange  = 80                                                  % Minimum y-Axis limit range
        yMaxLimRange  = 100                                                 % Maximum y-Axis limit range

        specDataTypes = [1, 2, 4, 7, 60, 61, 63, 64, 67, 68, 167, 168, 1000, 1809];
        occDataTypes  = [8, 62, 65, 69];

        xDecimals     = 5
        
        floatDiffTolerance  = 1e-5
        nMaxWaterFallPoints = 1474560
        ElevationTolerance  = .85

        reportOCC            = struct('Method',    'Linear adaptativo',           ...
                                                   'IntegrationTime',     15,     ...
                                                   'Offset',              12,     ...
                                                   'noiseFcn',            'mean', ...
                                                   'noiseTrashSamples',   0.10,   ...
                                                   'noiseUsefulSamples',  0.20)
        reportDetection      = struct('ManualMode', 0,                            ...
                                      'Algorithm', 'FindPeaks+OCC',               ...
                                      'Parameters', struct('Distance',    25,     ... % kHz
                                                           'BW',          10,     ... % kHz
                                                           'Prominence1', 10,     ...
                                                           'Prominence2', 30,     ...
                                                           'meanOCC',     10,     ...
                                                           'maxOCC',      67))
        reportClassification = struct('Algorithm',  'Frequency+Distance Type 1',  ...
                                      'Parameters', struct('Contour', 30,         ...
                                                           'ClassMultiplier', 2,  ...
                                                           'bwFactors', [100, 300]))
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function fileName = DefaultFileName(userPath, Prefix, Issue)
            fileName = fullfile(userPath, sprintf('%s_%s', Prefix, datestr(now,'yyyy.mm.dd_THH.MM.SS')));

            if Issue > 0
                fileName = sprintf('%s_%d', fileName, Issue);
            end
        end


        %-----------------------------------------------------------------%
        function [upYLim, strUnit] = yAxisUpLimit(Unit)
            switch lower(Unit)
                case 'dbm';                    upYLim = -20; strUnit = 'dBm';
                case {'dbµv', 'dbμv', 'dbuv'}; upYLim =  87; strUnit = 'dBµV';
                case {'dbµv/m', 'dbμv/m'};     upYLim = 100; strUnit = 'dBµV/m';
            end
        end


        %-----------------------------------------------------------------%
        function d = english2portuguese()
            names  = ["AntennaHeight", ...
                      "Azimuth", ...
                      "Band", ...
                      "BitsPerSample", ...
                      "Count", ...
                      "DataPoints", ...
                      "Description", ...
                      "Distance", ...
                      "Elevation", ...
                      "Family", ...
                      "File", ...
                      "FileVersion", ...
                      "Frequency", ...
                      "gpsType", ...
                      "Height", ...
                      "Installation", ...
                      "IntegrationFactor", ...
                      "LevelUnit", ...
                      "Location", ...
                      "LocationSource", ...
                      "Memory", ...
                      "MetaData", ...
                      "Name", ...
                      "nData", ...
                      "nSweeps", ...
                      "Observation", ...
                      "ObservationSamples", ...
                      "ObservationTime", ...
                      "ObservationType", ...
                      "Polarization", ...
                      "Position", ...
                      "Proeminence", ...
                      "Receiver", ...
                      "Resolution", ...
                      "RevisitTime", ...
                      "RFMode", ...
                      "Service", ...
                      "Sync", ...
                      "Station", ...
                      "StepWidth", ...
                      "switchPort", ...
                      "Target", ...
                      "Task", ...
                      "taskType", ...
                      "Type", ...
                      "TraceIntegration", ...
                      "TraceMode", ...
                      "TrackingMode"];
            values = ["Altura da antena", ...
                      "Azimute", ...
                      "Banda", ...
                      "Codificação", ...
                      "Qtd. amostras", ...
                      "Pontos por varredura", ...
                      "Descrição", ...
                      "Distância", ...
                      "Elevação", ...
                      "Família", ...
                      "Arquivo", ...
                      "Arquivo", ...
                      "Frequência", ...
                      "GPS", ...
                      "Altura", ...
                      "Instalação", ...
                      "Integração", ...
                      "Unidade", ...
                      "Localidade", ...
                      "Fonte", ...
                      "Memória", ...
                      "Metadados", ...
                      "Nome", ...
                      "Qtd. fluxos", ...
                      "Qtd. varreduras", ...
                      "Observação", ...
                      "Amostras a coletar", ...
                      "Observação", ...
                      "Tipo de observação", ...
                      "Polarização", ...
                      "Posição", ...
                      "Proeminência", ...
                      "Receptor", ...
                      "Resolução", ...
                      "Tempo de revisita", ...
                      "Modo RF", ...
                      "Serviço", ...
                      "Sincronismo", ...
                      "Estação", ...
                      "Passo da varredura", ...
                      "Porta da matriz", ...
                      "Alvo", ...
                      "Tarefa", ...
                      "Tipo de tarefa", ...
                      "Tipo", ...
                      "Integração", ...
                      "Traço", ...
                      "Modo de apontamento"];
        
            d = dictionary(names, values);
        end
    end
end