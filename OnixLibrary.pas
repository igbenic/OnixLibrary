unit OnixLibrary;

// verzija 1

interface 

uses dlComponents, cxgrid, controls, Variants, dlDatabase, Sysutils, cxCalc, Forms, dialogs, Classes;

type oxCallback = procedure(); 
type 
    TLocalAfterOpen = class(TObject)
    private                        
        oldEvent: TDataSetNotifyEvent;
    public                   
        AfterOldEvent: boolean;
        Callback: oxCallback;
        NewEvent: procedure(DataSet: TdlDataSet);
        constructor Create(oldEvent: TDataSetNotifyEvent);
    end;
    
type
    TcxDisplayTextOrdinalHelper = class(TObject)
    public 
        GetDisplayTextOrdinalNumber: procedure(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: String);
    end;
 
type
    TLocalAfterClick = class(TObject)
    private                        
        oldEvent: TNotifyEvent;
    public                   
        AfterOldEvent: boolean;
        Callback: oxCallback;
        NewEvent: procedure(Sender: TObject);
        constructor Create(oldEvent: TNotifyEvent);
    end;
 
type
    TLocalNotifyEvent = class(TObject)
    public
        Callback: oxCallback;
        procedure NotifyEvent(Sender: TObject);
        constructor Create(Callback: oxCallback);
    end;      

function oxSQLExp(SQL: String): String;
function oxSQLExpWithParams(SQL: String; params: array of Variant): String;
function oxAddColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxAddCurrencyColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxAddNumericColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxGetGridSQL(gridName: String): String;
function oxGetDatasetSQL(dataSet: String): String;
function oxGetDataset(dataset: String): TdlDataSet;
function oxGetGrid(grid: String): TcxGridDBTableView;
function oxOnlyASCIILetterAndNumbers(s: String): String;
function oxNavigatorAcKey(name: String = 'bMenuDBNavigator'): String;
function oxGetValue(ofElement: String): String;
function oxAsAcKey(someText: String): String;
function oxAsFloat(someText: String): extended;
function oxAddOrdinalNumberColumn(grid: String; columnCaption: String = 'Rbr.'; columnFieldName: String = '_ordinal_column_internal_ox'; width: integer = 50): TcxGridDBColumn;
function oxGetButton(button: String): TcxButton;
procedure oxAfterDataSetOpen(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
procedure oxBeforeDataSetPost(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
procedure oxAfterDataSetPost(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
procedure oxRefreshDataset(dataSet: String);
procedure oxRefreshGrid(grid: String; keepRecord: boolean = false);
procedure oxRedrawGrid(grid: String);
procedure oxHackRefreshDataSet(dataSet: String);
procedure oxHackRefreshGrid(grid: String; callback: oxCallback);
procedure oxConfirm(what: String; onYes: oxCallback; onNo: oxCallback);
procedure oxForceColumnIndex(forColumn: TcxGridDBColumn; index: Integer);
procedure oxLogObjectClassname(o: TObject; oName: String = 'nepoznato');
procedure oxLogElementClassname(elementName: String);
procedure oxAddSQLColumn(tableName: String; columnName: String; sqlType: String);
procedure oxBeforeButtonClick(button: String; callback: oxCallback);
procedure oxAfterButtonClick(button: String; callback: oxCallback);
procedure oxPrintComponent(component: TComponent; prefix: String = '');
function oxAddButtonInto(intoComponentName: String; inLineWithComponentName: String; caption: String; relativeCoordinates: array of Integer; onClickCallback: oxCallback): TdlcxButton;
function oxGetActiveFieldValue(gridOrDSName: string; fieldName: String): String;

implementation 

// sqlexp(query)
function oxSQLExp(sql:string):string
var dataSet: TdlDataSet;
var firstFieldName: string;
begin
    dataSet := TdlDataSet.Create(Ares);
    dataSet.SQL.Text := sql;
    dataSet.Open;
    _macro.eventlogadd('izvodim ' + sql);
    if dataSet.EOF then begin
        Result := '';
    end else begin       
        firstFieldName := dataSet.Fields[0].FieldName;
        Result := dataSet.FieldByName(firstFieldName).AsString;
    end;
end;

function oxSQLExpWithParams(sql: string; params: array of Variant): string;
var v: Variant;
    i: Integer;
    dataSet: TdlDataSet;
    firstFieldName: string;
begin
    dataSet := TdlDataSet.Create(Ares);
    dataSet.SQL.Text := sql;
    dataSet.Debug := true;
    dataSet.DontHandleException := true;
    for i := 0 to Length(params) - 1 do
    begin 
        dataSet.Params.ParamByName('p' + inttostr(i)).Value := params[i];
    end;      
    try
        dataSet.Open; 
        if dataSet.LastError <> null then
        begin
            raise Exception(dataSet.LastError);
        end; 
        if dataSet.EOF then begin
            Result := '';       
        end else begin       
            firstFieldName := dataSet.Fields[0].FieldName;
            Result := dataSet.FieldByName(firstFieldName).AsString;
        end;
        dataSet.Close;
    except on E:Exception do
        raise E;
    end;
end;

function oxAddColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
begin
    with TcxGridDBTableView(AresFindComponent(gridName, OwnerForm)) do
    begin      
        Result := CreateColumn();
        Result.Caption := columnCaption;
        Result.Name := oxOnlyASCIILetterAndNumbers(gridName + columnFieldName);
        Result.DataBinding.FieldName := columnFieldName;
        Result.Width := width;
    end;
end;

function oxAddCurrencyColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
begin
	Result := oxAddColumn(gridName, columnCaption, columnFieldName, width);
    with Result do
    begin
        PropertiesClass := TcxCurrencyEditProperties;
        with TcxCurrencyEditProperties(Properties) do
        begin
        end;
    end;
end;

function oxAddNumericColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
begin
	Result := oxAddColumn(gridName, columnCaption, columnFieldName, width);
    with Result do
    begin
        PropertiesClass := TcxCalcEditProperties;
        with TcxCalcEditProperties(Properties) do
        begin
            DisplayFormat := '###,##0.00';
        end;
    end;
end;

function oxGetGridSQL(gridName: String): String;
var strings: TStrings;
begin
    with TcxGridDBTableView(AresFindComponent(gridName, OwnerForm)) do
    begin
        strings := TdlDataSource(DataController.DataSet.DataSource).SQL;
        if strings <> nil then
        begin
            Result := strings.Text;
        end;
    end;
end;

function oxGetDatasetSQL(dataSet: String): String;
var c: TComponent;
    strings: TStrings;
    ds: TdlDataSet;
begin
    c := AresFindComponent(dataSet, OwnerForm);
    if c is TdlDataSet then
    begin    
        ds := TdlDataSet(c); 
        if ds.DataSource <> nil then
        begin          
            strings := TdlDataSource(ds.DataSource).SQL;
            if strings <> nil then
            begin
                Result := strings.Text;
            end;
        end else 
        begin
            showmessage('DataSet ' + dataset + ' je ispravna komponenta, ali joÄąË‡ ne postoji DataSource, pomakni Ă„Ĺ¤itanje SQL-a na kasniji korak u programu.');
        end;
    end else if c is TdlDataSource then
    begin
        strings := TdlDataSource(c).SQL;
        if strings <> nil then
        begin
            Result := strings.Text;
        end;
    end else 
    begin
        showmessage(dataset + ' nije pronaĂ„â€en kao dataset niti kao datasource!');
    end; 
end;

// dataset moÄąÄľe biti naziv dataseta, ali i grida, naĂ„â€ˇi Ă„â€ˇe ga
function oxGetDataset(dataset: String): TdlDataSet;
var c: TComponent;
begin
    c := AresFindComponent(dataset, OwnerForm);
    if c is TcxGridDBTableView then
    begin
        Result := TdlDataSet(TcxGridDBTableView(c).DataController.DataSet);
    end
    else if c is TcxDBLookupComboBox then
    begin
        Result := TdlDataSet(TcxDBLookupComboBox(c).DataBinding.DataSource.DataSet);
        _macro.eventlogadd('TraÄąÄľiÄąË‡ DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? VraĂ„â€ˇam DataSet od krajnjeg DataSeta.');
    end
    else if c is TDaDBLookupComboBox then
    begin
        Result := TdlDataSet(TDaDBLookupComboBox(c).DataBinding.DataSource.DataSet);
        _macro.eventlogadd('TraÄąÄľiÄąË‡ DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? VraĂ„â€ˇam DataSet od krajnjeg DataSeta.'); 
    end 
    else if c is TdlDataSet then
    begin
        Result := TdlDataSet(c);
    end 
    else if c is TcxGridDBBandedTableView then
    begin
        Result := TdlDataSet(TcxGridDBBandedTableView(c).DataController.DataSet);
    end else
    begin
        showmessage(dataset + ' nije TDataSet!');
    end;    
end;    

function oxOnlyASCIILetterAndNumbers(s: String): String;
var
  i, Count: Integer;
begin
  SetLength(Result, Length(s));
  Count := 0;
  for i := 1 to Length(s) do begin
    if (((s[i] >= #48) and (s[i] <= #57)) or ((s[i] >= #65) and (s[i] <= #90)) or ((s[i] >= #97) and (s[i] <= #122))) then 
    begin
      inc(Count);
      Result[Count] := s[i];
    end;
  end;
  SetLength(Result, Count);
end;

// sve za afterDataSetOpen

constructor TLocalAfterOpen.Create(oldEvent: TDataSetNotifyEvent);
begin
    self.oldEvent := oldEvent;
end;

procedure TLocalAfterOpen.NewEvent(DataSet: TdlDataSet);
begin
     if self.AfterOldEvent then
     begin
        if assigned(self.oldevent) then self.oldEvent(DataSet);
        self.callback;
     end else 
     begin      
        self.callback;
        if assigned(self.oldevent) then self.oldEvent(DataSet);
     end;
end;

procedure oxAfterDataSetOpen(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
var localAfterOpen: TLocalAfterOpen;
begin
    with oxGetDataset(dataset) do
    begin
        localAfterOpen := TLocalAfterOpen.Create(AfterOpen);
        localAfterOpen.Callback := callback;
        localAfterOpen.AfterOldEvent := afterOldEvent;    
        AfterOpen := localAfterOpen.NewEvent;
        _macro.eventlogadd('New event set for ' + dataset);
    end;
end;

procedure oxBeforeDataSetPost(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
var localAfterOpen: TLocalAfterOpen;
begin
    with oxGetDataset(dataset) do
    begin
        localAfterOpen := TLocalAfterOpen.Create(BeforePost);
        localAfterOpen.Callback := callback;
        localAfterOpen.AfterOldEvent := afterOldEvent;    
        BeforePost := localAfterOpen.NewEvent;
        _macro.eventlogadd('New event set for ' + dataset);
    end;
end;

procedure oxRefreshDataset(dataset: String);
begin
    with oxGetDataset(dataset) do
    begin         
        Refresh;
        _macro.eventlogadd(dataset + ' refreshed');
    end;
end;

procedure oxAfterDataSetPost(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
var localAfterOpen: TLocalAfterOpen;
begin
    with oxGetDataset(dataset) do
    begin
        localAfterOpen := TLocalAfterOpen.Create(AfterPost);
        localAfterOpen.Callback := callback;
        localAfterOpen.AfterOldEvent := afterOldEvent;    
        AfterPost := localAfterOpen.NewEvent;
        _macro.eventlogadd('New event set for ' + dataset);
    end;
end;

function oxGetGrid(grid: String): TcxGridDBTableView;
var c: TComponent;
begin
    c := AresFindComponent(grid, OwnerForm);
    
    if c is TcxGrid then
    begin
        Result := TcxGridDBTableView(TcxGrid(c).Views[0]);
    end 
    else if c is TcxGridDBTableView then
    begin
        Result := TcxGridDBTableView(c);
    end
    else
    begin
        showmessage('Not a valid grid or gridview: ' + grid);
    end;
end;

procedure oxRedrawGrid(grid: String);
begin
    with oxGetGrid(grid) do
    begin
        DataController.UpdateItems(true);
    end;
end;

procedure oxRefreshGrid(grid: String; keepRecord: boolean = false);
var
  DetailRecIdx : integer;
  MasterRecIdx : integer;
begin       
    MasterRecIdx := -1;
    DetailRecIdx := -1;
    with oxGetGrid(grid) do
    begin             
        if not keepRecord then
        begin
            DataController.RefreshExternalData();
            DataController.UpdateItems(true);
        end else 
        begin   
            if IsDetail then
            begin
                MasterRecIdx := MasterRecordIndex;
                DetailRecIdx := Controller.FocusedRecordIndex;
            end else 
            begin
                DetailRecIdx := Controller.FocusedRecordIndex;
            end;    
            DataController.RefreshExternalData();
            DataController.UpdateItems(true);
            _macro.eventlogadd('MasterRecIdx: ' + MasterRecIdx.ToString()); 
            _macro.eventlogadd('DetailRecIdx: ' + DetailRecIdx.ToString()); 
            if IsMaster and (MasterRecIdx > -1) then
            begin         
                _macro.eventlogadd('Is master and has focusable index');
                if Controller.FocusNextRecord(MasterRecIdx, true, true, true, false) then
                begin
                    ViewData.Rows[MasterRecIdx].Expand(false);
                    if IsDetail and (DetailRecIdx > -1) then
                    begin
                        Controller.FocusedRecordIndex := DetailRecIdx;
                    end;
                end;  
            end else
            begin
                if DetailRecIdx > -1 then
                begin                 
                    _macro.eventlogadd('nije master, stavljam focus na detail poziciju');
                    Controller.FocusNextRecord(DetailRecIdx, true, true, true, false);
                    ViewData.Rows[DetailRecIdx].Expand(false);
                    Controller.FocusedRecordIndex := DetailRecIdx;
                end else if MasterRecIdx > -1 then
                begin        
                    _macro.eventlogadd('nije detail, stavljam focus na master poziciju');
                    Controller.FocusNextRecord(MasterRecIdx, true, true, true, false);
                    ViewData.Rows[MasterRecIdx].Expand(false); 
                    Controller.FocusedRecordIndex := MasterRecIdx;
                end;
            end;
        end;
    end;
end;

procedure oxHackRefreshDataSet(dataSet: String);
begin
    showmessage('not implemented oxHackRefreshDataSet');   
end;

procedure oxHackRefreshGrid(grid: String; callback: oxCallback);
var colIndex: Integer;
    gridMode: boolean;
    columnSettings: TStringList;
    currSetting: String;
begin 
    columnSettings := TStringList.Create();
    with oxGetGrid(grid) do
    begin           
        for colIndex := 0 to ColumnCount - 1 do
        begin
            try
                with Columns[colIndex] do
                begin                 
                    currSetting := '';
                    columnSettings.Add(currSetting);
                    if Editing then currSetting := currSetting + 'T'
                    else currSetting := currSetting + 'F';
                    if Options.Editing then currSetting := currSetting + 'T'
                    else currSetting := currSetting + 'F';
                    if Properties.Readonly then currSetting := currSetting + 'T'
                    else currSetting := currSetting + 'F';
                    Editing := true;
                    Options.Editing := true;
                    Properties.Readonly := false;
                end;
            except on E: Exception do 
                _macro.EventLogAdd(E.message);
            end;
        end;    
        with DataController do
        begin       
            BeginUpdate;     
            Refresh;
            DataSet.Refresh;
            gridMode := DataModeController.GridMode;
            DataModeController.GridMode := not gridMode;
            EndUpdate;
        end;   
        callback();
        with DataController do
        begin       
            BeginUpdate;     
            Refresh;
            DataSet.Refresh;
            DataModeController.GridMode := gridMode;
            EndUpdate;
        end;
        for colIndex := 0 to ColumnCount - 1 do
        begin
            try
                with Columns[colIndex] do
                begin
                    Editing := columnSettings[colIndex][0] = 'T';
                    Options.Editing := columnSettings[colIndex][1] = 'T';
                    Properties.Readonly := columnSettings[colIndex][2] = 'T';
                end;
            except on E: Exception do 
                _macro.EventLogAdd(E.message);
            end;
        end;
    end;
end;

procedure oxConfirm(what: String; onYes: oxCallback = null; onNo: oxCallback = null);
var res: Integer;
begin
    _macro.eventlogadd('Executing dialog');
    try
        res := Integer(Dialogs.MessageDlg(what, mtConfirmation, [mbYes, mbNo], 0, mbYes));
        if (res = mrYes) then
        begin       
            _macro.eventlogadd('Executing yes');
            onYes();
        end;
        if (res = mrNo) then 
        begin       
            _macro.eventlogadd('Executing no');
            onNo();
        end;
    except on E: Exception do
        _macro.eventlogadd('Dialog error: ' + E.Message);
    end;
end;

function oxNavigatorAcKey(name: String = 'bMenuDBNavigator'): String;
var comp: TComponent;
begin
    comp := OwnerForm.FindComponent(name);
    if not assigned(comp) then
    begin
        showmessage(name + ' nije ispravan navigator! nije pronaĂ„â€en...');
    end else
    begin
        Result := TNavigator3(comp).datasource.dataset.FieldByName('ackey').asstring;
    end;
end;

function oxGetValue(ofElement: String): String;
var comp: TComponent;
begin
    comp := OwnerForm.FindComponent(ofElement);
    
    if not assigned(comp) then
    begin               
        showmessage(ofElement + ' nije pronaĂ„â€en!!!');
    end else
    begin    
        _macro.eventlogadd('Element ' + ofElement + ' je pronaĂ„â€en, testiram vrstu'); // ovdje naredati sve moguĂ„â€ˇe class opcije
        if comp is TdlcxLabeledDBTextEdit then Result := TdlcxLabeledDBTextEdit(comp).EditingValue
        else if comp is TdlcxLabeledNumberEdit then Result := TdlcxLabeledNumberEdit(comp).EditingValue
        else showmessage('Nije implementirana vrsta za ' + ofElement + ': ' + comp.classname);
    end;
    
    _macro.eventlogadd('Element ' + ofElement + ' obraĂ„â€en s vrijednoÄąË‡Ă„â€ˇu: ' + Result);
end;

function oxAsAcKey(someText: String): String;
var yearPart: String;
    docPart: String;
    counterPart: String;
begin
    if someText.IndexOf('-') <> -1 then
    begin                 
        yearPart := COPY(someText,0,2);
        docPart := COPY(someText,4,3);
        counterPart := COPY(someText,8, 20);
        _macro.eventlogadd(Format('Parsed someText with: Year: [%s], Doc: [%s], Counter: [%s]', [yearPart, docPart, counterPart]));
        Result := yearPart + docPart +'00'+ counterPart;
    end
    else Result := someText;
    Result := TRIM(Result);
    _macro.eventlogadd('oxAsAcKey returning: ' + Result);
end;

function oxAsFloat(someText: String): extended;
begin
    Result := strToFloat(someText);
end;

// dovanje stupca redni broj
procedure TcxDisplayTextOrdinalHelper.GetDisplayTextOrdinalNumber(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AText: String);
var row: Integer;
begin
    //row := Sender.DataController.GetRowIndexByRecordIndex(ARecord.RecordIndex, False);
    //AText := IntToStr(row + 1);
    AText := IntToStr(ARecord.Index + 1);
end;

function oxAddOrdinalNumberColumn(grid: String; columnCaption: String = 'Rbr.'; columnFieldName: String = '_ordinal_column_internal_ox'; width: integer = 50): TcxGridDBColumn;
var helper: TcxDisplayTextOrdinalHelper;
begin
    helper := TcxDisplayTextOrdinalHelper.Create();
    Result := oxAddColumn(grid, columnCaption, columnFieldName);
    with Result do
    begin                   
        OnGetDisplayText := helper.GetDisplayTextOrdinalNumber;
    end;
end;

procedure oxForceColumnIndex(forColumn: TcxGridDBColumn; index: Integer);
begin
    raise Exception.Create('Nije implementirano!!! oxForceColumnIndex');
end;

procedure oxLogObjectClassname(o: TObject; oName: String = 'nepoznato');
begin
    _macro.EventLogAdd(Format('Object "%s" has ClassName: "%s"', [oName, o.ClassName]));
end;

procedure oxLogElementClassname(elementName: String);
var obj: TObject;
begin
    obj := Ares.FindComponent(elementName);
    if obj <> nil then oxLogObjectClassName(obj, elementName)
    else _macro.EventLogAdd(Format('Nije pronaĂ„â€en element: "%s"', [elementName]));
end;

function oxGetButton(button: String): TcxButton;
begin
    Result := TcxButton(AresFindComponent(button, OwnerForm));
end;

// sve za onClickOverride

constructor TLocalAfterClick.Create(oldEvent: TNotifyEvent);
begin
    self.oldEvent := oldEvent;
end;

procedure TLocalAfterClick.NewEvent(Sender: TObject);
begin
     if self.AfterOldEvent then
     begin
        if assigned(self.oldevent) then self.oldEvent(Sender);
        self.callback;
     end else 
     begin      
        self.callback;
        if assigned(self.oldevent) then self.oldEvent(Sender);
     end;
end;

procedure oxAddSQLColumn(tableName: String; columnName: String; sqlType: String);
var alterSQL: String;
begin
    alterSQL := 'IF NOT EXISTS (SELECT * FROM syscolumns                 '             +
        'WHERE ID=OBJECT_ID(''' + tableName + ''') AND NAME=''' + columnName + ''')    '       +
        'ALTER TABLE ' + tableName + '      '                                          +
        'ADD ' + columnName + ' ' + sqlType + '';
    oxSQLExp(alterSQL);
end;

procedure oxBeforeButtonClick(button: String; callback: oxCallback);
var localBeforeClick: TLocalAfterClick;
begin
    with oxGetButton(button) do
    begin
        localBeforeClick := TLocalAfterClick.Create(OnClick);
        localBeforeClick.Callback := callback;
        localBeforeClick.AfterOldEvent := false;    
        OnClick := localBeforeClick.NewEvent;
        _macro.eventlogadd('New event set before, for ' + button);
    end;
end;

procedure oxAfterButtonClick(button: String; callback: oxCallback);
var localAfterClick: TLocalAfterClick;
begin
    with oxGetButton(button) do
    begin
        localAfterClick := TLocalAfterClick.Create(OnClick);
        localAfterClick.Callback := callback;
        localAfterClick.AfterOldEvent := true;    
        OnClick := localAfterClick.NewEvent;
        _macro.eventlogadd('New event set after, for ' + button);
    end;
end;

function oxGetActiveFieldValue(gridOrDSName: string; fieldName: String): String;
var columnIndex: Integer;
    column: TcxGridColumn;
begin
    with oxGetGrid(gridOrDSName) do
    begin                
        column := GetColumnByFieldName(fieldName);
        if column <> nil then
        begin
            columnIndex := column.Index;
            _macro.EventLogAdd('Column index: ' + inttostr(columnIndex));
            Result := Controller.FocusedRow.Values[columnIndex];
        end else begin
            showmessage(fieldName + ' ne postoji na ' + gridOrDSName + '!');
        end;
    end;
end;

procedure oxPrintComponent(component: TComponent; prefix: String = '');
var index: Integer;
begin
    if component <> nil then
    begin
        _macro.EventLogAdd(Format('%s%s', [prefix, component.Name]));
        for index := 0 to component.ComponentCount - 1 do
        begin
            oxPrintComponent(component.Components[index], prefix + #9);
        end; 
    end else
    begin
        _macro.EventLogAdd(Format('%s%s', [prefix, 'Tražena komponenta nije postavljena']));
    end;   
end;

constructor TLocalNotifyEvent.Create(Callback: oxCallback);
begin
    self.Callback := Callback;
end;

procedure TLocalNotifyEvent.NotifyEvent(Sender: TObject);
begin
    self.Callback();
end;

function oxAddButtonInto(intoComponentName: String; inLineWithComponentName: String; caption: String; relativeCoordinates: array of Integer; onClickCallback: oxCallback): TdlcxButton;
var intoComponent: TdlcxPanel;
    inLineWithComponent: TControl;
    callbackWrapper: TLocalNotifyEvent;
    topOffset: Integer;
    leftOffset: Integer;
begin
    Result := TdlcxButton.Create(Ares);
    
    intoComponent := TdlcxPanel(AresFindComponent(intoComponentName, OwnerForm));
    inLineWithComponent := TControl(AresFindComponent(inLineWithComponentName, OwnerForm));
    
    callbackWrapper := TLocalNotifyEvent.Create(onClickCallback);
    
    if (Length(relativeCoordinates) = 0) then
    begin
        relativeCoordinates := [0, 0];
    end;
        
    if (Length(relativeCoordinates) = 2) then
    begin    
        topOffset := relativeCoordinates[0];
        leftOffset := relativeCoordinates[1];
        Result.Parent := intoComponent;
        Result.Top := inLineWithComponent.Top + topOffset;
        Result.Left := inLineWithComponent.Left + inLineWithComponent.Width + leftOffset;
        Result.Name := intoComponentName + inLineWithComponentName + oxOnlyASCIILetterAndNumbers(caption);
        Result.Enabled := true;
        Result.OnClick := callbackWrapper.NotifyEvent;
        Result.Caption := caption;
    end else
    begin
        showmessage('Unesite ispravan broj argumenata za relativne koordinate gumba u ' + intoComponentName + '. prazno [] ili [10, 0] odnosno [top, left] unutar ' + intoComponentName);
    end;
end;

end.
