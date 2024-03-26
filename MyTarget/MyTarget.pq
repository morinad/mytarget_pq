
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
get = [#"date_from"=dateFunc(start), #"date_to"=dateFunc(end), #"metrics"="all"],
headers = [#"Authorization"="Bearer "&Extension.CurrentCredential()[Key]],
web = Web.Contents("https://ads.vk.com/api/v2/statistics/", [RelativePath = reportType &"/day.json", Query = get, Headers = headers, ManualStatusHandling = {404, 400}]),
result = Json.Document(web),
items = result[items],
#"Преобразовано в таблицу" = Table.FromList(items, Splitter.SplitByNothing(), null, null, ExtraValues.Error),


#"Развернутый элемент Column1" = Table.ExpandRecordColumn(#"Преобразовано в таблицу", "Column1", {"id", "rows"}, {"id", "rows"}),
#"Развернутый элемент rows" = Table.ExpandListColumn(#"Развернутый элемент Column1", "rows"),
#"Развернутый элемент rows1" = Table.ExpandRecordColumn(#"Развернутый элемент rows", "rows", {"date", "base", "uniques","video"}, {"date", "base", "uniques","video"}),

#"Развернутый элемент base" = Table.ExpandRecordColumn(#"Развернутый элемент rows1", "base", {"shows", "clicks", "goals", "spent"}, {"shows", "clicks", "goals", "spent"}),
#"Развернутый элемент base2" = Table.ExpandRecordColumn(#"Развернутый элемент base", "uniques", {"reach", "frequency"}, {"reach", "frequency"}),
#"Развернутый элемент base3" = Table.ExpandRecordColumn(#"Развернутый элемент base2", "video", {"started", "paused"}, {"started", "paused"}),

#"Измененный тип" = Table.TransformColumnTypes(#"Развернутый элемент base3",{{"id", type text}, {"date", type date}, {"shows", Int64.Type},  {"started", Int64.Type},  {"paused", Int64.Type}, {"reach", Int64.Type}, {"frequency", type number}, {"clicks", Int64.Type}, {"goals", Int64.Type}}),

#"Измененный тип с языком" = Table.TransformColumnTypes(#"Измененный тип", {{"spent", type number}}, "en-AU"),
select = Table.SelectRows(#"Измененный тип с языком", each ([shows] <> 0) or ([clicks] <> 0) or ([goals] <> 0) or ([spent] <> 0)  ),

join = 
if reportType="campaigns" then Table.Join(select, "id",campaignNames,"campaign_id", JoinKind.LeftOuter ) else
if reportType="banners" then Table.Join(select, "id",bannerCampaignNames,"banner_id", JoinKind.LeftOuter ) else "Ошибка типа отчёта",
remove = Table.RemoveColumns(join,{"id"}),
reorder = try Table.ReorderColumns(remove,{"date", "campaign_id", "campaign_name", "banner_id", "shows", "clicks", "goals", "spent", "reach","frequency","started","paused"}) 
          otherwise  Table.ReorderColumns(remove,{"date", "campaign_id", "campaign_name", "shows", "clicks", "goals", "spent", "reach","frequency","started","paused"})
in try result[error] otherwise reorder;



campaignNames = 
let
    get=[limit="50"],
    headers = [#"Authorization"="Bearer "& Extension.CurrentCredential()[Key]],
    web = Function.InvokeAfter(()=>Web.Contents("https://ads.vk.com/api/v2/campaigns.json", [Query = get, Headers = headers, ManualStatusHandling = {404, 400}]),#duration(0,0,0,0.3)),
    result = Json.Document(web),
    Пользовательский1 = {0..Number.RoundDown(result[count]/50)},
    #"Преобразовано в таблицу1" = Table.FromList(Пользовательский1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Переименованные столбцы1" = Table.RenameColumns(#"Преобразовано в таблицу1",{{"Column1", "list"}}),
    #"Измененный тип1" = Table.TransformColumnTypes(#"Переименованные столбцы1",{{"list", Int64.Type}}),
    #"Умноженный столбец" = Table.TransformColumns(#"Измененный тип1", {{"list", each _ * 50, type number}}),
    #"Измененный тип2" = Table.TransformColumnTypes(#"Умноженный столбец",{{"list", type text}}),
    #"Добавлен пользовательский объект" = Table.AddColumn(#"Измененный тип2", "Пользовательский", each Function.InvokeAfter(()=>Json.Document(Web.Contents("https://target.my.com/api/v2/campaigns.json", [Query = get& [offset = [list]], Headers = headers, ManualStatusHandling = {404, 400}]))[items],#duration(0,0,0,0.2))),
    #"Развернутый элемент Пользовательский" = Table.ExpandListColumn(#"Добавлен пользовательский объект", "Пользовательский"),
    #"Развернутый элемент Пользовательский1" = Table.ExpandRecordColumn(#"Развернутый элемент Пользовательский", "Пользовательский", {"id", "name"}, {"id", "name"}),
    #"Измененный тип" = Table.TransformColumnTypes(#"Развернутый элемент Пользовательский1",{{"id", type text}, {"name", type text}}),
    #"Переименованные столбцы" = Table.RenameColumns(#"Измененный тип",{{"id", "campaign_id"}, {"name", "campaign_name"}}),
    #"Удаленные столбцы" = Table.RemoveColumns(#"Переименованные столбцы",{"list"}),
    distinct=Table.Distinct(#"Удаленные столбцы", {"campaign_id"})
in
    distinct;



bannerCampaignNames= 
let
    get=[limit="50"],
    headers = [#"Authorization"="Bearer "&Extension.CurrentCredential()[Key] ],
    web = Function.InvokeAfter(()=>Web.Contents("https://ads.vk.com/api/v2/banners.json", [Query = get, Headers = headers, ManualStatusHandling = {404, 400}]),#duration(0,0,0,0.3)),
    result = Json.Document(web),
    Пользовательский1 = {0..Number.RoundDown(result[count]/50)},
    #"Преобразовано в таблицу1" = Table.FromList(Пользовательский1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Переименованные столбцы1" = Table.RenameColumns(#"Преобразовано в таблицу1",{{"Column1", "list"}}),
    #"Измененный тип1" = Table.TransformColumnTypes(#"Переименованные столбцы1",{{"list", Int64.Type}}),
    #"Умноженный столбец" = Table.TransformColumns(#"Измененный тип1", {{"list", each _ * 50, type number}}),
    #"Измененный тип2" = Table.TransformColumnTypes(#"Умноженный столбец",{{"list", type text}}),
    #"Добавлен пользовательский объект" = Table.AddColumn(#"Измененный тип2", "Column1", each Function.InvokeAfter(()=>Json.Document(Web.Contents("https://target.my.com/api/v2/banners.json", [Query = get& [offset = [list]], Headers = headers, ManualStatusHandling = {404, 400}]))[items],#duration(0,0,0,0.2))),
    #"Развернутый элемент Пользовательский" = Table.ExpandListColumn(#"Добавлен пользовательский объект", "Column1"),
    #"Развернутый элемент Column1" = Table.ExpandRecordColumn(#"Развернутый элемент Пользовательский" , "Column1", {"campaign_id", "id"}, {"campaign_id", "id"}),
    #"Измененный тип" = Table.TransformColumnTypes(#"Развернутый элемент Column1",{{"id", type text}, {"campaign_id", type text}}),
    #"Переименованные столбцы" = Table.RenameColumns(#"Измененный тип",{{"id", "banner_id"}, {"campaign_id", "id"}}),
    #"Объединенные запросы" = Table.Join(#"Переименованные столбцы", {"id"},campaignNames, {"campaign_id"},  JoinKind.LeftOuter),
    #"Удаленные столбцы" = Table.RemoveColumns(#"Объединенные запросы",{"id", "list"}),
    distinct=Table.Distinct(#"Удаленные столбцы", {"banner_id"})
in
    distinct;



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
