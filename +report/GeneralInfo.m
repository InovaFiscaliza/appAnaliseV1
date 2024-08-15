function [idx, reportInfo] = GeneralInfo(app, Mode, reportTemplateIndex)

    switch Mode
        case {'Report', 'auxApp.winTemplate'}
            idx = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            detectionMode = 'Automatic+Manual';

        case 'Preview'
            idx = unique([app.report_Tree.CheckedNodes.NodeData]);
            detectionMode = 'Automatic+Manual';

        case 'playback.AddEditOrDeleteEmission'
            idx = app.play_PlotPanel.UserData.NodeData;
            detectionMode = 'Manual';

        case {'report.AddOrDeleteThread', 'auxApp.winSignalAnalysis'}
            idx = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            detectionMode = 'Manual';
    end
    
    % Criação de variável local que suportará a criação do relatório de
    % monitoração.
    reportInfo = struct('appVersion',    app.General.AppVersion,                         ...
                        'Issue',         app.report_Issue.Value,                         ...
                        'General',       struct('Mode',        Mode,                     ...
                                                'Version',     app.report_Version.Value, ...
                                                'Image',       app.General.Image,        ...
                                                'Parameters',  app.General.Plot,         ...
                                                'RootFolder',  app.rootFolder,           ...
                                                'UserPath',    app.config_Folder_userPath.Value), ...
                        'Model',         struct('Name',        app.report_ModelName.Value,  ...
                                                'idx',         reportTemplateIndex,         ...
                                                'Type',        app.General.Models(reportTemplateIndex,:), ...
                                                'Template',    fileread(fullfile(app.rootFolder, 'Template', app.General.Models.Template{reportTemplateIndex}))), ...
                        'Attachments',   app.projectData.externalFiles,                  ...
                        'DetectionMode', detectionMode,                                  ...
                        'Filename',      '');
end