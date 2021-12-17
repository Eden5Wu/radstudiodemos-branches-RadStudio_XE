{*******************************************************}
{                                                       }
{               Delphi DBX Framework                    }
{                                                       }
{ Copyright(c) 1995-2010 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

unit SimpleDSEx;

interface

uses
  Classes,
  DBClient,
  Provider,
  SqlExpr,
  SimpleDS
;

type

{ TInternalSQLDataSet }

  TInternalDataSetProvider = class(TDataSetProvider)
  published
    property DataSet;
    property Options;
    property UpdateMode;
  end;

{ TSimpleDataSetEx }
  /// <summary>
  /// 僅增加 DataSetProvider 屬性，其它和 TSimpleDataSet 完全相同
  /// </summary>
  TSimpleDataSetEx = class(TCustomClientDataSet)
  private
    FConnection: TSQLConnection;
    FInternalConnection: TSQLConnection; { Always points to internal if present }
    FDataSet: TInternalSQLDataSet;
    FProvider: TInternalDataSetProvider;
  protected
    procedure AllocConnection; virtual;
    procedure AllocDataSet; virtual;
    procedure AllocProvider; virtual;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure OpenCursor(InfoQuery: Boolean); override;
    procedure SetConnection(Value: TSQLConnection); virtual;
    { IProviderSupport }
    function PSGetCommandText: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FetchParams;
  published
    property Active;
    property Aggregates;
    property AggregatesActive;
    property AutoCalcFields;
    property Connection: TSQLConnection read FConnection write SetConnection;
    property DataSet: TInternalSQLDataSet read FDataSet;
    property Provider: TInternalDataSetProvider read FProvider;
    property Constraints;
    property DisableStringTrim;
    property FileName;
    property Filter;
    property Filtered;
    property FilterOptions;
    property FieldDefs;
    property IndexDefs;
    property IndexFieldNames;
    property IndexName;
    property FetchOnDemand;
    property MasterFields;
    property MasterSource;
    property ObjectView;
    property PacketRecords;
    property Params;
    property ReadOnly;
    property StoreDefs;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property OnReconcileError;
    property BeforeApplyUpdates;
    property AfterApplyUpdates;
    property BeforeGetRecords;
    property AfterGetRecords;
    property BeforeRowRequest;
    property AfterRowRequest;
    property BeforeExecute;
    property AfterExecute;
    property BeforeGetParams;
    property AfterGetParams;
  end;


implementation

uses
  SysUtils,
  SQLConst,
  DB
;

{ TSimpleDataSetEx }

constructor TSimpleDataSetEx.Create(AOwner: TComponent);
begin
  inherited;
  AllocProvider;
  AllocDataSet;
  AllocConnection;
end;

destructor TSimpleDataSetEx.Destroy;
begin
  inherited; { Reserved }
end;

procedure TSimpleDataSetEx.FetchParams;
begin
  if not HasAppServer and Assigned(FProvider) then
    SetProvider(FProvider);

  inherited FetchParams;
end;

procedure TSimpleDataSetEx.Loaded;
begin
  inherited;
  { Internal connection can now be safely deleted if needed }
  if FInternalConnection <> FConnection then
    FreeAndNil(FInternalConnection);
end;

procedure TSimpleDataSetEx.AllocConnection;
begin
  FConnection := TSQLConnection.Create(Self);
  FInternalConnection := FConnection;
  FConnection.Name := 'InternalConnection';             { Do not localize }
  FConnection.SetSubComponent(True);
  FDataSet.SQLConnection := FConnection;
end;

procedure TSimpleDataSetEx.AllocDataSet;
begin
  FDataSet := TInternalSQLDataSet.Create(Self);
  FDataSet.Name := 'InternalDataSet';                   { Do not localize }
  FDataSet.SQLConnection := FConnection;
  FDataSet.SetSubComponent(True);
  FProvider.DataSet := FDataSet;
end;

procedure TSimpleDataSetEx.AllocProvider;
begin
  FProvider := TInternalDataSetProvider.Create(Self);
  FProvider.DataSet := FDataSet;
  FProvider.Name := 'InternalProvider';                 { Do not localize }
  FProvider.SetSubComponent(True);
  SetProvider(FProvider);
end;

procedure TSimpleDataSetEx.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if not (csDestroying in ComponentState ) and (Operation = opRemove) and
     (AComponent = FConnection) and (AComponent.Owner <> Self) then
    AllocConnection;
end;

procedure TSimpleDataSetEx.OpenCursor(InfoQuery: Boolean);
begin
  if Assigned(FProvider) then
    SetProvider(FProvider);
  if FProvider.DataSet = Self then
    raise Exception.Create(SCircularProvider);
  inherited;
end;

procedure TSimpleDataSetEx.SetConnection(Value: TSQLConnection);
begin
  { Assigning existing value or clearing internal connection is a NOP }
  if (Value = FConnection) or ((Value = nil) and Assigned(FInternalConnection)) then
    Exit;
  { Remove FreeNotification from existing external reference }
  if FConnection <> FInternalConnection then
    FConnection.RemoveFreeNotification(Self);
  { Reference to external connection was cleared, recreate internal }
  if (Value = nil) then
    AllocConnection
  else
  begin
    { Free the internal connection when assigning an external connection }
    if Assigned(FInternalConnection) and
       { but not if we are streaming in, then wait until loaded is called }
       not (csLoading in FInternalConnection.ComponentState) then
      FreeAndNil(FInternalConnection);
    FConnection := Value;
    FConnection.FreeNotification(Self);
    FDataSet.SQLConnection := FConnection;
  end;
end;

function TSimpleDataSetEx.PSGetCommandText: string;
var
  IP: IProviderSupport;
begin
  if Supports(FDataSet, IProviderSupport, IP) then
    Result := IP.PSGetCommandText
  else
    Result := CommandText;
end;

end.
