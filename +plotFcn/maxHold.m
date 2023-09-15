function maxHold(app, idx, newArray, LevelUnit)
    
    switch app.play_TraceIntegration.Value
        case 'Inf'
            app.line_MaxHold = plot(app.axes1, app.xArray, app.specData(idx).Data{3}(:,3), Color=app.General.Colors(3,:), Tag='MaxHold');
        otherwise
            app.line_MaxHold = plot(app.axes1, app.xArray, newArray, Color=app.General.Colors(3,:), Tag='MaxHold');
    end

    plotFcn.DataTipModel(app.line_MaxHold, LevelUnit)
end