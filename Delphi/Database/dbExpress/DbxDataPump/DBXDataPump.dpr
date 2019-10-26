{*******************************************************}
{                                                       }
{               Delphi DBX Framework                    }
{                                                       }
{ Copyright(c) 1995-2010 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}
program DBXDataPump;

uses
  Forms,
  DBLogDlg,
  DBPWDlg,
  GridNavFrame in 'GridNavFrame.pas' {GridFrame: TFrame},
  DBXPumpForm in 'DBXPumpForm.pas' {DataPumpForm},
  QueryForm in 'QueryForm.pas' {FormQuery},
  DBXUtils in '..\Utils\DBXUtils.pas',
  CommandParser in '..\Utils\CommandParser.pas',
  DBGridExts in '..\Utils\DBGridExts.pas',
  DBXMatch in '..\Utils\DBXMatch.pas',
  DBXMigrator in '..\Utils\DBXMigrator.pas',
  DBXPumpUtils in '..\Utils\DBXPumpUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'dbExpress Data Pump';
  Application.CreateForm(TDataPumpForm, DataPumpForm);
  Application.CreateForm(TDataPumpForm, DataPumpForm);
  Application.CreateForm(TFormQuery, FormQuery);
  Application.Run;
end.
