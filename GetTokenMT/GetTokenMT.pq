// This file contains your Data Connector logic
section GetTokenMT;

[DataSource.Kind="GetTokenMT", Publish="GetTokenMT.Publish"]
shared GetTokenMT.Data = Value.ReplaceType(GetTokenMT.Func, FuncType);

FuncType = type function (
    
    getToken as (type text meta [
        Documentation.FieldCaption = "Operation:",
        Documentation.FieldDescription = "",
        Documentation.AllowedValues = {"Get","Refresh","Get for Agency"}
    ]),
     client_id as (type text meta [
        Documentation.FieldCaption = "Client ID:",
        Documentation.FieldDescription = "",
        Documentation.SampleValues = {"k8vhxgbOvtKTIT"}
    ]),
     client_secret as (type text meta [
        Documentation.FieldCaption = "Client Secret:",
        Documentation.FieldDescription = "",
        Documentation.SampleValues = {"uyQMhPl1dGbO4Fw1elf8nzK6drPqXbcOmkmOjrn0qxR2gUCNgJe9"}
    ]),
     refreshMT as (type nullable text meta [
        Documentation.FieldCaption = "Refresh token:",
        Documentation.FieldDescription = "",
        Documentation.SampleValues = {"u1y5M7h9lbaFdw1elf8nzK6drPqXbcOmkmOjrn0qxR2gUCNgJe9"}
    ]),
    clientName as (type nullable text meta [
        Documentation.FieldCaption = "Agency Client Name:",
        Documentation.FieldDescription = "",
        Documentation.SampleValues = {"client_name"}
    ])
    )
    as table meta [
        Documentation.Name = "GetTokenMT Function",
        Documentation.LongDescription = "Created to get refresh and access token from MyTarget.",
        Documentation.Examples = {
        [
            Description = "Get token row:",
            Code = "GetTokenMT.Data(""k8vhxgbOvtKTIT"",""uyQMhPl1dGbO4Fw1elf8nzK6drPqXbcOmkmOjrn0qxR2gUCNgJe9"")",
            Result = "Refresh and access token."
        ]
        }
    ];



GetTokenMT.Func =(getToken as text, client_id as text, client_secret as text, refreshMT as nullable text, clientName as nullable text)=>
let
agencyClientName = if clientName=null then "" else "agency_client_name="&clientName,
refresh = if refreshMT=null then "" else refreshMT,
tok = 
    if getToken = "Get" then "grant_type=client_credentials" 
    else if getToken = "Get for Agency" then "grant_type=agency_client_credentials&"&agencyClientName
    else "grant_type=refresh_token&refresh_token="&refresh,

data = Text.ToBinary(tok&"&client_id="&client_id&"&client_secret="&client_secret&"&permanent=true"),
headers = [#"Content-Type"="application/x-www-form-urlencoded"],
web = try Json.Document(Web.Contents(" https://target.my.com/api/v2/oauth2/token.json", [Content = data, Headers = headers, ManualStatusHandling = {404, 400}])) otherwise "Что-то пошло не так("
in     data;




GetTokenMT = [
    TestConnection = (dataSourcePath) => { "GetTokenMT.Data", Json.Document(dataSourcePath)[start],Json.Document(dataSourcePath)[end]},
    Authentication = [
        
         Implicit  = []
   
    ],
    Label = "GetTokenMT Connection"
];



GetTokenMT.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { "GetTokenMT Connector", "GetTokenMT Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g/",
    SourceImage = GetTokenMT.Icons,
    SourceTypeImage = GetTokenMT.Icons
];



GetTokenMT.Icons = [
    Icon16 = { Extension.Contents("GetTokenMT16.png"), Extension.Contents("GetTokenMT20.png"), Extension.Contents("GetTokenMT24.png"), Extension.Contents("GetTokenMT32.png") },
    Icon32 = { Extension.Contents("GetTokenMT32.png"), Extension.Contents("GetTokenMT40.png"), Extension.Contents("GetTokenMT48.png"), Extension.Contents("GetTokenMT64.png") }
];
