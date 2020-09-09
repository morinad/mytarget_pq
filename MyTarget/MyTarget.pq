
section MyTarget;

[DataSource.Kind="MyTarget", Publish="MyTarget.Publish"]
shared MyTarget.Stat =  Value.ReplaceType(MyTarget.Data, FuncType);


FuncType =  type function (
     reportType as (type text meta [
        Documentation.FieldCaption = "Report type:",
        Documentation.AllowedValues = {"campaigns","banners"}
    ]),
    start as (type text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.SampleValues = {"2020-02-28"}
    ]),
     end as (type text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.SampleValues = {"yesterday"}
    ])
    )
    as table meta [
        Documentation.Name = "Получаем звонки из системы MyTarget.",
       Documentation.LongDescription = "",
        Documentation.Examples = {
        [
            Description = "Получаем данные из рекламного кабинета MyTarget",
            Code = "myTarget(""2020-02-20"",""yesterday"")",
            Result ="Данные по датам, ID кампании, показам-кликам-расходам и целям."
        ]
        }
    ]
;




MyTarget.Data=(reportType as text, start as text, end as text)=>

let
get = [#"date_from"=dateFunc(start), #"date_to"=dateFunc(end), #"metrics"="base"],
headers = [#"Authorization"="Bearer "&Extension.CurrentCredential()[Key]],
web = Web.Contents("https://target.my.com/api/v2/statistics/"& reportType &"/day.json", [Query = get, Headers = headers, ManualStatusHandling = {404, 400}]),
result = Json.Document(web),
items = result[items],
#"Преобразовано в таблицу" = Table.FromList(items, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
#"Развернутый элемент Column1" = Table.ExpandRecordColumn(#"Преобразовано в таблицу", "Column1", {"id", "rows"}, {"id", "rows"}),
#"Развернутый элемент rows" = Table.ExpandListColumn(#"Развернутый элемент Column1", "rows"),
#"Развернутый элемент rows1" = Table.ExpandRecordColumn(#"Развернутый элемент rows", "rows", {"date", "base"}, {"date", "base"}),
#"Развернутый элемент base" = Table.ExpandRecordColumn(#"Развернутый элемент rows1", "base", {"shows", "clicks", "goals", "spent"}, {"shows", "clicks", "goals", "spent"}),
#"Измененный тип" = Table.TransformColumnTypes(#"Развернутый элемент base",{{"id", type text}, {"date", type date}, {"shows", Int64.Type}, {"clicks", Int64.Type}, {"goals", Int64.Type}}),
#"Измененный тип с языком" = Table.TransformColumnTypes(#"Измененный тип", {{"spent", type number}}, "en-AU"),
select = Table.SelectRows(#"Измененный тип с языком", each ([shows] <> 0) or ([clicks] <> 0) or ([goals] <> 0) or ([spent] <> 0)  )
in try result[error] otherwise select;



dateFunc= (dat)=>
       if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"yyyy-MM-dd") 
       else if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"yyyy-MM-dd")
       else if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"yyyy-MM-dd") 
       else dat;



MyTarget = [
    TestConnection = (dataSourcePath) => 
        { 
        "MyTarget.Stat",
        Json.Document(dataSourcePath)[reportType],
        Json.Document(dataSourcePath)[start],
        Json.Document(dataSourcePath)[end]
        },
    Authentication = [
        
       Key =[ ]
    ],
    Label = "MyTarget Connection"
];


MyTarget.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { "MyTarget  Connector", "Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g",
    SourceImage = MyTarget.Icons,
    SourceTypeImage = MyTarget.Icons
];

MyTarget.Icons = [
    Icon16 = { Extension.Contents("MyTarget16.png"), Extension.Contents("MyTarget20.png"), Extension.Contents("MyTarget24.png"), Extension.Contents("MyTarget32.png") },
    Icon32 = { Extension.Contents("MyTarget32.png"), Extension.Contents("MyTarget40.png"), Extension.Contents("MyTarget48.png"), Extension.Contents("MyTarget64.png") }
];
