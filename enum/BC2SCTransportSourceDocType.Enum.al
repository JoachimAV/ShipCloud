/// <summary>
/// Enum "BC2SC_TransportSourceDocType" (ID 61002).
/// </summary>
enum 61002 BC2SC_TransportSourceDocType
{
    Extensible = true;

    value(0; Manual)
    {
        Caption = 'Manual';
    }
    value(1; "Sales Order")
    {
        Caption = 'Sales Order';
    }
    value(10; "Service Order")
    {
        Caption = 'Service Order';
    }
    value(4; "Segment")
    {
        Caption = 'Segment';
    }
}
