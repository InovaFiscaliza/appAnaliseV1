function report_ResetGUI(app)

    if ~isempty(app.fiscalizaObj)
        GridInitialization(app.fiscalizaObj, false)
        app.fiscalizaObj.issueID = [];
    end
    set(app.report_FiscalizaIcon, 'Parent', app.report_FiscalizaGrid, 'Visible', 1)

    app.report_FiscalizaAutoFillImage.Enable = 0;
    app.report_FiscalizaUpdateImage.Enable   = 0;
    
end