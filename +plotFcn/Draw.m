function Draw(app, idx)

    % No processo de inicialização do PLOT, que ocorre toda vez que é
    % alterado o fluxo espectral selecionado, na árvore principal do
    % appAnalise, os eixos são limpos e os handles dos principais
    % componentes do plot são apagados.

    % app.hClearWrite vazio significa que deverá ser desenhado um novo PLOT. 
    % Por outro lado, caso não seja vazio, então o PLOT deverá ser atualizado.

    if isempty(app.hClearWrite)
        % O objeto app.bandObj armazena valores que simplificam os plots de curvas
        % estatísticas, como MinHold, Average e MaxHold, por exemplo, além
        % de aferir os limites XY dos eixos.
        axesLimits = update(app.bandObj, idx);

        % Abaixo é inicializado o restoreView, variável que viabiliza o retorne
        % aos limites dos eixos a partir de clique em botão do Toolbar. Importante 
        % observar, contudo, que os valores de "cLim" serão atualizados após o 
        % plot das curvas dos tipos "Persistance" (em app.UIAxes1) e "Waterfall"
        % (em app.UIAxes3).
        app.restoreView(1) = struct('ID', 'app.UIAxes1', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yLevelLim, 'cLim', app.UIAxes1.CLim);
        app.restoreView(2) = struct('ID', 'app.UIAxes2', 'xLim', axesLimits.xLim, 'yLim', [0, 100],             'cLim', app.UIAxes2.CLim);
        app.restoreView(3) = struct('ID', 'app.UIAxes3', 'xLim', axesLimits.xLim, 'yLim', axesLimits.yTimeLim,  'cLim', app.UIAxes3.CLim);

        set(app.UIAxes1, 'XLim', axesLimits.xLim, 'YLim', axesLimits.yLevelLim, 'YScale', 'linear')
        ylabel(app.UIAxes1, sprintf('Nível (%s)', app.bandObj.LevelUnit))

        % customPlayback
        customPlayback = app.specData(idx).UserData.customPlayback.Parameters;

        % UIAXES1
        for plotTag = ["ClearWrite", "MinHold", "Average", "MaxHold"]
            yArray = YArray(app.bandObj, idx, plotTag, app.timeIndex);
            
            if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'}) && ~eval(sprintf('app.tool_%s.Value', plotTag))
                continue
            end

            eval(sprintf('app.h%s = plot.draw2D.OrdinaryPlot(app.UIAxes1, app.bandObj.xArray, yArray, app.General, customPlayback, "%s");', plotTag, plotTag))
            plot.datatip.Template(eval(sprintf('app.h%s', plotTag)), "Frequency+Level", app.bandObj.LevelUnit)
        end
        
        if plot_ConfigPersistance(app)
            app.hPersistanceObj = plot.draw3D.Persistance(app.hPersistanceObj, app.UIAxes1, app.specData(idx), app.bandObj, app.General, customPlayback, 'Persistance', 'Creation');
        end
        
        plot.BandLimits(app, idx)

        % UIAXES1 + UIAXES2 (OCC)
        if app.tool_Occupancy.Value
            occIndex = play_OCCIndex(app, idx, 'PLAYBACK');
            plot.OCC(app, idx, 'Creation', occIndex)
        end

        % UIAXES3
        if app.tool_Waterfall.Value
            plot.draw3D.WaterFall(app, idx, 'Creation', LevelUnit)
        end

        % postPLOT
        % (a) StackingOrder
        plot.axes.StackingOrder.execute(app.UIAxes1, 'winAppAnalise:PLAYBACK')

        % (b) customPlayback
        if ~isempty(customPlayback)
            dtConfig = app.specData(idx).UserData.customPlayback.Parameters.Datatip;
            dtParent = [app.UIAxes1, app.UIAxes2, app.UIAxes3];
            plot.datatip.Create('customPlayback', dtConfig, dtParent)

            plot.axes.Colormap(app.UIAxes1, app.play_Persistance_Colormap.Value)
            plot.axes.Colormap(app.UIAxes3, app.play_Waterfall_Colormap.Value)
        end

    else
        yArray = app.specData(idx).Data{2}(:,app.timeIndex)';
        integrationFactor = app.General.Integration.Trace;

        for plotTag = ["ClearWrite", "MinHold", "Average", "MaxHold"]
            if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'})
                if ~eval(sprintf('app.tool_%s.Value', plotTag)) || isinf(integrationFactor)
                    continue
                end
            end

            eval(sprintf('plot.draw2D.OrdinatyPlotUpdate(app.h%s, yArray, plotTag, integrationFactor);', plotTag))
        end

        for ii = 1:numel(app.hEmissionMarkers)
            app.hEmissionMarkers(ii).Position(2) = app.hClearWrite.YData(app.hClearWrite.MarkerIndices(ii));
        end

        if app.tool_Persistance.Value && ~strcmp(app.play_Persistance_Samples.Value, 'full')
            plotFcn.Persistance(app, idx, 'Update')
        end

        if app.tool_Waterfall.Value && ~isempty(app.hWaterFallTime) && strcmp(app.play_Waterfall_Timestamp.Value, 'on')
            app.hWaterFallTime.YData = [app.specData(idx).Data{1}(app.timeIndex), app.specData(idx).Data{1}(app.timeIndex)];
        end
    end
    drawnow
end