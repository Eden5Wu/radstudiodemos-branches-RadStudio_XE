unit Main;

interface

uses
  DBXCommon, DBXCommonTable, DBXMetaDataNames, DBXMetaDataReader,
  DBXCustomDataGenerator,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBXMetaDataProvider, DB, SqlExpr,
  DBXDataExpressMetaDataProvider, DBXTypedTableStorage, StdCtrls, DbxDataGenerator,
  FMTBcd, DBXMSSQL;

type
  TForm2 = class(TForm)
    SQLConnection1: TSQLConnection;
    Button1: TButton;
    Memo1: TMemo;
    SQLQuery1: TSQLQuery;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CreateTestData;
    procedure CreateEdenTestTable(AProvider: TDBXMetaDataProvider);
    function FetchDBXMetaProvider: TDBXMetaDataProvider;
    function TableExists(AProvider: TDBXMetaDataProvider; ATableName: string):Boolean;
    function FetchColumns(AProvider: TDBXMetaDataProvider; ATableName: string): TDBXTable;
    procedure FillGeneratorColumns(AProvider: TDBXMetaDataProvider; ADataGenerator: TDbxDataGenerator);
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

const
  EdenTestTable = 'EdenTestTable';

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
var
  LDBXTran: TDBXTransaction;
begin
  if not SQLConnection1.Connected then
    SQLConnection1.Open;
  LDBXTran := SQLConnection1.BeginTransaction;
  try
    CreateTestData;
    SQLConnection1.CommitFreeAndNil(LDBXTran);
  except
    SQLConnection1.RollbackFreeAndNil(LDBXTran);
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
  // This function retrieves a list of indexes in a table from the metadata
  // provider.
  function DBXGetIndexes(const AProvider: TDBXMetaDataProvider;
    const ATableName: string): TDBXIndexesTableStorage;
  var
    Coll: TDBXTable;
  begin
    // Retrieve a collection of all the indexes in this table.
    Coll := AProvider.GetCollection(TDBXMetaDataCommands.GetIndexes
      + ' ' + AProvider.QuoteIdentifierIfNeeded(ATableName));
    //CheckCollection(Coll, TDBXIndexesTableStorage, 'indexes for table ' + ATableName);
    Result := Coll as TDBXIndexesTableStorage;
  end;
  function DBXGetIndexColumns(const AProvider: TDBXMetaDataProvider;
    const ATableName, AIndexName: string ): TDBXIndexColumnsTableStorage; overload;
  var
    Coll:  TDBXTable;
  begin
    // Retrieve a collection of the columns associated with an index in this table.
    Coll := AProvider.GetCollection(
      TDBXMetaDataCommands.GetIndexColumns + ' '
        + AProvider.QuoteIdentifierIfNeeded(ATableName)
        + ' ' +  AProvider.QuoteIdentifierIfNeeded(AIndexName));
    //CheckCollection(Coll, TDBXIndexColumnsTableStorage, 'index columns for index ' + AIndexName + ' in table ' + ATableName);
    Result := Coll as TDBXIndexColumnsTableStorage;
  end;
  // This function retrieves a list of columns in a table from the metadata
  // provider.
  function DBXGetColumns(const AProvider: TDBXMetaDataProvider;
    const ATableName: string): TDBXColumnsTableStorage;
  var
    Coll: TDBXTable;
  begin
    // Retrieve a collection of all the columns in this table.
    Coll := AProvider.GetCollection(TDBXMetaDataCommands.GetColumns
      + ' ' + AProvider.QuoteIdentifierIfNeeded(ATableName));
    //CheckCollection(Coll, TDBXColumnsTableStorage, 'columns for table ' + ATableName);
    Result := Coll as TDBXColumnsTableStorage;
  end;
var
  LProvider: TDBXMetaDataProvider;
  LIndex: TDBXIndexesTableStorage;
  LCols: TDBXIndexColumnsTableStorage;
  LColumnList: string;
  //LCol:
begin
  LProvider := FetchDBXMetaProvider;
  try
    LIndex := DBXGetIndexes(LProvider, EdenTestTable);

    while LIndex.InBounds do
    begin
      if LIndex.Primary then
      begin
        LCols := DBXGetIndexColumns(LProvider, EdenTestTable, LIndex.IndexName);
        while LCols.InBounds do
        begin
          LColumnList := LColumnList + LCols.ColumnName + ',';
          LCols.Next;
        end;
        LCols.Free;
      end;
      LIndex.Next;
    end;
    LIndex.Free;
  finally
    if Length(LColumnList) > 0 then
      LColumnList := Copy(LColumnList, 1, Length(LColumnList)-1);
    Memo1.Text := LColumnList;
    FreeAndNil(LProvider);
  end;
end;

procedure TForm2.CreateEdenTestTable(AProvider: TDBXMetaDataProvider);
  procedure AddPrimaryKey(Provider: TDBXMetaDataProvider;
    LTableMeta: TDBXMetaDataTable; ColumnName: string);
  var
    index: TDBXMetaDataIndex;
  begin
    index := TDBXMetaDataIndex.Create;
    index.TableName := LTableMeta.TableName;
    index.AddColumn(ColumnName);

    Provider.CreatePrimaryKey(index);
    index.Free;
  end;
var
  TableMeta:        TDBXMetaDataTable;
  av:               TDBXUnicodeVarCharColumn;
begin
    TableMeta := TDBXMetaDataTable.Create;
    TableMeta.TableName := EdenTestTable;
    av := TDBXUnicodeVarCharColumn.Create('var100', 100 );
    av.Nullable := False;
    TableMeta.AddColumn( av );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var200', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var300', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var400', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var500', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var600', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var700', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var800', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var900', 100 ) );
    TableMeta.AddColumn( TDBXUnicodeVarCharColumn.Create('var901', 100 ) );

    // NTEXT
    //av := TDBXUnicodeVarCharColumn.Create('var_long', 100 );
    //av.Long := True;
    //TableMeta.AddColumn( av );

    // TEXT
    //TableMeta.AddColumn( TDBXAnsiLongColumn.Create('ansilong' ) );

    AProvider.CreateTable(TableMeta);
    AddPrimaryKey(AProvider, TableMeta, 'var100');

    TableMeta.Free;
end;

procedure TForm2.CreateTestData;
var
  LProvider: TDBXMetaDataProvider;
  LDataGenerator: TDbxDataGenerator;
  LDBXCmd: TDBXCommand;
  LPos01: Integer;
begin
  LProvider := FetchDBXMetaProvider;
  try
    if TableExists(LProvider, EdenTestTable) then
      LProvider.DropTable(EdenTestTable);
    CreateEdenTestTable(LProvider);

    LDataGenerator := TDbxDataGenerator.Create;
    try
      LDataGenerator.TableName := EdenTestTable;
      LDataGenerator.MetaDataProvider := LProvider;
      FillGeneratorColumns(LProvider, LDataGenerator);
      LDBXCmd := SQLConnection1.DBXConnection.CreateCommand;
      LDBXCmd.Text := LDataGenerator.CreateParameterizedInsertStatement;
      LDBXCmd.Prepare;
      //Memo1.Lines.Text := (LDBXCmd.Text);
      LDataGenerator.AddParameters(LDBXCmd);
      for LPos01 := 1 to 100000 do
      begin
        LDataGenerator.SetInsertParameters(LDBXCmd, LPos01);
        LDBXCmd.ExecuteUpdate;
      end;
      LDBXCmd.Free;
    finally
      LDataGenerator.Free;
    end;
  finally
    FreeAndNil(LProvider);
  end;
end;

function TForm2.FetchColumns(AProvider: TDBXMetaDataProvider;
  ATableName: string): TDBXTable;
begin
  Result := AProvider.GetCollection( TDBXMetaDataCommands.GetColumns + ' ' + ATableName );
end;

function TForm2.FetchDBXMetaProvider: TDBXMetaDataProvider;
begin
  if not SQLConnection1.Connected then
    SQLConnection1.Open;
  Result := TDBXDataExpressMetaDataProvider.Create();
  try
    with TDBXDataExpressMetaDataProvider(Result) do
    begin
      Connection := SQLConnection1.DBXConnection;
      Open;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TForm2.FillGeneratorColumns(AProvider: TDBXMetaDataProvider;
  ADataGenerator: TDbxDataGenerator);
  function CreateWideStrColumn(AName: string; ALength: Integer): TDBXWideStringSequenceGenerator;
  var LCol: TDBXMetaDataColumn;
  begin
    LCol := TDBXUnicodeCharColumn.Create(AName, ALength);
    Result := TDBXWideStringSequenceGenerator.Create(LCol);
    LCol.Free;
  end;
var
  cols: TDBXTable;
begin
  cols := FetchColumns(AProvider, EdenTestTable);
  if Assigned(cols) and (cols is TDBXColumnsTableStorage) then
  begin
    while (cols.InBounds) do
    begin
      case TDBXColumnsTableStorage(cols).DbxDataType of
        TDBXDataTypes.UnknownType,
        TDBXDataTypes.WideStringType: begin
          ADataGenerator.AddColumn(CreateWideStrColumn(TDBXColumnsTableStorage(cols).ColumnName, TDBXColumnsTableStorage(cols).Precision));
        end;
      end;
      cols.Next;
    end;
    cols.Free;
  end;
end;

function TForm2.TableExists(AProvider: TDBXMetaDataProvider;
  ATableName: string): Boolean;
var
  TableCollection:  TDBXTable;

begin
  // Get a table collection from the provider that will contain the table if it does exist.
  TableCollection := AProvider.GetCollection(TDBXMetaDataCommands.GetTables + ' ' + ATableName + ' ' + TDBXTableType.Table);

  // GetCollection returns a class instance, whose type depends on the query passed.
  // So we double-check to make sure that we've been returned the type we want.
  if (TableCollection = nil) or not (TableCollection is TDBXTablesTableStorage) then
      raise Exception.Create('Failed to get collection of tables');

  // If there is a record for the desired table, Next will return true (the first row).
  // Otherwise it will return false.
  try
    Result := TableCollection.Next;

  finally
    TableCollection.Free;

  end;
end;

end.
