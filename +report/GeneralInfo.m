function [idx, reportInfo] = GeneralInfo(app, Mode)

    switch Mode
        case 'Report'
            idx = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
        case 'Preview'
            idx = [];
            for ii = 1:numel(app.report_Tree.CheckedNodes)
                idx = [idx, app.report_Tree.CheckedNodes(ii).NodeData];
            end
            idx = unique(idx);
    end


    % Filtro de período de observação.
    % (a) Inicialmente, verifica-se se o período é válido (data de fim
    %     superior à de início).
    % (b) Posteriormente, verifica-se se os valores inseridos (seja de
    % forma automática ou manual) efetivamente filtra alguma amostra.
    BeginFilteredTime = app.report_DatePicker1.Value + hours(app.report_Spinner1.Value) + minutes(app.report_Spinner2.Value);
    EndFilteredTime   = app.report_DatePicker2.Value + hours(app.report_Spinner3.Value) + minutes(app.report_Spinner4.Value);
    if BeginFilteredTime > EndFilteredTime
        error('Os valores inseridos para aplicação do filtro de TimeStamp devem ser ajustados!')
    end

    BeginListTime     = arrayfun(@(x) x.Data{1}(1),   app.specData(idx));
    EndListTime       = arrayfun(@(x) x.Data{1}(end), app.specData(idx));

    if any(BeginFilteredTime > BeginListTime) || ...
            any(EndFilteredTime < EndListTime)
        filterStatus = true;
    else
        filterStatus = false;
    end


    % Identificação do modelo de relatório.    
    reportTemplateIndex = find(strcmp(app.report_Type.Items, app.report_Type.Value), 1);
    

    % Criação de variável local que suportará a criação do relatório de
    % monitoração.
    reportInfo = struct('appVersion',  app.General.ver,                                 ...
                        'Issue',       app.report_Issue.Value,                          ...
                        'General',     struct('Mode',        Mode,                      ...
                                              'Version',     app.report_Version.Value,  ...
                                              'Image',       app.General.Image,         ...
                                              'RootFolder',  app.RootFolder,            ...
                                              'UserPath',    app.menu_userPath.Value),  ...
                        'Model',       struct('Name',        app.report_Type.Value,     ...
                                              'idx',         reportTemplateIndex,       ...
                                              'Type',        app.General.Models(reportTemplateIndex,:), ...
                                              'Template',    fileread(fullfile(app.RootFolder, 'Template', app.General.Models.Template{reportTemplateIndex}))), ...
                        'Attachments', app.projData,                                    ...
                        'TimeStamp',   struct('Status',      filterStatus,              ...
                                              'Observation', [BeginFilteredTime, EndFilteredTime]),...
                        'Filename',    '');
end