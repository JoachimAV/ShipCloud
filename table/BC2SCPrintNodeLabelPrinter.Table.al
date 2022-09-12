table 61006 "BC2SC_PrintNode Label Printer"
{
    Caption = 'BC2SC_PrintNode Label Printer';
    LookupPageId = "BC2SC_PrintNode Label Printer";
    DrillDownPageId = "BC2SC_PrintNode Label Printer";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(3; "Printer ID"; Integer)
        {
            Caption = 'Printer ID';
            DataClassification = ToBeClassified;
        }
        field(5; Rotate; Integer)
        {
            Caption = 'Rotate';
            MinValue = 0;
            MaxValue = 360;
        }
        field(6; "Paper"; text[30])
        {
            Caption = 'Paper';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
