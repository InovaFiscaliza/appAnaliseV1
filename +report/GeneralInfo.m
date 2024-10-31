function [idx, reportInfo] = GeneralInfo(app, Mode, reportTemplateIndex)
    switch Mode
        case 'Report'
            idx = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            detectionMode = 'Automatic+Manual';

        case 'Preview'
            idx = unique([app.report_Tree.CheckedNodes.NodeData]);
            detectionMode = 'Automatic+Manual';

        case 'playback.AddEditOrDeleteEmission'
            idx = app.play_PlotPanel.UserData.NodeData;
            detectionMode = 'Manual';

        case {'report.AddOrDeleteThread', 'signalAnalysis.EditOrDeleteEmission', 'signalAnalysis.externalJSON'}
            idx = find(arrayfun(@(x) x.UserData.reportFlag, app.specData));
            detectionMode = 'Manual';
    end
    
    % Criação de variável local que suportará a criação do relatório de
    % monitoração.
    versionInfo = struct('machine',    reportLib.Constants.MachineVersion(), ...
                         'matlab',     reportLib.Constants.MatlabVersion(),  ...
                         'reportLib',  reportLib.Constants.ReportLib(),      ...
                         'appAnalise', struct('name',       class.Constants.appName,    ...
                                              'release',    class.Constants.appRelease, ...
                                              'version',    class.Constants.appVersion, ...
                                              'rootFolder', app.rootFolder), ...
                         'RFDataHub',  struct('name',       'RFDataHub', ...
                                              'release',    app.General.AppVersion.RFDataHub.ReleaseDate));

    reportInfo = struct('Version',       versionInfo,                                    ...
                        'Issue',         app.report_Issue.Value,                         ...
                        'General',       struct('Mode',        Mode,                     ...
                                                'Image',       app.General.Image,        ...
                                                'Parameters',  app.General.Plot,         ...
                                                'RootFolder',  app.rootFolder,           ...
                                                'UserPath',    app.General.fileFolder.userPath), ...
                        'ExternalFiles', app.projectData.externalFiles,                  ...
                        'DetectionMode', detectionMode,                                  ...
                        'Filename',      '');

    if reportTemplateIndex >= 1
        reportInfo.Model = struct('Name',    app.report_ModelName.Value,                ...
                                  'idx',     reportTemplateIndex,                       ...
                                  'Type',    app.General.Models(reportTemplateIndex,:), ...
                                  'Version', app.report_Version.Value,                  ...
                                  'Script',  fileread(fullfile(app.rootFolder, 'Template', app.General.Models.Template{reportTemplateIndex})));
    end
end