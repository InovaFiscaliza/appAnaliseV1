function Controller(app, Mode)

    d = uiprogressdlg(app.UIFigure, 'Indeterminate', 'on', 'Interpreter', 'html'); 
    d.Message = '<font style="font-size:12;">Em andamento a análise dos fluxos de dados selecionados, o que inclui diversas manipulações, como, por exemplo, a busca de emissões e a comparação com a base de dados da Agência...</font>';
        
    try
        [idx, reportInfo] = ReportGenerator_Aux1(app, Mode);
        
        switch Mode
            case 'Report'
                % Verifica se o template e relatório selecionado demanda
                % arquivos externos (imagens e tabelas).
                if contains(reportInfo.Model.Template, '"Origin": "External"')
                    msg = '<font style="font-size:12;">Confirma que foram relacionados os arquivos externos ao appAnalise estabelecidos no modelo?</font>';
                    selection = uiconfirm(app.UIFigure, msg, '', 'Options', {'OK', 'Cancelar'}, 'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question', 'Interpreter', 'html');
                    
                    if selection == "Cancelar"
                        return
                    end
                end

                % Verifica...
                [htmlReport, Peaks] = report.ReportGenerator(app, idx, reportInfo);
                report.ReportGenerator_PeaksUpdate(app, idx, Peaks)

                switch app.report_Version.Value
                    case 'Definitiva'
                        filename = fullfile(app.menu_userPath.Value, sprintf( 'Report_%s_%.0f.html', datestr(now, 'yyyy.mm.dd_THH.MM.SS'), app.report_Issue.Value));
                        fileID   = fopen(filename, 'w', 'native', 'ISO-8859-1');

                    case 'Preliminar'
                        filename = fullfile(app.menu_userPath.Value, sprintf('~Report_%s_%.0f.html', datestr(now, 'yyyy.mm.dd_THH.MM.SS'), app.report_Issue.Value));
                        fileID   = fopen(filename, 'w');
                end
                
                fprintf(fileID, '%s', htmlReport);
                fclose(fileID);
    
                if strcmp(app.report_Version.Value, 'Definitiva')
                    app.General.Report = filename;
                    
                    [ReportProject, tableStr] = ReportGenerator_Aux2(app, idx, reportInfo);
                    save(replace(filename, '.html', '.mat'), 'ReportProject', '-mat', '-v7.3')
                    writematrix(tableStr, replace(filename, '.html', '.json'), "FileType", "text", "QuoteStrings", "none")
                end
                web(filename, '-new')


            case 'Preview'
                Peaks = report.PreviewGenerator(app, idx, reportInfo);
                report.ReportGenerator_PeaksUpdate(app, idx, Peaks)


            case 'auxApp.SignalAnalysis'
                [~, countTable] = report.ReportGenerator_Table_Summary(app.CallingApp.peaksTable, app.CallingApp.exceptionList);
                tableStr = ReportGenerator_Aux3(app.CallingApp, idx, countTable);
    
                filename = fullfile(app.CallingApp.menu_userPath.Value, sprintf('preReport_%s.json', datestr(now, 'yyyymmdd_THHMMSS')));
                writematrix(tableStr, filename, "FileType", "text", "QuoteStrings", "none")
                layoutFcn.modalWindow(app.UIFigure, 'ccTools.MessageBox', sprintf('Informações relacionadas às emissões foram salvas no arquivo <b>%s</b>', replace(filename, '\', '\\')));
        end
        
    catch ME
        fprintf('%s\n', jsonencode(ME))
        layoutFcn.modalWindow(app.UIFigure, 'ccTools.MessageBox', getReport(ME));
    end

    delete(d)
end


%-------------------------------------------------------------------------%
function [idx, reportInfo] = ReportGenerator_Aux1(app, Mode)
    switch Mode
        case {'Report', 'Preview'}
            if isempty(app.General.ver.fiscaliza)
                app.General.ver = fcn.startup_Versions("Full", app.RootFolder);
            end
        
            [idx, reportInfo] = report.GeneralInfo(app, Mode);

        case 'auxApp.SignalAnalysis'    
            [idx, reportInfo] = report.GeneralInfo(app.CallingApp, Mode);
    end
end


%-------------------------------------------------------------------------%
function [ReportProject, tableStr] = ReportGenerator_Aux2(app, idx, reportInfo)

    % Variável que possibilitará o preenchimento dos campos
    % estruturados da inspeção (no Fiscaliza).
    ReportProject = struct('Issue',           app.report_Issue.Value,       ...
                           'Latitude',        [], 'Longitude',          [], ...
                           'City',            [], 'Bands',              [], ...
                           'F0',              [], 'F1',                 [], ...
                           'emissionsValue1',  0, 'emissionsValue2',     0, 'emissionsValue3',     0, ...
                           'Services',        [], 'tableJournal',       []);

    % Preenchimento dos dados...            
    ReportProject.Services = app.General.Models.RelatedServices{reportInfo.Model.idx};
    
    % Definir FreqStart, FreqStop, Latitude, Longitude e City que
    % irão compor inspeção no Fiscaliza.
    ReportProject.Bands = {};
    for ii = 1:numel(idx)
        if ismember(app.specData(ii).MetaData.DataType, class.Constants.specDataTypes)
            ReportProject.Bands(end+1) = {sprintf('%.3f - %.3f MHz', app.specData(ii).MetaData.FreqStart / 1e+6, ...
                                                                     app.specData(ii).MetaData.FreqStop  / 1e+6)};
            
            if isempty(ReportProject.Latitude)
                ReportProject.Latitude  = app.specData(idx(ii)).GPS.Latitude;
                ReportProject.Longitude = app.specData(idx(ii)).GPS.Longitude;
                ReportProject.City      = {app.specData(idx(ii)).GPS.Location};
                
                ReportProject.F0 = app.specData(idx(ii)).MetaData.FreqStart;
                ReportProject.F1 = app.specData(idx(ii)).MetaData.FreqStop;
            
            else
                if ~ismember(app.specData(idx(ii)).GPS.Location, ReportProject.City)
                    ReportProject.City{end+1,1} = app.specData(idx(ii)).gps.Location;
                end                        
                
                ReportProject.F0 = min(ReportProject.F0, app.specData(idx(ii)).MetaData.FreqStart);
                ReportProject.F1 = max(ReportProject.F1, app.specData(idx(ii)).MetaData.FreqStop);
            end
        end
    end
    
    % Juntar numa mesma variável a informação gerada pelo algoritmo
    % embarcado no appAnálise (app.peaksTable) com a informação
    % gerada pelo fiscal (app.exceptionList).
    [infoTable, countTable] = report.ReportGenerator_Table_Summary(app.peaksTable, app.exceptionList);

    ReportProject.emissionsValue1 = sum(infoTable{:,2:4}, 'all');                               % Qtd. emissões
    ReportProject.emissionsValue2 = sum(infoTable{:,2});                                        % Qtd. emissões licenciadas
    ReportProject.emissionsValue3 = sum(infoTable{:,5:8}, 'all');                               % Qtd. emissões identificadas

    ReportProject.tableJournal = infoTable(:,cell2mat(reportInfo.Model.Type.JournalTable));

    % Arquivo JSON
    tableStr = ReportGenerator_Aux3(app, idx, countTable);
end


%-------------------------------------------------------------------------%
function tableStr = ReportGenerator_Aux3(app, idx, countTable)
    
    % Tabelas que irão compor o JSON que será carregado como anexo
    % à inspeção (no Fiscaliza).
    TaskTable   = table('Size', [0, 12],                                                                                                                 ...
                        'VariableTypes', {'uint16', 'cell', 'single', 'single', 'double', 'double', 'cell', 'cell', 'uint32', 'double', 'cell', 'cell'}, ...
                        'VariableNames', {'PK1', 'Node', 'Latitude', 'Longitude', 'FreqStart', 'FreqStop', 'BeginTime', 'EndTime', 'Samples', 'timeOCC', 'Description', 'RelatedFiles'});

    occMethodTable      = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK2', 'occMethod'});
    DetectionTable      = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK3', 'Detection'});
    ClassificationTable = table('Size', [0, 2], 'VariableTypes', {'uint16', 'cell'}, 'VariableNames', {'PK4', 'Classification'});
    
    PeakTable           = countTable(:,5:21);
    PeakTable.Frequency = round(PeakTable.Frequency, 3);
    PeakTable.BW        = round(PeakTable.BW, 3);

    occMethod = unique(countTable.occMethod);
    occMethodTable(1:numel(occMethod),:) = [num2cell((1:numel(occMethod))'), occMethod];
    
    Detection = unique(countTable.Detection);
    DetectionTable(1:numel(Detection),:) = [num2cell((1:numel(Detection))'), Detection];
    
    Classification = unique(countTable.Classification);
    ClassificationTable(1:numel(Classification),:) = [num2cell((1:numel(Classification))'), Classification];

    jj = 0;
    for ii = idx
        if ismember(app.specData(ii).MetaData.DataType, class.Constants.specDataTypes)
            jj = jj+1;

            occInfo = app.specData(ii).UserData.reportOCC;
            if isfield(occInfo, 'IntegrationTime')
                IntegrationTime = occInfo.IntegrationTime;
            else
                IntegrationTime = occInfo.IntegrationTimeCaptured;
            end
            
            TaskTable(end+1,:) = {jj,                                  ...
                                  app.specData(ii).Receiver,           ...
                                  app.specData(ii).GPS.Latitude,       ...
                                  app.specData(ii).GPS.Longitude,      ...
                                  app.specData(ii).MetaData.FreqStart / 1e+6, ...
                                  app.specData(ii).MetaData.FreqStop  / 1e+6, ...
                                  datestr(app.specData(ii).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), ...
                                  datestr(app.specData(ii).Data{1}(end), 'dd/mm/yyyy HH:MM:SS'), ...
                                  numel(app.specData(ii).Data{1}),      ...
                                  IntegrationTime,                      ...
                                  app.specData(ii).RelatedFiles.Description{1}, ...
                                  strjoin(app.specData(ii).RelatedFiles.File, ', ')};
            
            Tag = sprintf('%s\nID %d: %.3f - %.3f MHz', app.specData(ii).Receiver,                  ...
                                                        app.specData(ii).RelatedFiles.ID(1),        ...
                                                        app.specData(ii).MetaData.FreqStart / 1e+6, ...
                                                        app.specData(ii).MetaData.FreqStop  / 1e+6);
            
            idx1 = find(strcmp(app.peaksTable.Tag, Tag));
            if ~isempty(idx1)
                PeakTable.FK1(idx1) = uint16(jj);
            end
        end
    end

    % occMethod, detection and classification tables
    for ii = 1:numel(occMethod)
        idx_OCC = find(strcmp(app.peaksTable.occMethod, occMethod(ii)));

        if ~isempty(idx_OCC); PeakTable.FK2(idx_OCC) = uint16(ii);
        end                
    end

    for ii = 1:numel(Detection)
        idx_Det = find(strcmp(app.peaksTable.Detection, Detection(ii)));

        if ~isempty(idx_Det); PeakTable.FK3(idx_Det) = uint16(ii);
        end
    end

    for ii = 1:numel(Classification)
        idx_Cla = find(strcmp(app.peaksTable.Classification, Classification(ii)));

        if ~isempty(idx_Cla); PeakTable.FK4(idx_Cla) = uint16(ii);
        end
    end

    if ~isempty(PeakTable)
        PeakTable = movevars(PeakTable, {'FK1', 'FK2', 'FK3', 'FK4'}, 'Before', 1);
        tableStr  = jsonencode(struct('ReferenceData1', TaskTable, 'ReferenceData2', occMethodTable, 'ReferenceData3', DetectionTable, 'ReferenceData4', ClassificationTable, 'MeasurementData', PeakTable(:,1:end-1)), 'PrettyPrint', true);
    else
        tableStr  = jsonencode(struct('ReferenceData1', TaskTable), 'PrettyPrint', true);
    end            
end