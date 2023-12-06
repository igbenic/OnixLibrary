unit OnixLibrary;

// verzija 1

interface 


Uses dlComponents, cxScrollBox, cxgrid, controls, Variants, dlDatabase, Sysutils
, cxCalc, Forms, dialogs, Classes, clEncoder, menus, DB, extctrls, DateUtils, clHTTP, clHTTPRequest, clJson;



type TCheckboxListOnix = class(TComponent)
    private                 
        parent: TComponent;
        scrollBox: TcxScrollBox;
        popupMenu: TPopupMenu;
	    totalScrollboxHeight: Integer;
	    values: TStringList;
        skipCheckboxCallbacks: boolean; 
        procedure popupMenuPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
        procedure scrollboxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
        procedure scrollboxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
        procedure addMenuItems();
        procedure checkAllMenuItemClicked(Sender: TObject);
        procedure uncheckAllMenuItemClicked(Sender: TObject);
        procedure checkInverseMenuItemClicked(Sender: TObject); 
        procedure onChangedWrapper(Sender: TObject);
    public                
        onChanged: TNotifyEvent;
        constructor Create(AParent: TComponent); override;
        procedure Add(AKey: string; AValue: string; AChecked: boolean = false);
        procedure AddFromCSV(CSV: string);
        procedure AddFromDataSet(Dataset: TdlDataSet);
        function GetSelectedKeys():TStringList;
        function GetSelectedKeysJoined(by: String = ','):string;
        function GetSelectedKeysJoinedAndQuoted(by: String = ','):string;
    end;

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
    
type
    TDeferEvent = class(TObject)
    public
        Callback: oxCallback;
        Timer: TTimer;                           
        Timeout: Integer;
        procedure TimerFired(Sender: TObject);
        constructor Create(forCallback: oxCallback; forTimeout: Integer);
    end;

function oxSQLExp(SQL: String): String;
function oxSQLExpWithParams(SQL: String; params: array of Variant): String;
function oxSQLBlobToStream(sql: string; params: array of Variant): TStream;
function oxAddColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxAddCurrencyColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxAddNumericColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
function oxAddCheckboxColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
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
function oxConfirmBool(what: String): Boolean;
function oxAddButtonInto(intoComponentName: String; inLineWithComponentName: String; caption: String; relativeCoordinates: array of Integer; onClickCallback: oxCallback): TdlcxButton;
function oxGetActiveFieldValue(gridOrDSName: string; fieldName: String): String;
function oxSTruthy(v: String; zeroIsFalsy: boolean = false): boolean;
function oxDTruthy(v: TDateTime): boolean;
function oxColumnExists(tableName: String; columnName: String): boolean;
Function oxTableExists(tableName: String): boolean;
function oxDateToSQLString(date: TDateTime): String;
function oxNavigator(name: String = 'bMenuDBNavigator'): TNavigator3;
function oxCheckComboBoxSelectedKeys(cbx: TcxCheckComboBox): TStringList;
function oxCheckComboBoxSelectedKeysSeparated(cbx: TcxCheckComboBox; delimiter: String = ','): String;
function oxSQLStepResult(stepId: Integer): String;
function oxSQLStepResultWithParams(stepId: Integer; params: array of Variant): String;
function oxSQLStepResultAnotherAres(stepId: Integer; aresAcKey: String): String;
function oxSQLStepResultWithParamsAnotherAres(stepId: Integer; aresAcKey: String; params: array of Variant): String;
function IsWeekend(ADate: TDateTime): Boolean;
function GetFirstBusinessDayAfterToday: TDateTime;
Function oxColumnByFieldName(TableView: TcxGridDBTableView; Const FieldName: String): TcxGridDBColumn;
Function oxColumnByName(TableView: TcxGridDBTableView; Const ColName: String): TcxGridDBColumn;
function oxSendTwilioMessage(const AccountSID, AuthToken, ToNumber, FromNumber, MessageBody: String): String;
function oxSendInfoBipMessage(const BaseURL, APIKey, Sender, Recipient, MessageText: String): String;
function oxSQLStepWithAresVariablesApplied(stepId: Integer): String;
function oxApplyAresVariablesToString(s: String): String;
function oxParseCSV(const CSVFileName, Delimiter, QuoteChar: string): array of TStringList;
function oxTransliterate(const Text: string): string;
function oxCommaTextToTStringList(commaText: String; delimiter: String = ','): TStringList;
function oxMemoryStreamToString(MStream: TMemoryStream): string;
function oxSQLExpRowWithParams(sql: string; params: array of Variant): TdlDataSet;
function oxContainsValue(const Arr: array of string; const Value: string): Boolean;
procedure oxLogAresVariables();
procedure oxDrillClassParent(obj: TObject); 
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
procedure oxOnButtonClick(button: String; callback: oxCallback);
procedure oxBeforePopupClick(popupName: String; callback: oxCallback);
procedure oxAfterButtonClick(button: String; callback: oxCallback);
procedure oxPrintComponent(component: TComponent; prefix: String = '');
procedure oxDataSetToCSV(DataSet: TdlDataSet; const FileName: string; const Delimiter: string = ';'; const QuoteEverything: boolean = false);
procedure oxAddToNavigator(field: String; fieldLen: Integer; fieldName: String; fieldF: String; navigator: String = 'bMenuDBNavigator'; atIndex: Integer = -1);
procedure oxAddToNavigatorAt(field: String; fieldLen: Integer; fieldName: String; fieldF: String; atIndex: Integer = -1);
procedure oxAddDefToNavigator(def: String; navigator: String = 'bMenuDBNavigator'; atIndex: Integer = -1);
procedure oxAddDefToNavigatorAt(def: String; atIndex: Integer = -1);
procedure oxDefer(callback: oxCallback; forMs: integer = 1);
procedure oxItemsFromDataset(cbx: TcxCheckComboBox; DataSet: TDataSet);
procedure oxImportCSV(csv: array of TStringList; tableName: String; tableColumns: array of string; firstRow: integer = 0; recreateTable: boolean = true; cleanTable: boolean = true);
procedure oxParseAndImportCSV(const CSVFileName, Delimiter, QuoteChar: string; tableName: String; tableColumns: array of string; firstRow: integer = 0; recreateTable: boolean = true; cleanTable: boolean = true);


Implementation

procedure oxLogAresVariables();
var variableStrings: TStringList;
    varString: String;
begin
    variableStrings := TStringList.Create();    
    Ares.Variables.SaveToStrings(variableStrings);
    
    for varString in variableStrings do begin
        // ovo ispisuje svaki redak
        _macro.EventLogAdd(varString);
    end;
end;

function oxContainsValue(const Arr: array of string; const Value: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(Arr) do
    if Arr[I] = Value then
    begin
      Result := True;
      Exit;
    end;
end;

function oxMemoryStreamToString(MStream: TMemoryStream): string;
var
  SS: TStringStream;
begin
  if MStream <> nil then
  begin
    MStream.Position := 0;
    SS := TStringStream.Create('');
    try
      SS.CopyFrom(MStream, MStream.Size);
      Result := SS.DataString;
    finally
      SS.Free;
    end;
  end;
end;

function oxCommaTextToTStringList(commaText: String; delimiter: String = ','): TStringList;
var sl: TStringList;
begin
    sl := TStringList.Create;
    sl.Delimiter := delimiter;
    sl.DelimitedText := commaText;
    result := sl;
end;

function oxTransliterate(const Text: string): string;
var
  i: Integer;
begin
  Result := Text;
  for i := 1 to Length(Result) do
  begin
    case Result[i] of
      'è', 'æ': Result[i] := 'c';
      'š': Result[i] := 's';
      'ð': Result[i] := 'd';
      'ž': Result[i] := 'z';
      'È', 'Æ': Result[i] := 'C';
      'Š': Result[i] := 'S';
      'Ð': Result[i] := 'D';
      'Ž': Result[i] := 'Z';
      'á', 'a', 'ä', 'â', 'a': Result[i] := 'a';
      'Á', 'A', 'Ä', 'Â', 'A': Result[i] := 'A';
      'é', 'e', 'ë', 'e': Result[i] := 'e';
      'É', 'E', 'Ë', 'E': Result[i] := 'E';
      'í', 'i', 'i', 'î': Result[i] := 'i';
      'Í', 'I', 'I', 'Î': Result[i] := 'I';
      'ó', 'o', 'ö', 'ô', 'o': Result[i] := 'o';
      'Ó', 'O', 'Ö', 'Ô', 'O': Result[i] := 'O';
      'ú', 'u', 'ü', 'u': Result[i] := 'u';
      'Ú', 'U', 'Ü', 'U': Result[i] := 'U';
      // Add any other special characters and their replacements here
    end;
  end;
end;


function oxParseCSV(const CSVFileName, Delimiter, QuoteChar: string): array of TStringList;
var
  CSVFile: TStringList;
  I: Integer;
begin
  CSVFile := TStringList.Create;

  try
    // Load the CSV file
    CSVFile.LoadFromFile(CSVFileName);

    // Set the length of the result array
    SetLength(Result, CSVFile.Count);

    // Iterate over the lines in the CSV file
    for I := 0 to CSVFile.Count - 1 do
    begin
      Result[I] := TStringList.Create;

      // Set the delimiter and quote char
      Result[I].Delimiter := Delimiter;
      Result[I].StrictDelimiter := True; // Ignore spaces as delimiters
      Result[I].QuoteChar := QuoteChar;

      // Parse the line into a TStringList of fields
      Result[I].DelimitedText := CSVFile[I];
    end;
  finally
    CSVFile.Free;
  end;
end;

procedure oxImportCSV(csv: array of TStringList; tableName: String; tableColumns: array of string; firstRow: integer = 0; recreateTable: boolean = true; cleanTable: boolean = true);
var createQuery: String;
    insertQuery: String;
    colIndex: Integer;
    rowIndex: Integer;
    tableColumn: String;
    rowValues: array of Variant;
begin
    if recreateTable and oxtableexists(tableName) then
    begin
        oxSQLExp('drop table ' + tableName);
    end;

    if not oxTableExists(tableName) then
    begin        
        createQuery := 'create table ' + tableName + ' (';
        for colIndex := 0 to High(tableColumns) do
        begin                
            tableColumn := tableColumns[colIndex];
            createQuery := createQuery + char(13) + '   [' + tableColumn + '] varchar(max) ';
            if colIndex < High(tableColumns) then
            begin
                createQuery := createQuery + ',';
            end;
        end;                                     
        createQuery := createQuery + char(13) + ');';
        oxSQLExp(createQuery);
    end;
    
    if cleanTable then
    begin
        oxSQLExp('truncate table ' + tableName);
    end; 

    insertQuery := 'insert into ' + tableName + '(';
          
    for colIndex := 0 to High(tableColumns) do
    begin
        insertQuery := insertQuery + '[' + tableColumns[colIndex] + ']';
        if colIndex < High(tableColumns) then
        begin
            insertQuery := insertQuery + ', ';
        end;
    end;
    
    insertQuery := insertQuery + ')' + char(13) + 'values(';
        
    for colIndex := 0 to High(tableColumns) do
    begin
        insertQuery := insertQuery + ':p' + IntToStr(colIndex); 
        if colIndex < High(tableColumns) then
        begin
            insertQuery := insertQuery + ',';
        end;
    end;        
                               
    insertQuery := insertQuery + ');'; 
    
    SetLength(RowValues, Length(tableColumns));
        
    for rowIndex := firstRow to High(csv) do
    begin              
        for colIndex := 0 to High(tableColumns) do
        begin             
            rowValues[colIndex] := csv[rowIndex][colIndex];
        end;                                    
        oxSQLExpWithParams(insertQuery, rowValues);
    end;
end;

procedure oxParseAndImportCSV(const CSVFileName, Delimiter, QuoteChar: string; tableName: String; tableColumns: array of string; firstRow: integer = 0; recreateTable: boolean = true; cleanTable: boolean = true);
var parsed: array of TStringList;
begin
    parsed := oxParseCSV(CSVFileName, Delimiter, QuoteChar);
    oxImportCSV(parsed, tableName, tableColumns, firstRow, recreateTable, cleanTable);
end;

function oxSendTwilioMessage(const AccountSID, AuthToken, ToNumber, FromNumber, MessageBody: String): String;
 var request: TclHTTP;
     response: TStringList;
     URL: String;
 begin
     URL := Format('https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json', [AccountSID]);
     response := TStringList.Create();
     request := TclHTTP.Create(nil); 
     request.UseTLS := ctAutomatic; 
     request.TLSFlags := [];
     request.Request := TclHTTPRequest.Create(request);
     request.Request.HeaderSource.Add('Content-Type: application/x-www-form-urlencoded');
     request.SilentHTTP := true;              
     request.UserName := AccountSID;
     request.Password := AuthToken;
     request.Request.ClearItems(); 
     request.Request.AddFormField('To', ToNumber);
     request.Request.AddFormField('From', FromNumber);
     request.Request.AddFormField('Body', MessageBody);
     request.Post(URL, response);
     _macro.EventLogAdd(response.text);
     Result := response.text;
 end;

 function oxSendInfoBipMessage(const BaseURL, APIKey, Sender, Recipient, MessageText: String): String;
var
  request: TclHTTP;
  response: TStringList;
  URL: String;
  jsonRequest: TclJSONObject;
  jsonMessage, jsonDestinations: TclJSONObject;
  jsonMessagesArray, jsonDestinationsArray: TclJSONArray;
  RequestStream: TStringStream;
  RequestStrings: TStringList;
  jsonLanguages: TclJSONObject;
  acPhone: String;
begin
  if BaseURL.EndsWith('/') then
  begin
    URL := BaseURL + 'sms/2/text/advanced';
  end else
  begin
    URL := BaseURL + '/sms/2/text/advanced';
  end;

  request := TclHTTP.Create(nil);
  response := TStringList.Create();
  RequestStrings := TStringList.Create();
  jsonRequest := TclJSONObject.Create();

  try
    // Construct the JSON payload
    jsonMessagesArray := TclJSONArray.Create();
    jsonRequest.AddMember('messages', jsonMessagesArray);
    
    jsonMessage := TclJSONObject.Create();
    jsonMessagesArray.Add(jsonMessage);
    jsonMessage.AddString('from', Sender);
    jsonMessage.AddString('text', MessageText);
    
    //jsonLanguages := TclJSONObject.Create();
    //jsonLanguages.AddString('languageCode', 'HR'); 
    //jsonMessage.AddMember('language', jsonLanguages);

    // Create destinations array and add a destination object
    jsonDestinationsArray := TclJSONArray.Create();
    jsonMessage.AddMember('destinations', jsonDestinationsArray);
                 
    for acPhone in Recipient.Split(';') do
    begin    
        jsonDestinations := TclJSONObject.Create();
        jsonDestinationsArray.Add(jsonDestinations);
        jsonDestinations.AddString('to', oxOnlyASCIILetterAndNumbers(EnsureCountryCode(acPhone, '00385')));
    end;

    // Convert the JSON object to a string and add it to the request source 
    //RequestStream := TStringStream.Create(jsonRequest.GETJsonString(), TEncoding.UTF8);
    RequestStrings := TStringList.Create();
    RequestStrings.Add(jsonRequest.GETJsonString()); 
    request.Request := TclHTTPRequest.Create(request);
    //request.Request.RequestSource := RequestStrings; // Assuming you can set RequestSource directly
    request.Request.RequestSource := RequestStrings; // Assuming you can set RequestSource directly
    
    // Set up the HTTP request
    request.UseTLS := ctAutomatic;
    request.TLSFlags := []; 
    request.SilentHTTP := true;              
    request.Request.HeaderSource.Add('Content-Type: application/json');
    request.Request.HeaderSource.Add('Authorization: App ' + APIKey);

    // Send the request
    request.Post(URL, response);
    
    _macro.EventLogAdd(response.Text);
    
    Result := response.Text;
  finally
    jsonRequest.Free;
    request.Free;
    response.Free;
    RequestStrings.Free;
  end;
end;

function EnsureCountryCode(const Number: String; const DefaultCountryCode: String): String;
begin
  // Check if the number starts with '+' or '00' which means it's already in international format
  if Number.StartsWith('+') or Number.StartsWith('00') then
  begin
    Result := Number;
  end
  else
  begin
    // If the number starts with '0', remove this leading '0' before adding the country code
    if Number.StartsWith('0') then
    begin
      Result := DefaultCountryCode + Copy(Number, 2, MaxInt);
    end
    else
    begin
      Result := DefaultCountryCode + Number;
    end;
  end;
end;


Function oxColumnByFieldName(TableView: TcxGridDBTableView; Const FieldName:
                             String): TcxGridDBColumn;

Var 
  i: Integer;
Begin
  Result := Nil;
  // Default result for "not found"

  For i := 0 To TableView.ColumnCount - 1 Do
    Begin
      If Assigned(TableView.Columns[i].DataBinding) And
         Assigned(TableView.Columns[i].DataBinding.Field) And
         SameText(TableView.Columns[i].DataBinding.Field.FieldName, FieldName)
        Then
        Begin
          Result := TableView.Columns[i];
          Break;
        End;
    End;
End;

Function oxColumnByName(TableView: TcxGridDBTableView; Const ColName: String):




                                                                 TcxGridDBColumn
;

Var 
  i: Integer;
Begin
  Result := Nil;
  // Default result for "not found"

  For i := 0 To TableView.ColumnCount - 1 Do
    Begin
      If SameText(TableView.Columns[i].Name, ColName) Then
        Begin
          Result := TableView.Columns[i];
          Break;
        End;
    End;
End;


function oxCheckComboBoxSelectedKeys(cbx: TcxCheckComboBox): TStringList;
var
  i: Integer;
  Params: TStringList;
begin
  Params := TStringList.Create;

    for i := 0 to cbx.Properties.Items.Count - 1 do
    begin
      if cbx.States[i] = cbsChecked then
      begin
        Params.Add(cbx.Properties.Items[i].Tag.ToString);
      end;
    end;
  
  Result := Params;
end;

function oxCheckComboBoxSelectedKeysSeparated(cbx: TcxCheckComboBox; delimiter: String = ','): String;
var ts: TStringList;
begin
    ts := oxCheckComboBoxSelectedKeys(cbx);
    ts.Delimiter := delimiter;
    Result := ts.CommaText;
end;

procedure oxItemsFromDataset(cbx: TcxCheckComboBox; DataSet: TDataSet);
begin
    cbx.Properties.Items.Clear(); 
    
  if not Dataset.Active then
  begin
    Dataset.open;
  end;
  Dataset.First;
  while not Dataset.EOF do
  begin
    // Make sure the dataset has at least three fields
    if Dataset.Fields.Count < 3 then
      raise Exception.Create('Dataset has less than three fields');
          
      
  with cbx.Properties.Items.Add do
  begin
    Description := Dataset.Fields[0].AsString;
    Tag := Dataset.Fields[1].AsInteger;
  end;
  
    //self.Add(Dataset.Fields[0].AsString, 
    //         Dataset.Fields[1].AsString, 
    //         Dataset.Fields[2].AsString = '1');
             
    Dataset.Next;
  end;
end;

function GetFirstBusinessDayAfterToday: TDateTime;
var
  DateAfterToday: TDateTime;
begin
DateAfterToday := IncDay(DateOf(Now), 1);

  while IsWeekend(DateAfterToday) do
  begin
    DateAfterToday := IncDay(DateAfterToday, 1);
  end;
  Result := DateAfterToday;
end;

function IsWeekend(ADate: TDateTime): Boolean;
var
  DayOfWeek: Integer;
begin
  DayOfWeek := DayOfTheWeek(ADate);
  Result := (DayOfWeek = DaySaturday) or (DayOfWeek = DaySunday);
end;

function oxSQLStepResultAnotherAres( stepId: Integer; aresAcKey: String = nil): String;
var stepSQL: String;
begin
    stepSQL := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [aresAcKey, stepId]);
    result := oxSQLExp(stepSQL);
end;

function oxApplyAresVariablesToString(s: String): String;
var variableStrings: TStringList;
    varString: String;
    split: array of string;
    varName, varValue: String;
    i: Integer;
begin
    variableStrings := TStringList.Create();    
    Ares.Variables.SaveToStrings(variableStrings);
    
    for varString in variableStrings do begin
        _macro.EventLogAdd(varString);
        split := varString.split('=');
        
        if Length(split) > 1 then
        begin
            varName := split[0].Trim;
            varValue := split[1];
        
            // Concatenate remaining parts if there are more than two parts after the split
            for i := 2 to High(split) do
            begin
                varValue := varValue + '=' + split[i];
            end;
          
            s := StringReplace(s, '#' + varName + '#', varValue.Trim, [rfReplaceAll]);
        end;
    end;                                     
    
    result := s;
end;

function oxSQLStepWithAresVariablesApplied(stepId: Integer): String;
var stepSQL: String;
begin
    stepSQL := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [ares.AcKey, stepId]);
    stepSQL := oxApplyAresVariablesToString(stepSQL);
    result := stepSQL;
end;

function oxSQLStepResultWithParamsAnotherAres(stepId: Integer; aresAcKey: String; params: array of Variant): String;
var stepSQL: String;
begin
    stepSQL := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [aresAcKey, stepId]);
    result := oxSQLExpWithParams(stepSQL, params);
end;

function oxSQLStepResult( stepId: Integer): String;
var stepSQL: String;
begin
    stepSQL := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [Ares.AcKey, stepId]);
    result := oxSQLExp(stepSQL);
end;

function oxSQLStepResultWithParams(stepId: Integer; params: array of Variant): String;
var stepSQL: String;
begin
    stepSQL := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [Ares.AcKey, stepId]);
    result := oxSQLExpWithParams(stepSQL, params);
end;

procedure oxDefer(callback: oxCallback; forMs: integer = 1);
var deferrer: TDeferEvent;
begin
    deferrer := TDeferEvent.Create(callback, forMs);
end;

constructor TDeferEvent.Create(forCallback: oxCallback; forTimeout: Integer);
begin
    callback := forCallback;
    timeout := forTimeout;
    timer := TTimer.Create(nil);
    timer.Enabled := false;
    timer.OnTimer := TimerFired;
    timer.Interval := timeout;
    timer.Enabled := true;
end;

procedure TDeferEvent.TimerFired(Sender: TObject);
begin
    timer.Enabled := false;
    callback();
end;

constructor TCheckboxListOnix.Create(AParent: TComponent); override;
begin    
    totalScrollboxHeight := 0;
    parent := AParent;
    values := TStringList.Create();
    popupMenu := TPopupMenu.Create(AParent);
    addMenuItems();
    scrollbox := TcxScrollBox.Create(AParent);
    with scrollbox do
    begin  
        Align := alClient;
        Parent := AParent;
        OnContextPopup := popupMenuPopup;
        OnMouseWheelDown := scrollboxMouseWheelDown;
        OnMouseWheelUp := scrollboxMouseWheelUp;
    end;
end;

procedure oxAddToNavigatorAt(field: String; fieldLen: Integer; fieldName: String; fieldF: String; atIndex: Integer = -1);
begin
    oxAddToNavigator(field, fieldLen, fieldName, fieldF, 'bMenuDBNavigator', atIndex);
end;

procedure oxAddDefToNavigatorAt(def: String; atIndex: Integer = -1);
begin
    oxAddDefToNavigator(def, 'bMenuDBNavigator', atIndex);
end;

procedure oxAddToNavigator(field: String; fieldLen: Integer; fieldName: String; fieldF: String; navigator: String = 'bMenuDBNavigator'; atIndex: Integer = -1);
begin
    oxAddDefToNavigator(
        field + #9 + IntToStr(fieldLen) + #9 + fieldName + #9 + fieldF,
        navigator,
        atIndex
    );
end;

procedure oxAddDefToNavigator(def: String; navigator: String = 'bMenuDBNavigator'; atIndex: Integer = -1);
var nav: TNavigator3;
    sl: TStringList;
begin
    nav := oxNavigator(navigator);
    sl := TStringList.Create;
    sl.CommaText := nav.LookupSelected.CommaText;
    nav.LookupSelected.Clear;
    if atIndex = -1 then
        sl.Add(def)
    else
        sl.Insert(atIndex, def);
    nav.LookupSelected := sl;
end;

procedure oxDataSetToCSV(DataSet: TdlDataSet; const FileName: string; const Delimiter: string = ';'; const QuoteEverything: boolean = false);
var
  StringList: TStringList;
  Field: TField;                                  
  Line: string;
  i: Integer;
begin
  StringList := TStringList.Create;
  try                              
    try
    DataSet.First;

    // Write column headers
    Line := '';
    for Field in DataSet.Fields do
    begin
      if Line <> '' then
        Line := Line + Delimiter;
      Line := Line + Field.FieldName;
    end;
    StringList.Add(Line);

    // Write data
    while not DataSet.Eof do
    begin
      Line := '';
      for i := 0 to DataSet.FieldCount - 1 do
      begin
        if Line <> '' then
          Line := Line + Delimiter;
        if QuoteEveryThing then
        begin
            Line := Line + QuotedStr(DataSet.Fields[i].AsString);
        end else
        begin
            Line := Line + DataSet.Fields[i].AsString;
        end;
      end;
      StringList.Add(Line);
      DataSet.Next;
    end;
    StringList.SaveToFile(FileName);
    except on E:Exception do
        begin
            _macro.EventLogAdd('Error: ' + E.message);
        end
    end;
  finally
    StringList.Free;
  end;
end;

procedure TCheckboxListOnix.addMenuItems();
var currentMenuItem: TMenuItem;
begin
    currentMenuItem := TMenuItem.Create(popupMenu);
    currentMenuItem.Caption := 'Izaberi sve';
    currentMenuItem.OnClick := checkAllMenuItemClicked;
    popupMenu.Items.Add(currentMenuItem);
    
    currentMenuItem := TMenuItem.Create(popupMenu);
    currentMenuItem.Caption := 'Odaberi sve';
    currentMenuItem.OnClick := uncheckAllMenuItemClicked;
    popupMenu.Items.Add(currentMenuItem);
    
    currentMenuItem := TMenuItem.Create(popupMenu);
    currentMenuItem.Caption := 'Izaberi inverzno';
    currentMenuItem.OnClick := checkInverseMenuItemClicked;
    popupMenu.Items.Add(currentMenuItem);
end;

procedure TCheckboxListOnix.AddFromCSV(CSV: string);
var
  lines, fields: TStringList;
  i: Integer;
begin
  // split CSV into lines
  lines := TStringList.Create;
  lines.Text := CSV;

  fields := TStringList.Create;
  fields.Delimiter := ',';
  fields.StrictDelimiter := True; // spaces are not considered as delimiters

  for i := 0 to lines.Count - 1 do
  begin
    // split each line into fields
    fields.DelimitedText := lines[i];

    // assuming CSV contains no missing fields
    if fields.Count = 3 then
      self.Add(fields[0], fields[1], fields[2] = '1')
    else
      raise Exception.Create('Invalid CSV data');
  end;

  fields.Free;
  lines.Free;
end;

procedure TCheckboxListOnix.AddFromDataSet(Dataset: TdlDataSet);
begin
  if not Dataset.Active then
  begin
    Dataset.open;
  end;
  Dataset.First;
  while not Dataset.EOF do
  begin
    // Make sure the dataset has at least three fields
    if Dataset.Fields.Count < 3 then
      raise Exception.Create('Dataset has less than three fields');

    self.Add(Dataset.Fields[0].AsString, 
             Dataset.Fields[1].AsString, 
             Dataset.Fields[2].AsString = '1');
             
    Dataset.Next;
  end;
end;


procedure TCheckboxListOnix.checkAllMenuItemClicked();
var
  i: Integer;    
  Child: TControl;
begin
    skipCheckboxCallbacks := true;
    for i := 0 to scrollbox.ControlCount - 1 do
    begin
        Child := scrollbox.Controls[i];
        
        if Child is TcxCheckbox then
        begin
            with Child as TcxCheckBox do
            begin
                Checked := true;
            end;
        end;
    end;       
    skipCheckboxCallbacks := false;
    if assigned(OnChanged) then OnChanged(self);
end;

procedure TCheckboxListOnix.uncheckAllMenuItemClicked();
var
  i: Integer;    
  Child: TControl;
begin
    skipCheckboxCallbacks := true;
    try
        for i := 0 to scrollbox.ControlCount - 1 do
        begin
            Child := scrollbox.Controls[i];
        
            if Child is TcxCheckbox then
            begin
                with Child as TcxCheckBox do
                begin
                    Checked := false;
                end;
            end;
        end; 
    finally
        begin           
            skipCheckboxCallbacks := false; 
        end
    end;
    if assigned(OnChanged) then OnChanged(self);
end;

procedure TCheckboxListOnix.checkInverseMenuItemClicked();
var
  i: Integer;    
  Child: TControl;
begin
    skipCheckboxCallbacks := true;
    try    
        for i := 0 to scrollbox.ControlCount - 1 do
        begin
            Child := scrollbox.Controls[i];
        
            if Child is TcxCheckbox then
            begin
                with Child as TcxCheckBox do
                begin
                    Checked := not Checked;
                end;
            end;
        end;  
    finally
        begin
            skipCheckboxCallbacks := false;
        end
    end;          
    if assigned(OnChanged) then OnChanged(self);
end;

procedure TCheckboxListOnix.Add(AKey: string; AValue: string; AChecked: boolean = false);
var cb: TdlcxCheckBox;
begin
    if values.IndexOf(AKey) <> -1 then
    begin
        _macro.EventLogAdd('TCheckboxListOnix: dupli unos! : ' + AKey);
        exit; 
    end;

    cb := TdlcxCheckBox.Create(scrollbox); // ako nije u varijabli, onda se eventi ne okidaju
    with cb do
    begin                  
        Parent := scrollbox;
        Caption := AValue;
        values.Add(AKey);
        Tag := values.Count; 
        Top := totalScrollboxHeight;
        totalScrollboxHeight := totalScrollboxHeight + Height;
        Checked := AChecked;
        OnClick := self.OnChangedWrapper;
        with TcxCheckBoxProperties(Properties) do
        begin
            OnChanged := self.OnChangedWrapper; 
        end;
    end;
end;

procedure TCheckBoxListOnix.OnChangedWrapper(Sender: TObject);
begin
    if (skipCheckboxCallbacks <> true) and (assigned(OnChanged)) then OnChanged(Self);
end;

procedure TCheckboxListOnix.popupMenuPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var pt: TPoint;
begin
    pt := TcxScrollBox(Sender).ClientToScreen(MousePos);
    popupMenu.Popup(pt.X, pt.Y);
end;

procedure TCheckboxListOnix.scrollboxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);  
begin  
  TcxScrollBox(Sender).VertScrollBar.Position := TcxScrollBox(Sender).VertScrollBar.Position + 1;  
end;  
 
procedure TCheckboxListOnix.scrollboxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);  
begin  
  TcxScrollBox(Sender).VertScrollBar.Position := TcxScrollBox(Sender).VertScrollBar.Position - 1;  
end;

function TCheckboxListOnix.GetSelectedKeys():TStringList;
var selectedKeys: TStringList;
  i: Integer;    
  Child: TControl;
begin
    selectedKeys := TStringList.Create();
    for i := 0 to scrollbox.ControlCount - 1 do
    begin
        Child := scrollbox.Controls[i];
        
        if Child is TcxCheckbox then
        begin
            with Child as TcxCheckBox do
            begin
                 if Checked then
                 begin
                    selectedKeys.Add(values[Tag - 1]);
                 end;
            end;
        end;
    end;
    result := selectedKeys;
end;

function TCheckboxListOnix.GetSelectedKeysJoined(by: String = ','):string;
var selectedKeys: TStringList;
    key: string;
begin
    result := '';
    selectedKeys := GetSelectedKeys();
    for key in selectedKeys do
    begin
        result := result + key;
        if not (selectedKeys.IndexOf(key) = selectedKeys.Count - 1) then
        begin
            result := result + by;
        end;
    end;
end;

function TCheckboxListOnix.GetSelectedKeysJoinedAndQuoted(by: String = ','):string;
var selectedKeys: TStringList;
    key: string;
begin
    result := '';
    selectedKeys := GetSelectedKeys();
    for key in selectedKeys do
    begin
        result := result + QuotedStr(key);
        if not (selectedKeys.IndexOf(key) = selectedKeys.Count - 1) then
        begin
            result := result + by;
        end;
    end;
end;

procedure oxDrillClassParent(obj: TObject); 
var
  cls: TClass;
begin
  cls := obj.ClassType;
  _macro.EventLogAdd(cls.ClassName);
  if Assigned(cls.ClassParent) then
    oxDrillClassParent(cls.ClassParent.NewInstance);
end;

function oxDateToSQLString(date: TDateTime): String;
begin
    Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', date);
end;

// sqlexp(query)
function oxSQLExp(sql:string):string
var dataSet: TdlDataSet;
var firstFieldName: string;
begin
    dataSet := TdlDataSet.Create(Ares);
    dataSet.SQL.Text := sql;
    dataSet.Debug := true;
    dataSet.DontHandleException := true;
    try
        dataSet.Open;
        try
            _macro.eventlogadd('izvodim ' + sql);
            if (dataSet.LastError <> null) and (not dataSet.LastError.Contains('return rows')) then
            begin                                         
                _macro.eventlogadd('dataSet.LastError: ' + dataSet.LastError);
                raise Exception(dataSet.LastError);
            end; 
            if dataSet.EOF then begin
                Result := '';
            end else begin       
                firstFieldName := dataSet.Fields[0].FieldName;
                Result := dataSet.FieldByName(firstFieldName).AsString;
            end;
        finally
            dataSet.Close;
        end;
    except on E:Exception do
        begin
            if not E.message.Contains('return rows') then 
            begin       
                _macro.EventLogAdd('Thrown exception: ' + E.message);
                raise E;
            end; 
        end;
    end;
end;

function oxSQLExpRowWithParams(sql: string; params: array of Variant): TdlDataSet;
var v: Variant;
    i: Integer;
    dataSet: TdlDataSet;
    firstFieldName: string;
    pName: string;
    strVal: string;
begin
    dataSet := TdlDataSet.Create(Ares);
    dataSet.SQL.Text := sql;
    dataSet.Debug := true;
    dataSet.DontHandleException := true;
    for i := 0 to Length(params) - 1 do
    begin                           
        pname := 'p' + inttostr(i);
        strVal := VarToStr(params[i]);         
        //_macro.eventlogadd('Postavljam ' + pname + ' na ' + strVal);
        dataSet.Params.ParamByName(pname).Value := params[i];
    end;      
    try
        dataSet.Open;
        Result := dataSet;
    except on E:Exception do
        begin 
            if not E.message.Contains('return rows') then 
            begin
                _macro.EventLogAdd('Thrown exception: ' + E.message);
                raise E;
            end; 
        end;
    end;
end;

function oxSQLExpWithParams(sql: string; params: array of Variant): string;
var v: Variant;
    i: Integer;
    dataSet: TdlDataSet;
    firstFieldName: string;
    pName: string;
    strVal: string;
begin
    dataSet := oxSQLExpRowWithParams(sql, params);     
    dataSet.Open;
    try
        _macro.eventlogadd('izvodim ' + sql); 
        if (dataSet.LastError <> null) and (not dataSet.LastError.Contains('return rows')) then
        begin            
            _macro.eventlogadd('dataSet.LastError: ' + dataSet.LastError);
            raise Exception(dataSet.LastError);
        end; 
        if dataSet.EOF then begin
            Result := '';       
        end else begin       
            firstFieldName := dataSet.Fields[0].FieldName;
            Result := dataSet.FieldByName(firstFieldName).AsString;
        end;
    finally
        dataSet.Close;
    end;
end;

function oxSQLBlobToStream(sql: string; params: array of Variant): TStream;
var
  i: Integer;
  dataSet: TdlDataSet;
  blobFieldName: string;
begin
  Result := nil;
  
  dataSet := TdlDataSet.Create(Ares);
  try
    dataSet.SQL.Text := sql;
    dataSet.Debug := true;
    dataSet.DontHandleException := true;

    for i := 0 to Length(params) - 1 do
    begin 
        dataSet.Params.ParamByName('p' + inttostr(i)).Value := params[i];
    end;      
    dataSet.Open; 

    if dataSet.LastError <> null then
    begin
        raise Exception.Create(dataSet.LastError);
    end; 

    if not dataSet.EOF then
    begin
        blobFieldName := dataSet.Fields[0].FieldName; // Assuming the first field is the BLOB field

        if not dataSet.FieldByName(blobFieldName).IsNull then
        begin
          Result := TMemoryStream.Create;
          TMemoryStream(Result).LoadFromStream(dataSet.CreateBlobStream(dataSet.FieldByName(blobFieldName), bmRead));
        end;
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

function oxAddCheckboxColumn(gridName: String; columnCaption: String; columnFieldName: String; width: integer = 50): TcxGridDBColumn;
begin
	Result := oxAddColumn(gridName, columnCaption, columnFieldName, width);
    with Result do
    begin
        PropertiesClass := TcxCheckBoxProperties;
        with TcxCheckBoxProperties(Properties) do
        begin
            ValueChecked := 'T';
            ValueUnchecked := 'F';
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
            showmessage('DataSet je ispravna komponenta, ali trenutno ne postoji DataSource, pomakni upit SQL-a na kasniji korak u programu.');
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
        showmessage('dataset +  ne postoji kao dataset niti kao datasource!');
    end; 
end;

// dataset moze biti naziv dataseta, ali i grida, bilo cega sto je ovdje implementirano if else if...'
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
        _macro.eventlogadd('Upit za DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? Rezultat je DataSet od krajnjeg DataSeta.');
    end
    else if c is TDaDBLookupComboBox then
    begin
        Result := TdlDataSet(TDaDBLookupComboBox(c).DataBinding.DataSource.DataSet);
        _macro.eventlogadd('Upit za DataSet od Lookupa ili od krajnjeg DataSeta za ' + dataset + '? Rezultat je DataSet od krajnjeg DataSeta.');
    end 
    else if c is TdlDataSet then
    begin
        Result := TdlDataSet(c);
    end 
    else if c is TcxGridDBBandedTableView then
    begin
        Result := TdlDataSet(TcxGridDBBandedTableView(c).DataController.DataSet); 
    end
    else if c is TNavigator3 then
    begin
        Result := TdlDataSet(TNavigator3(c).DataSource.DataSet);
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
    else if c is TcxGridDBBandedTableView then
    begin
        Result := c;
    end
    else
    begin       
        _macro.EventLogAdd('Was of type: ' + c.ClassName);
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

function oxConfirmBool(what: String): Boolean;
var res: Integer;
begin
    result := false;
    _macro.eventlogadd('Executing dialog');
    try
        res := Integer(Dialogs.MessageDlg(what, mtConfirmation, [mbYes, mbNo], 0, mbYes));
        if (res = mrYes) then
        begin       
            _macro.eventlogadd('Executing yes');
            result := true;
        end;
        if (res = mrNo) then 
        begin       
            _macro.eventlogadd('Executing no');
        end;
    except on E: Exception do
        _macro.eventlogadd('Dialog error: ' + E.Message);
    end;
end;

function oxNavigator(name: String = 'bMenuDBNavigator'): TNavigator3;
begin
    Result := TNavigator3(OwnerForm.FindComponent(name));
end;

function oxNavigatorAcKey(name: String = 'bMenuDBNavigator'): String;
var comp: TComponent;
begin
    comp := OwnerForm.FindComponent(name);
    if not assigned(comp) then
    begin
        showmessage(name + ' nije ispravan navigator! Ne postoji...');
    end else
    begin
        Result := oxNavigator(name).datasource.dataset.FieldByName('ackey').asstring;
    end;
end;

function oxGetValue(ofElement: String): String;
var comp: TComponent;
begin
    comp := OwnerForm.FindComponent(ofElement);
    
    if not assigned(comp) then
    begin               
        ShowMessage(ofElement + ' ne postoji');
    end else
    begin    
        _macro.eventlogadd('Element '  + ofElement + ' postoji, testiram vrstu'); // ovdje naredati sve moguce class opcije za koje zelimo implentirati trazenje vrijednosti
    if comp is TdlcxLabeledDBTextEdit then Result := TdlcxLabeledDBTextEdit(comp).EditingValue
        else if comp is TdlcxLabeledNumberEdit then Result := TdlcxLabeledNumberEdit(comp).EditingValue
    else if comp is TDaDBLookupComboBox then Result := TDaDBLookupComboBox(comp).EditingValue
        else showmessage('Nije implementirana vrsta za ' + ofElement + ': ' + comp.classname);
    end;
    
    _macro.eventlogadd('Element '  + ofElement +  ' postoji s value: ' + Result);
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
    else _macro.EventLogAdd(Format('Ne postoji element: "%s"', [elementName]));
end;

function oxGetButton(button: String): TcxButton;
begin
    Result := TcxButton(AresFindComponent(button, OwnerForm));
end;

function oxGetPopup(popup: String): TPopupMenu;
begin
    Result := TPopupMenu(AresFindComponent(popup, OwnerForm)); 
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

procedure oxBeforePopupClick(popupName: String; callback: oxCallback);
var localBeforeClick: TLocalAfterClick;
begin
    with oxGetPopup(popupName) do
    begin
        localBeforeClick := TLocalAfterClick.Create(OnPopup);
        localBeforeClick.Callback := callback;
        localBeforeClick.AfterOldEvent := false;    
        OnPopup := localBeforeClick.NewEvent;
        _macro.eventlogadd('New event set before, for ' + popupName);
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

procedure oxOnButtonClick(button: String; callback: oxCallback);
var localEvent: TLocalNotifyEvent;
begin
    with oxGetButton(button) do
    begin
        localEvent := TLocalNotifyEvent.Create(callback);
        localEvent.Callback := callback;
        OnClick := localEvent.NotifyEvent;
        _macro.eventlogadd('New event set for ' + button);
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
        _macro.EventLogAdd(Format('%s%s', [prefix, 'Komponenta nije postavljena']));
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


function oxSTruthy(v: String; zeroIsFalsy: boolean = false): boolean;
begin
    Result := false;
    
    if v <> null then
    begin
        if TRIM(v) <> '' then
        begin              
            if (not zeroIsFalsy) or 
               (zeroIsFalsy and (TRIM(v) <> '0')) then
            begin
                Result := true;
            end;
        end;
    end;
end;

function oxDTruthy(v: TDateTime): boolean;
begin
    Result := false;
    
    if v <> null then
    begin
        if v <> 0 then
        begin              
            Result := true;
        end;
    end;
end;

function oxColumnExists(tableName: String; columnName: String): boolean;
var alterSQL: String;
begin
    alterSQL := 'select top 1 1 from syscolumns where ID = OBJECT_ID(''' + tableName + ''') and NAME = ''' + columnName + ''';';
    Result := oxSQLExp(alterSQL) = '1';  
end;

Function oxTableExists(tableName: String): boolean;
Var 
  alterSQL: String;
Begin
  alterSQL := 'SELECT CASE WHEN ' +
        '(LEFT(:p0, 1) = ''#'' and object_id(''tempdb..'' + :p0) is not null) ' +
        'OR ' +
        '(LEFT(:p0, 1) <> ''#'' AND EXISTS (SELECT 1 FROM sys.tables WHERE name = :p0)) ' +
        'THEN 1 ELSE 0 END ';

  Result := oxSQLExpWithParams(alterSQL, [tableName]) = '1';
End;

end.
