function [status, customPlayback] = checkCustomPlaybackFieldNames(specData, generalSettings)
    % Avalia se a propriedade "customPlayback" está no modo "manual", ajustando 
    % os nomes dos campos, o que pode ser necessário, caso o .MAT tenha sido 
    % salvo até a versão 1.67. A partir da v. 1.80, o appAnalise começou a 
    % trabalhar com os nomes dos campos compactos. "MinHold" ao invés de 
    % "play_MinHold", por exemplo.

    status = false;
    customPlayback = specData.UserData.customPlayback;

    if specData.UserData.customPlayback.Type == "manual"
        fieldClassNames = fieldnames(specData.UserData.customPlayback.Parameters);
        newClassNames   = {'Controls', 'Persistance', 'Waterfall', 'WaterfallTime', 'Datatip'};

        if any(~ismember(newClassNames, fieldClassNames))
            status = true;

            oldFieldNames = ["play_MinHold", ...
                             "play_Average", ...
                             "play_MaxHold", ...
                             "play_Persistance", ...
                             "play_Occupancy", ...
                             "play_Waterfall", ...
                             "play_LayoutRatio", ...
                             "play_Persistance_Interpolation", ...
                             "play_Persistance_Samples", ...
                             "play_Persistance_Transparency", ...
                             "play_Waterfall_Decimation"];

            newFieldNames = ["MinHold",       ...
                             "Average",       ...
                             "MaxHold",       ...
                             "Persistance",   ...
                             "Occupancy",     ...
                             "Waterfall",     ...
                             "LayoutRatio",   ...
                             "Interpolation", ...
                             "WindowSize",    ...
                             "Transparency",  ...
                             "Decimation"];

            nameMapping    = dictionary(oldFieldNames, newFieldNames);

            oldControls    = structUtil.renameFieldNames(customPlayback.Parameters.Controls,    nameMapping);
            oldPersistance = structUtil.renameFieldNames(customPlayback.Parameters.Persistance, nameMapping);
            oldWaterfall   = structUtil.renameFieldNames(customPlayback.Parameters.Waterfall,   nameMapping);

            newControls    = oldControls;
            newControls.FrequencyLimits = [0,0];
            newControls.LevelLimits     = [0,0];

            newPersistance = structUtil.addingFields(oldPersistance, generalSettings.Plot.Persistance);
            newWaterfall   = structUtil.addingFields(oldWaterfall,   generalSettings.Plot.Waterfall);

            customPlayback.Parameters.Controls      = newControls;
            customPlayback.Parameters.Persistance   = newPersistance;
            customPlayback.Parameters.Waterfall     = newWaterfall;
            customPlayback.Parameters.WaterfallTime = generalSettings.Plot.WaterfallTime;
        end
    end
end