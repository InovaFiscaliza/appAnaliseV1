classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'appAnalise'
        appRelease    = 'R2023a'
        appVersion    = '1.41'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]

        gps2locAPI    = 'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=<Latitude>&longitude=<Longitude>&localityLanguage=pt'
        gps2loc_City  = 'city'
        gps2loc_Unit  = 'principalSubdivisionCode'

        userPaths     = {fullfile(getenv('USERPROFILE'), 'Documents'); fullfile(getenv('USERPROFILE'), 'Downloads')}
        Interactions  = {'datacursor', 'zoomin', 'restoreview'}

        yMinLimRange  = 80                                                  % Minimum y-Axis limit range
        yMaxLimRange  = 100                                                 % Maximum y-Axis limit range

        specDataTypes = [1, 2, 4, 7, 60, 61, 63, 64, 67, 68, 167, 168, 1000, 1809];
        occDataTypes  = [8, 62, 65, 69];

        xDecimals     = 5

        nMaxWaterFallPoints = 1474560
    end

    
    methods (Static = true)
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
            names  = ["Azimuth", ...
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
                      "Sync", ...
                      "StepWidth", ...
                      "switchPort", ...
                      "Target", ...
                      "Task", ...
                      "taskType", ...
                      "Type", ...
                      "TraceIntegration", ...
                      "TraceMode", ...
                      "TrackingMode"];
            values = ["Azimute", ...
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
                      "Sincronismo", ...
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