/// <summary>
/// Table BC2SC_Transport Line (ID 61002).
/// </summary>
table 61002 "BC2SC_Transport Line"
{
    Caption = 'BC2SC_Transport Line';

    fields
    {
        field(1; "Transport No."; Code[20])
        {
            Caption = 'Transport No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Type"; Enum BC2SC_TransportLine_Type)
        {
            Caption = 'Type';
            trigger OnValidate()
            begin
                CheckModifyAllowed();
            end;

        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = const(Item)) Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                CheckModifyAllowed();
                Rec.TestField(Type, Rec.Type::Item);
                Item.get("No.");
                Rec.Description := Item.Description;
                Rec."Description 2" := Item."Description 2";
                Rec."Unit of Measure Code" := Item."Base Unit of Measure";
                CheckWeightperUnit();
            end;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            trigger OnValidate()
            begin
                CheckModifyAllowed();
            end;

        }
        field(8; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            trigger OnValidate()
            begin
                CheckModifyAllowed();
            end;

        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
            trigger OnValidate()
            begin
                CheckModifyAllowed();
            end;

        }

        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
        }

        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            trigger OnValidate()
            var
                ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
            begin
                CheckModifyAllowed();
                CheckWeightperUnit();
                ShipCloudSetup.get;
                if ShipCloudSetup."Def. Qty. to Pack with Qty." then
                    Rec.validate("Qty. to pack", Rec.Quantity);
                Rec."Total Weight" := Rec."Weight per Unit" * Rec.Quantity;
            end;
        }
        // field(15; "Quantity (Base)"; Decimal)
        // {
        //     Caption = 'Quantity (Base)';
        //     trigger OnValidate()
        //     begin
        //         CheckModifyAllowed();
        //     end;
        // }

        field(16; "Weight per Unit"; Decimal)
        {
            Caption = 'Weight per Unit';
        }
        field(17; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight (to Pack)';
            trigger OnValidate()
            begin
                CheckModifyAllowed();
                if (Rec."Total Weight" > 0) and (Rec."Qty. to pack" > 0) then
                    Rec."Weight per Unit" := Rec."Total Weight" / Rec."Qty. to pack"
            end;
        }
        field(18; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(20; "Parcel No."; Code[20])
        {
            Caption = 'Parcel No.';
            TableRelation = BC2SC_Parcel;
            Editable = false;

            trigger OnLookup()
            var
                Parcel: Record BC2SC_Parcel;
            begin
                Parcel.get(Rec."Parcel No.");
                Page.RunModal(page::"BC2SC_Parcel Card", Parcel);
            end;
        }
        field(21; "Tracking No."; Text[50])
        {
            FieldClass = FlowField;
            Editable = False;
            CalcFormula = lookup(BC2SC_Parcel."Tracking No." where("No." = field("Parcel No."), "Transport No." = field("Transport No.")));
        }
        field(30; "Qty. to pack"; Decimal)
        {
            Caption = 'Qty. to pack';
            trigger OnValidate()

            begin
                CheckModifyAllowed();
                CheckWeightperUnit();
                Rec."Total Weight" := Rec."Weight per Unit" * Rec."Qty. to pack";
            end;
        }

    }
    keys
    {
        key(PK; "Transport No.", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnModify()
    begin

    end;
    /// <summary>
    /// CheckModifyAllowed.
    /// </summary>
    procedure CheckModifyAllowed()
    begin
        Testfield("Parcel No.", '');
    end;

    local procedure CheckWeightperUnit()
    var
        Item: record Item;
    begin
        if "Weight per Unit" = 0 then
            if Item.Get(Rec."No.") then
                if Item."Gross Weight" > 0 then
                    Rec.validate("Weight per Unit", item."Gross Weight")
                else
                    Rec.Validate("Weight per Unit", item."Net Weight");
    end;
}
