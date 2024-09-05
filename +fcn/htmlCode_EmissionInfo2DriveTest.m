function [htmlContent, emissionID] = htmlCode_EmissionInfo2DriveTest(specData, idx, idxEmission)

    emissionTag     = sprintf('%.3f MHz ⌂ %.1f kHz', specData(idx).UserData.Emissions.Frequency(idxEmission), specData(idx).UserData.Emissions.BW(idxEmission));
    emissionFullTag = sprintf('%s\n%.3f - %.3f MHz @ %s', specData(idx).Receiver, specData(idx).MetaData.FreqStart/1e+6, specData(idx).MetaData.FreqStop/1e+6, emissionTag);

    dataStruct(1)   = struct('group', 'RECEPÇÃO',   'value', struct('Receiver', specData(idx).Receiver, ...
                                                                    'ObservationTime', sprintf('%s - %s', datestr(specData(idx).Data{1}(1),   'dd/mm/yyyy HH:MM:SS'), datestr(specData(idx).Data{1}(end), 'dd/mm/yyyy HH:MM:SS'))));

    dataStruct(2)   = struct('group', 'METADADOS',  'value', specData(idx).MetaData);

    dataStruct(3)   = struct('group', 'ARQUIVO(S)', 'value', table2struct(specData(idx).RelatedFiles));
    

    htmlContent     = [sprintf('<p style="font-family: Helvetica, Arial, sans-serif; font-size: 16px; text-align: justify; line-height: 12px; margin: 5px; padding-top: 5px; padding-bottom: 10px;"><b>%s</b></p>', emissionTag) ...
                       textFormatGUI.struct2PrettyPrintList(dataStruct(1:2), 'delete'), ...
                       '<p style="font-family: Helvetica, Arial, sans-serif; color: gray; font-size: 10px; text-align: justify; line-height: 12px; margin: 5px; padding-bottom: 10px;">&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;&thinsp;____________________<br>&thinsp;̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ <br>A seguir são apresentadas informações detalhadas por arquivo.</p>' ...
                       textFormatGUI.struct2PrettyPrintList(dataStruct(3))];

    emissionID      = struct('Thread',   struct('Index',     idx,                                                     ...
                                                'UUID',      {specData(idx).RelatedFiles.uuid}),                      ...
                             'Emission', struct('Index',     idxEmission,                                             ...
                                                'Frequency', specData(idx).UserData.Emissions.Frequency(idxEmission), ...
                                                'BW',        specData(idx).UserData.Emissions.BW(idxEmission),        ...
                                                'Tag',       emissionFullTag));
end