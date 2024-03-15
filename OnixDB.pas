unit OnixDB;

interface

uses Variants, dlDatabase, Sysutils;

function oxSQLStepResultWithParams(stepId: Integer; params: array of Variant): String; 
function oxGetStepSQLFromAres(stepId: Integer; aresAcKey: String): String;
function oxSQLExpWithParams(sql: string; params: array of Variant): string;
function oxSQLExpRowWithParams(sql: string; params: array of Variant): TdlDataSet;
function oxMakeDSWithParams(sql: String; params: array of Variant): TdlDataSet;
function oxGetStepSQL(stepId: Integer): String;

implementation 

function oxSQLStepResultWithParams(stepId: Integer; params: array of Variant): String;
var stepSQL: String;
begin
    stepSQL := oxGetStepSQLFromAres(stepId, Ares.AcKey);
    result := oxSQLExpWithParams(stepSQL, params);
end;

function oxGetStepSQLFromAres(stepId: Integer; aresAcKey: String = nil): String;
begin
    Result := oxSQLExpWithParams('select CONVERT(varchar(max), acSQLExp) from tPA_SQLIStep where acKey = :p0 and anNo = :p1', [aresAcKey, stepId]);
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
            if dataSet.Fields.Count > 0 then
            begin
                firstFieldName := dataSet.Fields[0].FieldName;
                Result := dataSet.FieldByName(firstFieldName).AsString;
            end else begin
                _macro.EventLogAdd('No return fields to return');
                Result := '';
            end;
        end;
    finally
        dataSet.Close;
    end;
end;


function oxSQLExpRowWithParams(sql: string; params: array of Variant): TdlDataSet;
var firstFieldName: string;
begin
    Result := oxMakeDSWithParams(sql, params);
             
    try
        Result.Open;
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


function oxMakeDSWithParams(sql: String; params: array of Variant): TdlDataSet;
var i: Integer;
    pName: string;
begin        
    Result := TdlDataSet.Create(Ares);
    Result.SQL.Text := sql;
    Result.Debug := true;
    Result.DontHandleException := true;
    
    for i := 0 to Length(params) - 1 do
    begin                           
        pname := 'p' + inttostr(i);
        _macro.EventLogAdd('type of param value: ' + IntToStr(VarType(params[i])));
        if VarType(params[i]) = 8209 then
        begin    
            raise Exception.Create('Are you using oxSQLStoreBlob for blobs?');               
        end;
                    
        Result.Params.ParamByName(pname).Value := params[i];
    end; 
end;


function oxGetStepSQL(stepId: Integer): String;
begin
    Result := oxGetStepSQLFromAres(stepId, Ares.AcKey);
end;


end.
