/// <summary>
/// Table "Packaging" (ID 61004).
/// </summary>
table 61004 "BC2SC_Packaging"
{
    Caption = 'Packaging';
    LookupPageId = 61005;
    DrillDownPageId = 61005;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(20; Length; Decimal)
        {
            Caption = 'Length';
            DataClassification = ToBeClassified;
        }
        field(21; Width; Decimal)
        {
            Caption = 'Width';
            DataClassification = ToBeClassified;
        }
        field(22; Height; Decimal)
        {
            Caption = 'Height';
            DataClassification = ToBeClassified;
        }
        field(24; "Max. Weight"; Decimal)
        {
            Caption = 'Max. Weight';
        }
        field(27; "Package weight"; Decimal)
        {
            Caption = 'Package weight';
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
