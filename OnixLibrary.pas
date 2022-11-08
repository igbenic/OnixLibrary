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
procedure oxAfterDataSetOpen(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
procedure oxAfterDataSetPost(dataSet: String; callback: oxCallback; afterOldEvent: boolean = false);
procedure oxRefreshDataset(dataSet: String);
procedure oxRefreshGrid(grid: String; keepRecord: boolean = false);
procedure oxRedrawGrid(grid: String);
procedure oxHackRefreshDataSet(dataSet: String);
procedure oxHackRefreshGrid(grid: String; callback: oxCallback);
procedure oxConfirm(what: String; onYes: oxCallback; onNo: oxCallback);

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
    for i := 0 to Length(params) - 1 do
    begin 
        dataSet.Params.ParamByName('p' + inttostr(i)).Value := params[i];
    end;
    dataSet.Open;
    if dataSet.EOF then begin
        Result := '';
    end else begin       
        firstFieldName := dataSet.Fields[0].FieldName;
        Result := dataSet.FieldByName(firstFieldName).AsString;
    end;
    dataSet.Close;
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
            showmessage('DataSet ' + dataset + ' je ispravna komponenta, ali još ne postoji DataSource, pomakni čitanje SQL-a na kasniji korak u programu.');
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
        showmessage(dataset + ' nije pronađen kao dataset niti kao datasource!');
    end; 
end;

// dataset može biti naziv dataseta, ali i grida, naći će ga
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
        _macro.eventlogadd('Tražiš DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? Vraćam DataSet od krajnjeg DataSeta.');
    end
    else if c is TDaDBLookupComboBox then
    begin
        Result := TdlDataSet(TDaDBLookupComboBox(c).DataBinding.DataSource.DataSet);
        _macro.eventlogadd('Tražiš DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? Vraćam DataSet od krajnjeg DataSeta.'); 
    end 
    else if c is TdlDataSet then
    begin
        Result := TdlDataSet(c);
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

procedure oxRefreshDataset(dataset: String);
begin
    with oxGetDataset(dataset) do
    begin         
        Refresh;
        _macro.eventlogadd(dataset + ' refreshed');
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
        showmessage(name + ' nije ispravan navigator! nije pronađen...');
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
        showmessage(ofElement + ' nije pronađen!!!');
    end else
    begin    
        _macro.eventlogadd('Element ' + ofElement + ' je pronađen, testiram vrstu'); // ovdje naredati sve moguće class opcije
        if comp is TdlcxLabeledDBTextEdit then Result := TdlcxLabeledDBTextEdit(comp).EditingValue
        else if comp is TdlcxLabeledNumberEdit then Result := TdlcxLabeledNumberEdit(comp).EditingValue
        else showmessage('Nije implementirana vrsta za ' + ofElement + ': ' + comp.classname);
    end;
    
    _macro.eventlogadd('Element ' + ofElement + ' obrađen s vrijednošću: ' + Result);
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
procedure GetDataTextOrdinalNumber(Sender: TcxCustomGridTableView; ARecordIndex: Integer; var AText: String);
var AIndex: Integer;
begin
    AIndex := TcxGridDBTableView(Sender).DataController.GetRowIndexByRecordIndex(ARecordIndex, False);
    AText := IntToStr(AIndex + 1);
end;

procedure oxAddOrdinalNumberColumn(grid: String; columnCaption: String = 'Redni broj');
begin
    with oxAddColumn(grid, columnCaption) do
    begin
        GetDataText := GetDataTextOrdinalNumber;
    end;
end

end.
