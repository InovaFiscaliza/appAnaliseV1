classdef Band < handle

    properties
        %-----------------------------------------------------------------%
        Context

        DataPoints
        FreqStart   % in MHz
        FreqStop    % in MHz
        LevelUnit

        xArray      % in MHz

%       xFreq = aCoef * xIndex + bCoef
        aCoef
        bCoef
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        callingApp
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Band(Context, callingApp)
            obj.Context    = Context;
            obj.callingApp = callingApp;
        end


        %-----------------------------------------------------------------%
        function axesLimits = update(obj, idx)
            specData       = obj.callingApp.specData(idx);

            obj.DataPoints = specData.MetaData.DataPoints;
            obj.FreqStart  = specData.MetaData.FreqStart / 1e+6;
            obj.FreqStop   = specData.MetaData.FreqStop  / 1e+6;

            DataType       = specData.MetaData.DataType;
            if ismember(DataType, class.Constants.specDataTypes)
                obj.LevelUnit = specData.MetaData.LevelUnit;

            elseif ismember(DataType, class.Constants.occDataTypes)
                obj.LevelUnit = '%';

            else
                error('Band:update:UnexpectedDataType', 'UnexpectedDataType')                
            end

            obj.xArray     = round(linspace(obj.FreqStart, obj.FreqStop, obj.DataPoints), class.Constants.xDecimals);

            obj.aCoef      = (obj.FreqStop - obj.FreqStart)*1e+6 ./ (obj.DataPoints - 1);
            obj.bCoef      = obj.FreqStart*1e+6 - obj.aCoef;       

            axesLimits     = Limits(obj, idx);
        end


        %-----------------------------------------------------------------%
        function axesLimits = Limits(obj, idx)
            switch obj.Context
                case 'appAnalise:PLAYBACK'
                  % axesLimits = struct('xLim', {}, 'yLevelLim', {}, 'yTimeLim', {})
                    axesLimits = playbackLimits(obj, idx);

                case 'appAnalise:REPORT'
                    axesLimits = reportLimits(obj, idx);
            end
        end


        %-----------------------------------------------------------------%
        function yArray = YArray(obj, idx, plotTag, varargin)
            arguments
                obj
                idx
                plotTag {mustBeMember(plotTag, {'ClearWrite', 'MinHold', 'Average', 'MaxHold'})}
            end

            arguments (Repeating)
                varargin
            end

            yArray   = [];
            specData = obj.callingApp.specData(idx);

            switch plotTag
                case 'MinHold'; idxFcn = 1;
                case 'Average'; idxFcn = 2;
                case 'MaxHold'; idxFcn = 3;
            end

            switch obj.Context
                case 'appAnalise:PLAYBACK'
                    if ismember(plotTag, {'MinHold', 'Average', 'MaxHold'}) && isinf(str2double(obj.callingApp.play_TraceIntegration.Value))
                        yArray  = specData.Data{3}(:,idxFcn)';

                    else
                        idxTime = varargin{1};
                        yArray  = specData.Data{2}(:,idxTime)';
                    end

                case 'appAnalise:REPORT'
                    yArray = specData.Data{3}(:,idxFcn)';
            end
        end

        %-----------------------------------------------------------------%
        function FrequencyInHertz = idx2freq(obj, idx)
            FrequencyInHertz = obj.aCoef * idx + obj.bCoef;
        end

        %-----------------------------------------------------------------%
        function [idx, invalidIndex] = freq2idx(obj, FrequencyInHertz, validationType)
            arguments
                obj
                FrequencyInHertz
                validationType {mustBeMember(validationType, {'CheckAndRound', 'OnlyCheck'})} = 'CheckAndRound'
            end

            idx = round((FrequencyInHertz - obj.bCoef) / obj.aCoef);
            invalidIndex = (idx < 1) || (idx > obj.DataPoints);

            if validationType == "CheckAndRound"
                idx(idx < 1) = 1;
                idx(idx > obj.DataPoints) = obj.DataPoints;
            end
        end
    end

    methods(Access = private)
        %-----------------------------------------------------------------%
        function axesLimits = playbackLimits(obj, idx)
            axesLimits = [];
            specData   = obj.callingApp.specData(idx);
        
            % Inicialmente, avalia se o objeto possui a propriedade "customPlayback" 
            % configurada para "manual". Lembrando que o controle desses atributos
            % é recente, então um .MAT antigo pode registrar controle "manual", mas
            % não possuir esses atributos. Dessa forma, axesLimits retornará vazia.

            if specData.UserData.customPlayback.Type == "manual"
                axesLimits = playback.customPlayback('updateXYLimits', specData);
            end
        
            if isempty(axesLimits)
                % xLimits
                xLimits    = [obj.FreqStart, obj.FreqStop];
            
                % yLevelLimits
                DataType     = specData.MetaData.DataType;
                if ismember(DataType, class.Constants.specDataTypes)
                    auxValue = min(specData.Data{3}(:,1));
                    downYLim = auxValue - mod(auxValue, 10);
                
                    auxValue = max(specData.Data{3}(:,3));
                    upYLim   = auxValue - mod(auxValue, 10) + 10;

                elseif ismember(DataType, class.Constants.occDataTypes)
                    downYLim = 0;
                    upYLim   = 100;

                else
                    error('Band:Limits:UnexpectedDataType', 'UnexpectedDataType')
                end
                yLevelLimits = [downYLim, upYLim];
            
                if diff(yLevelLimits) > class.Constants.yMaxLimRange
                    yLevelLimits(1) = yLevelLimits(1) + diff(yLevelLimits) - class.Constants.yMaxLimRange;
                end
        
                axesLimits.xLim = xLimits;
                axesLimits.yLevelLim = yLevelLimits;
            end
        
            % yTimeLimits
            axesLimits.yTimeLim = [specData.Data{1}(1), specData.Data{1}(end)];
            if specData.Data{1}(1) == specData.Data{1}(end)
                axesLimits.yTimeLim(2) = axesLimits.yTimeLim(2) + seconds(1);
            end
        end

        %-----------------------------------------------------------------%
        function axesLimits = reportLimits(obj, specData, Parameters, yUnit)
            axesLimits     = [];
            specData       = obj.callingApp.specData(idx);

            switch Parameters.Plot.Type
                case 'Band'
                    FreqStartView = FreqStart;
                    FreqStopView  = FreqStop;
                    xIndexLim     = [1, DataPoints];

                case 'Emission'
                    emissionIndex = Parameters.Plot.emissionIndex;
                    if emissionIndex == -1
                        error('Unexpected value.')
                    end
    
                    emissionBW    = SpecInfo.UserData.Emissions.BW(emissionIndex)/1000;
                    xGuardBand    = Parameters.Axes.xGuardBandFactor * emissionBW;
    
                    FreqStartView = SpecInfo.UserData.Emissions.Frequency(emissionIndex) - (emissionBW + xGuardBand)/2;
                    FreqStopView  = SpecInfo.UserData.Emissions.Frequency(emissionIndex) + (emissionBW + xGuardBand)/2;
                    xIndexLim     = [plotFcn.axesDraw.freq2idx(SpecInfo, FreqStartView*1e+6, 'fix'), plotFcn.axesDraw.freq2idx(SpecInfo, FreqStopView*1e+6, 'ceil')];

                    xArray        = xArray(xIndexLim(1):xIndexLim(2));
            end

            xLim = [FreqStartView, FreqStopView];

            switch yUnit
                case {'ordinary level', 'persistance level'}
                    yLim = plotFcn.axesDraw.yzLimits(SpecInfo, yUnit, xIndexLim);
                    zLim = [-1, 1];
                case 'occupancy level'
                    yLim = [0, 100];
                    zLim = [-1, 1];
                case 'time'
                    yLim = [SpecInfo.Data{1}(1), SpecInfo.Data{1}(end)];
                    zLim = plotFcn.axesDraw.yzLimits(SpecInfo, yUnit, xIndexLim);
                case 'timeIndex'
                    yLim = [1, numel(SpecInfo.Data{1})];
                    zLim = [-1, 1];
            end
        end


        function yzLim = yzLimits(SpecInfo, yUnit, xIndexLim)
            yzLim  = [min(SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),1)), max(SpecInfo.Data{3}(xIndexLim(1):xIndexLim(2),end))];

            if ismember(yUnit, {'persistance level', 'time'})
                yzAmplitude = class.Constants.yMaxLimRange;

                yzLim(2)    = max(yzLim(1)+yzAmplitude, yzLim(2));
                yzLim(1)    = yzLim(2)-yzAmplitude;
            end
        end
    end
end