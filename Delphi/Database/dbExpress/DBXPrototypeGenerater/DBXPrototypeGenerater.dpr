program DBXPrototypeGenerater;

uses
  Forms,
  Main in 'Main.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  {$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown := DebugHook<>0;  //Debug Memory Leak
  {$WARN SYMBOL_PLATFORM ON}
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
