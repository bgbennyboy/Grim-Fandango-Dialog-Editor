//Original fileparser unit by Jimmi Thøgersen (Serge`)
//This is a modified and simplified version

unit FileParser;

interface

uses
	Classes, SysUtils;

type
	TFileParser = class(TFileStream)
  private
    FXORVal: byte;
    FXORWordVal: word;
    FXORDWordVal: longword;
    procedure SetXORVal(const Value: byte);
 	public
   	function EOF: boolean;
   	property XORVal: byte read FXORVal write SetXORVal;
   	function ReadByte(Offset: integer = -1): byte;
      function ReadBlockName(Offset: integer = -1): string;
      function ReadBlockSize: Integer;
      function ReadBlock(Blocksize: integer): string;
      function ReadWord(Offset: integer = -1): word;
      function ReadWordBE(Offset: integer = -1): word;
      function ReadDWord(Offset: integer = -1): longword;
      function ReadDWordBE(Offset: integer = -1): longword;
      function ReadBuffer(var Buffer; Count: longint; Offset: integer = -1): longint;
    	constructor Create(FileName: string; AXORVal: byte); reintroduce;
      destructor Destroy; override;
   end;

implementation

constructor TFileParser.Create(FileName: string; AXORVal: byte);
begin
	inherited Create(FileName,fmOpenRead or fmShareDenyWrite);
	SetXORVal(AXORVal);
end;

destructor TFileParser.Destroy;
begin

  inherited;
end;


function TFileParser.EOF: boolean;
begin
	result:=Position=Size;
end;

function TFileParser.ReadBlockName(Offset: integer): string;
begin
    //Seek(Offset,soFromCurrent);
   result:=chr(ReadByte)+chr(ReadByte)+chr(ReadByte)+chr(ReadByte);
end;

function TFileParser.ReadBlockSize: Integer;
begin
  result:=(ReadByte)+(ReadByte)+(ReadByte)+(ReadByte);
end;

function TFileParser.ReadBlock(Blocksize: integer): string;
var
counter: integer;
byteholder: string;
totalbytes: string;
begin
   seek(-8,sofromcurrent);
   counter:=-1;
    repeat
      begin
      byteholder:=chr(readbyte);
      totalbytes:=totalbytes + byteholder;
      inc(counter);
      end;
    until counter=blocksize;
   result:=totalbytes;
end;

function TFileParser.ReadBuffer(var Buffer; Count,
  Offset: integer): longint;
var
	n: integer;
  BufferPtr: PAnsiChar;
begin
	result:=Read(Buffer,Count);
 	BufferPtr:=@Buffer;
   for n:=0 to Result-1 do
   begin
		Byte(BufferPtr[n]):=Byte(BufferPtr[n]) xor FXORVal;
   end;
end;

function TFileParser.ReadByte(Offset: integer): byte;
begin
if Offset>-1 then
   	Seek(Offset,soFromCurrent);
	Read(result,1);
   result:=result xor FXORVal;
end;

function TFileParser.ReadDWord(Offset: integer): longword;
begin
	if Offset>-1 then
   	Seek(Offset,soFromCurrent);
   Read(result,4);
   result:=result xor FXORDWordVal;
end;

function TFileParser.ReadDWordBE(Offset: integer): longword;
begin
	if Offset>-1 then
   	Seek(Offset,soFromCurrent);
	result:=ReadByte shl 24
          +ReadByte shl 16
   		 +ReadByte shl 8
          +ReadByte;
end;

function TFileParser.ReadWord(Offset: integer): word;
begin
	if Offset>-1 then
   	Seek(Offset,soFromCurrent);
   Read(result,2);
   result:=result xor FXORWordVal;
end;

function TFileParser.ReadWordBE(Offset: integer): word;
begin
	if Offset>-1 then
   	Seek(Offset,soFromCurrent);
	result:=ReadByte shl 8
   		 +ReadByte;
end;

procedure TFileParser.SetXORVal(const Value: byte);
begin
  FXORVal := Value;
end;

end.
 