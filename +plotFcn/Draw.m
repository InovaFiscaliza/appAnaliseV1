function Draw(app, idx)

    newArray = app.specData(idx).Data{2}(:,app.timeIndex)';

    if isempty(app.line_ClrWrite)
        DataPoints = app.specData(idx).MetaData.DataPoints;
        FreqStart  = app.specData(idx).MetaData.FreqStart / 1e+6;
        FreqStop   = app.specData(idx).MetaData.FreqStop  / 1e+6;
        LevelUnit  = app.specData(idx).MetaData.LevelUnit;

        % Propriedades do app que poderão ser referenciadas, caso criadas
        % curvas estatísticas (MinHold | Average | MaxHold), ou caso a
        % janela de integração não seja "full".

        update(app.Band, DataPoints, FreqStart, FreqStop)
        app.General.Integration.Trace = plotFcn.TraceIntegration(app, idx);

        % Limites do app.axes1, os quais ficam armazenadas em app.restoreView 
        % para recuperação posterior. O comportamento padrão do "restoreView"
        % (existente no toolbar do eixo) não se mostrou adequado porque ao
        % ser acionado, não há troca das propriedades "XLim" e "YLim", logo
        % os controles "uispinner" não são atualizados.

        xLimits = [FreqStart, FreqStop];
        yLimits = YLimits(app, idx);
        app.restoreView = {xLimits, yLimits};

        set(app.axes1, XLim=xLimits, YLim=yLimits, YScale='linear')
        ylabel(app.axes1, sprintf('Nível (%s)', LevelUnit))

        % Curvas a plotar em app.axes1 (na sua ordem correta!).
        % Persistance >> ClearWrite >> MinHold >> Average >> MaxHold
        
        if app.play_Persistance.Value
            plotFcn.Persistance(app, idx, newArray, LevelUnit, 'Creation')
        end

        app.line_ClrWrite = plot(app.axes1, app.Band.xArray, newArray, Color=app.General.Colors(4,:), Tag='ClrWrite');
        plotFcn.DataTipModel(app.line_ClrWrite, LevelUnit)
        
        if app.play_MinHold.Value
            plotFcn.minHold(app, idx, newArray, LevelUnit)
        end

        if app.play_Average.Value
            plotFcn.Average(app, idx, newArray, LevelUnit)
        end

        if app.play_MaxHold.Value
            plotFcn.maxHold(app, idx, newArray, LevelUnit)
        end

        % Curva a plotar em app.axes2.

        if app.play_Occupancy.Value
            plotFcn.OCC(app, idx, newArray, LevelUnit)
        end

        % Curva a plotar em app.axes3.
        
        if app.play_Waterfall.Value
            plotFcn.Waterfall(app, idx, newArray, LevelUnit)
        end

    else
        app.line_ClrWrite.YData = newArray;

        if app.play_Persistance.Value && ~strcmp(app.play_Persistance_Samples.Value, 'full')
            plotFcn.Persistance(app, idx, newArray, '', 'Update')
        end

        if ~isinf(app.General.Integration.Trace)
            if ~isempty(app.line_MinHold)
                app.line_MinHold.YData = min(app.line_MinHold.YData, newArray);
            end
    
            if ~isempty(app.line_Average)
                app.line_Average.YData = ((app.General.Integration.Trace-1)*app.line_Average.YData + newArray) / app.General.Integration.Trace;
            end
    
            if ~isempty(app.line_MaxHold)
                app.line_MaxHold.YData = max(app.line_MaxHold.YData, newArray);
            end
        end
    end
    drawnow
end


%-------------------------------------------------------------------------%
function yLimits = YLimits(app, idx)
    if ismember(app.specData(idx).MetaData.DataType, class.Constants.specDataTypes)
        auxValue = min(app.specData(idx).Data{3}(:,1));
        downYLim = auxValue - mod(auxValue, 10);
    
        auxValue = max(app.specData(idx).Data{3}(:,3));
        upYLim   = auxValue - mod(auxValue, 10) + 10;
    else
        downYLim = 0;
        upYLim   = 100;
    end
    yLimits = [downYLim, upYLim];

    if diff(yLimits) > class.Constants.yMaxLimRange
        yLimits(1) = yLimits(1) + diff(yLimits) - class.Constants.yMaxLimRange;
    end
end