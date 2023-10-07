function OCC(app, LevelUnit)

    hComponents = findobj(app.play_OCCGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigrid', '-or', 'Type', 'uipanel'});

    if app.play_Occupancy.Value
        set(hComponents, Enable=1)

        switch app.play_OCC_Method.Value
            case 'Linear fixo'
                set(app.play_OCC_THRLabel,        Visible=1)
                set(app.play_OCC_THR,             Visible=1)

                set(app.play_OCC_OffsetLabel,     Visible=0)
                set(app.play_OCC_Offset,          Visible=0, Enable=0)
                
                set(app.play_OCC_ceilFactorLabel, Visible=0)
                set(app.play_OCC_ceilFactor,      Visible=0, Enable=0)

                set(app.play_OCC_noiseLabel,      Visible=0)
                set(app.play_OCC_noisePanel,      Visible=0)
                set(findobj(app.play_OCC_noiseGrid.Children, '-not', 'Type', 'uilabel'), Enable=0)

                app.play_OCC_THRLabel.Text = sprintf('Valor (%s):', LevelUnit);
                switch LevelUnit
                    case 'dBm'
                        if app.play_OCC_THR.Value > 0                            
                            app.play_OCC_THR.Value = -80;
                        end        
                    case 'dBµV'
                        if app.play_OCC_THR.Value < 0
                            app.play_OCC_THR.Value = 27;
                        end        
                    case 'dBµV/m'
                        if app.play_OCC_THR.Value < 0
                            app.play_OCC_THR.Value = 40;
                        end
                end

            otherwise                                                       % {'Linear adaptativo', 'Envoltória do ruído adaptativo'}
                set(app.play_OCC_THRLabel,    Visible=0)
                set(app.play_OCC_THR,         Visible=0, Enable=0)
                
                set(app.play_OCC_OffsetLabel, Visible=1)
                set(app.play_OCC_Offset,      Visible=1)

                set(app.play_OCC_noiseLabel,  Visible=1)
                set(app.play_OCC_noisePanel,  Visible=1)

                switch app.play_OCC_Method.Value
                    case'Linear adaptativo'
                        set(app.play_OCC_ceilFactorLabel, Visible=0)
                        set(app.play_OCC_ceilFactor,     Visible=0, Enable=0)

                    case 'Envoltória do ruído'
                        set(app.play_OCC_ceilFactorLabel, Visible=1)
                        set(app.play_OCC_ceilFactor,      Visible=1)
                end
        end

    else
        set(hComponents, Enable=0)
    end
end