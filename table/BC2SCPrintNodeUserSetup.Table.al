table 61005 "BC2SC_PrintNode User Setup"
{
    Caption = 'BC2SC_PrintNode User Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(2; "Label Printer"; Code[10])
        {
            Caption = 'Label Printer';
            TableRelation = "BC2SC_PrintNode Label Printer";
        }
        field(3; "Label Printer Name"; Text[50])
        {
            Caption = 'Label Printer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("BC2SC_PrintNode Label Printer".Name where(code = field("Label Printer")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}
